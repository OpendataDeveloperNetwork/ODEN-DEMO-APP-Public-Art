import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_js/flutter_js.dart';

final JavascriptRuntime jsRuntime = getJavascriptRuntime();

Future<dynamic> readFile(String filePath) {
  File src = File(filePath);
  return src.readAsString();
}

Future<dynamic> readURL(String uri_string) async {
  Uri uri = Uri.parse(uri_string);
  var response = await http.get(uri);
  return response.body;
}

dynamic readURLOrFile(String path) async {
  dynamic data;
  if (path.startsWith('http://') || path.startsWith('https://')) {
    data = await readURL(path);
  } else {
    data = await readFile(path);
  }
  return data;
}

Future<void> writeFile(String filePath, dynamic data) async {
  File dst = File(filePath);
  await dst.writeAsString(data);
}

Future<void> writeURL(String url, dynamic data) async {
  Uri postURL = Uri.parse(url);
  Map<String, String> headers = {'Content-Type': 'application/json; charset=UTF-8'};

  http.Response resp = await http.post(postURL,headers: headers, body: jsonEncode(data));
  if (resp.statusCode != 200) {
    throw 'Failed to post data "${postURL.host + postURL.path}": HTTP status code ${resp.statusCode}';
  }
}

Map sources = {
  'file_read': (Map params) async {
    return await readFile(params['path']);
  },
  'url_read': (Map params) async {
    return await readURL(params['path']);
  }
};

Map filters = {
  'null_filter': (dynamic data, Map params) async {
    return data;
  },
  'to_upper': (dynamic data, Map params) async {
    return data.toString().toUpperCase();
  },
  'to_lower': (dynamic data, Map params) async {
    return data.toString().toLowerCase();
  }
};

Map sinks = {
  'null': (Map params, dynamic data) async {
    return;
  },
  'file_write': (Map params, dynamic data) async {
    return await writeFile(params['path'], data);
  },
  'url_write': (Map params, dynamic data) async {
    return await writeURL(params['path'], data);
  }
};

dynamic runJSFilter(dynamic data) async {
  String evaluation = """JSON.stringify(filter(${jsonEncode(data)}, params), null);""";
  JsEvalResult filterResult = jsRuntime.evaluate("""JSON.stringify(filter(${jsonEncode(data)}, params), null);""");

  if (filterResult.isError) {
    throw 'running filter failed with:\n ${filterResult.rawResult}';
  }
  
  return jsonDecode(filterResult.toString());
}

Future<dynamic> runPipelineEntry(Function sourceFunc, Map sourceParams, List filters, List sinks, String schema) async {
  dynamic data = await sourceFunc(sourceParams);

  for (Map filter in filters) {
    dynamic filterFunc = await getFilterFunction(filter['func']);
    Map filterParams = await getFilterParameters(filter['params'] ?? {});
    filterParams['schema'] = schema;
    if (filterFunc is Function) {
      data = await filterFunc(data, filterParams);
    } else {
      data = await runJSFilter(data);
    }
  }

  for (Map sink in sinks) {
    Function sinkFunc = await getSinkFunction(sink['func']);
    Map sinkParams = sink['params'] ?? {};
    await sinkFunc(sinkParams, data);
  }
  return data;
}

Future<dynamic> runPipelineSchemaEntry(dynamic data, List filters, List sinks, String schema) async {
  for (Map filter in filters) {
    dynamic filterFunc = await getFilterFunction(filter['func']);
    Map filterParams = await getFilterParameters(filter['params'] ?? {});
    filterParams['schema'] = schema;
    if (filterFunc is Function) {
      data = await filterFunc(data, filterParams);
    } else {
      data = await runJSFilter(data);
    }
  }

  for (Map sink in sinks) {
    Function sinkFunc = await getSinkFunction(sink['func']);
    Map sinkParams = sink['params'] ?? {};
    await sinkFunc(sinkParams, data);
  }
  return data;
}

Future<Function> getSourceFunction(String name) async {
  Function source = sources[name];

  return source;
}

Future<dynamic> getFilterFunction(String name) async {
  if (name.startsWith('http://') || name.startsWith('https://')) {
    String filterStr = await readURL(name);

    JsEvalResult getResult = jsRuntime.evaluate("""var get = function() {$filterStr}; var filter = get();""");
    if (getResult.isError) {
      throw 'getting filter failed with:\n${getResult.toString()}';
    }
    return filterStr;

  } else {
    return filters[name];
  }
}

