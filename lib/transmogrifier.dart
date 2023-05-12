import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_js/flutter_js.dart';
// http and https
// ajv

final JavascriptRuntime jsRuntime = getJavascriptRuntime();

Future<dynamic> readFile(String filePath) {
  File src = File(filePath);
  return src.readAsString();
}

Future<dynamic> readURL(String url) async {
  // should read a url
  var readURL = Uri.https(url, '');
  var response = await http.get(readURL);
  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');
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

Future<Null> writeFile(String filePath, dynamic data) async {
  File dst = File(filePath);
  await dst.writeAsString(data);
}

Future<void> writeURL(String url, dynamic data) async {
  // should write data to a url
  var postURL = Uri.https(url, '');
  var response = await http.post(postURL, body: data);
  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');
  JsEvalResult result = await jsRuntime.evaluate('response.body');
  return result.rawResult;
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

// data comes in as a string, leaves as a Map (I think types could be messed up here)
Future<Map> runPipelineEntry(Function sourceFunc, Map sourceParams, List filters, Function sinkFunc, Map sinkParams, String schema) async {
  dynamic data = await sourceFunc(sourceParams);

  for (Map filter in filters) {
    Function filterFunc = await getFilterFunction(filter['func']);
    Map filterParams = await getFilterParameters(filter['params'] ? filter['params'] : {});
    filterParams['schema'] = schema;
    data = await filterFunc(data, filterParams);
  }
  await sinkFunc(sinkParams, data);
  return data;
}

Future<List> runPipelineSchemaEntry(List data, List filters, Function sinkFunc, Map sinkParams, String schema) async {
  for (Map filter in filters) {
    Function filterFunc = await getFilterFunction(filter['func']);
    Map filterParams = await getFilterParameters(filter['params'] ? filter['params'] : {});
    filterParams['schema'] = schema;
    data = await filterFunc(data, filterParams);
  }
  await sinkFunc(sinkParams, data);
  return data;
}

Future<Function> getSourceFunction(String name) async {
  Function source; 

  if (name.startsWith('http://') || name.startsWith('https://')) {
    source = await readURL(name);
    // parse js
  } else {
    source = sources[name];
  }

  return source;
}

Future<Function> getFilterFunction(String name) async {
  Function filter; 

  if (name.startsWith('http://') || name.startsWith('https://')) {
    filter = await readURL(name);
    // parse js
  } else {
    filter = filters[name];
  }

  return filter;
}

Future<Function> getSinkFunction(String name) async {
  Function sink; 

  if (name.startsWith('http://') || name.startsWith('https://')) {
    sink = await readURL(name);
    // parse js
  } else {
    sink = sinks[name];
  }

  return sink;
}

Future<String> getSchema(String path) async {
  String schema = await readURLOrFile(path);
  return schema;
}

Future<Map> getFilterParameters(Map params) async {
  if (params['validator'] == 'json') {
    // some validator
  }

  if (params['library']) {
    String library = await readURLOrFile(params['library']);
    // parse js
  }

  return params;
}

Future<Map> transmogrifyEntry(Map entry, String schemaPath) async {
  Map source = entry['source'];
  List filters = entry['filters'];
  Map sink = entry['sink'] ? entry['sink'] : {'func': 'null', 'params': {}};

  String schema = await getSchema(schemaPath);
  Function sourceFunc = await getSourceFunction(source['func']);
  Function sinkFunc = await getSinkFunction(sink['func']);

  return runPipelineEntry(sourceFunc, source["params"], filters, sinkFunc, sink['params'], schema);
}

Future<List> transmogrifySchemaEntry(List data, Map schemaEntry) async {
  List filters = schemaEntry['filters'] ? schemaEntry['filters'] : [];
  Map sink = schemaEntry['sink'] ? schemaEntry['sink'] : {'func': 'null', 'params': {}};

  String schema = await getSchema(schemaEntry['schema']);
  Function sinkFunc = await getSinkFunction(sink['func']);

  return runPipelineSchemaEntry(data, filters, sinkFunc, sink['params'], schema);
}

Future<List> transmogrify(List manifest) async {
  List schemaEntryDatas = [];
  for (Map schemaEntry in manifest) {
    List entryDatas = [];
    for (Map entry in schemaEntry['entries']) {
      Map entryData = await transmogrifyEntry(entry, schemaEntry['schema']);
      entryDatas.add(entryData);
    }
    List schemaEntryData = await transmogrifySchemaEntry(entryDatas, schemaEntry);
    schemaEntryDatas.add(schemaEntryData);
  }

  return schemaEntryDatas;
}

void main() async {
  print('Current directory: ${Directory.current}');
  File manifest_file = File("assets\\van-texas-manifest.json");
  String manifest_string = await manifest_file.readAsString();
  List manifest = jsonDecode(manifest_string);

  transmogrify(manifest);
}

// void main() async {
//   // Get the system temp directory.
//   var systemTempDir = Directory.systemTemp;

//   // List directory contents, recursing into sub-directories,
//   // but not following symbolic links.
//   await for (var entity in
//       systemTempDir.list(recursive: true, followLinks: false)) {
//     print(entity.path);
//   }
// }