Future<Function> getSinkFunction(String name) async {
  Function sink = sinks[name];  

  return sink;
}

Future<String> getSchema(String path) async {
  String schema = await readURLOrFile(path);
  JsEvalResult getSchema = jsRuntime.evaluate("""var schema = `$schema`;""");
  if (getSchema.isError) {
    throw 'getting schema failed with:\n${getSchema.rawResult}';
  }

  return schema;
}

Future<void> loadAJV(String path) async {
  JsEvalResult ajvLoaded = jsRuntime.evaluate("""var ajvIsLoaded = (typeof ajv == 'undefined') ? "0" : "1"; ajvIsLoaded;""");
  if (ajvLoaded.isError) {
    throw 'checking if ajv is loaded failed with:\n${ajvLoaded.rawResult}';
  } else if (ajvLoaded.toString() == "0") {
    String ajvJS = await rootBundle.loadString(path);
    JsEvalResult loadAJV = jsRuntime.evaluate(ajvJS);
    if (loadAJV.isError) {
      throw 'loading avj validator failed with:\n${loadAJV.rawResult}';
    }
    JsEvalResult createAJV = jsRuntime.evaluate("""var ajv = new Ajv({ allErrors: true });""");
    if (createAJV.isError) {
      throw 'creating ajv validator failed with:\n${createAJV.rawResult}';
    }
  }
}

Future<Map> getFilterParameters(Map params) async {
  JsEvalResult setParams = jsRuntime.evaluate("""var params = ${jsonEncode(params)};""");
  if (setParams.isError) {
    throw 'getting params failed with:\n${setParams.rawResult}';
  }
  
  JsEvalResult setSchema = jsRuntime.evaluate("""params.schema = schema;""");
  if (setSchema.isError) {
    throw 'setting schema failed with:\n${setSchema.rawResult}';
  }

  if (params['validator'] == 'json') {
    await loadAJV("assets/ajv.js");
    JsEvalResult setAJV = jsRuntime.evaluate("""params.ajv = ajv""");
    if (setAJV.isError) {
      throw 'setting ajv validator failed with:\n${setAJV.rawResult}';
    }
  }

  if (params.containsKey('library')) {
    String library = await readURLOrFile(params['library']);
    params['library'] = library;
    JsEvalResult setLibrary = jsRuntime.evaluate("""var get = function() {$library}; params.library = get();""");
    if (setLibrary.isError) {
      throw 'setting library failed with:\n${setLibrary.rawResult}';
    }
  }

  return params;
}

Future<dynamic> transmogrifyEntry(Map entry, String schemaPath) async {
  Map source = entry['source'];
  List filters = entry['filters'];
  List sinks = entry['sinks'] ?? [];

  String schema = await getSchema(schemaPath);
  Function sourceFunc = await getSourceFunction(source['func']);

  return runPipelineEntry(sourceFunc, source["params"], filters, sinks, schema);
}

Future<dynamic> transmogrifySchemaEntry(List data, Map schemaEntry) async {
  List filters = schemaEntry['filters'] ?? [];
  List sinks = schemaEntry['sinks'] ?? [];

  String schema = await getSchema(schemaEntry['schema']);

  return runPipelineSchemaEntry(data, filters, sinks, schema);
}

Future<List> transmogrify(List manifest) async {
  List schemaEntryDatas = [];
  for (Map schemaEntry in manifest) {
    List entryDatas = [];
    for (Map entry in schemaEntry['entries']) {
      dynamic entryData = await transmogrifyEntry(entry, schemaEntry['schema']);
      entryDatas.add(entryData);
    }
    dynamic schemaEntryData = await transmogrifySchemaEntry(entryDatas, schemaEntry);
    schemaEntryDatas.add(schemaEntryData);
  }

  return schemaEntryDatas;
}

// example usage

// Future<List> main() async {
//   String manifest_string = await rootBundle.loadString("assets/van-texas-manifest.json");

//   List manifest = jsonDecode(manifest_string);

//   List data = await transmogrify(manifest);
//   return data;
// }