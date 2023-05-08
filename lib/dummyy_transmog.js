async function filterCalgary(data, countryCode, regionCode, cityCode, stringify) {
  if (typeof data === "string") {
    data = JSON.parse(data);
  }

  let newData = [];

  for (let d of data) {
    let item = {};

    // Add the labels
    item['labels'] = {
      'category': 'public-art',
      'country': countryCode,
      'region': regionCode,
      'city': cityCode,
    };

    item['name'] = d['title'];
    if (item['name'] === null) {
      console.log(`Data name not found for art with url ${d['url']}`);
    }
    let coordinates = {
      'longitude': d['point']['coordinates'][0],
      'latitude': d['point']['coordinates'][1]
    };
    if (coordinates['longitude'] === null || coordinates['latitude'] === null) {
      console.log(`Data coordinates not found for art with url ${d['url']}`);
    }
    item['coordinates'] = coordinates;
    newData.push(item);
  }

  return newData;
}

async function filterSeattle(data, countryCode, regionCode, cityCode, stringify) {
  if (typeof data === "string") {
    data = JSON.parse(data);
  }

  let newData = [];

  for (let d of data) {
    let item = {};

    // Add the labels
    item['labels'] = {
      'category': 'public-art',
      'country': countryCode,
      'region': regionCode,
      'city': cityCode,
    };

    item['name'] = d['title'];
    if (item['name'] === null) {
      console.log(`Data name not found for art with url ${d['url']}`);
    }
    let coordinates = {
      'longitude': d['longitude'],
      'latitude': d['latitude']
    };
    if (coordinates['longitude'] === null || coordinates['latitude'] === null) {
      console.log(`Data coordinates not found for art with url ${d['url']}`);
    }
    item['coordinates'] = coordinates;
    newData.push(item);
  }

  return newData;
}

async function filterHamilton(data, countryCode, regionCode, cityCode, stringify) {
  if (typeof data === "string") {
    data = JSON.parse(data);
  }

  // Extract the features from the input data
  let features = data['features'];

  let newData = [];

  for (let d of features) {
    let item = {};

    // Extract the attributes for each feature
    let attributes = d['attributes'];

    // Add the labels
    item['labels'] = {
      'category': 'public-art',
      'country': countryCode,
      'region': regionCode,
      'city': cityCode,
    };

    item['name'] = attributes['ARTWORK_TITLE'];
    if (item['name'] === null) {
      console.log(`Data name not found for art with url ${attributes['url']}`);
    }
    let coordinates = {
      'longitude': attributes['LONGITUDE'],
      'latitude': attributes['LATITUDE']
    };
    if (coordinates['longitude'] === null || coordinates['latitude'] === null) {
      console.log(`Data coordinates not found for art with url ${attributes['url']}`);
    }
    item['coordinates'] = coordinates;
    newData.push(item);
  }

  return newData;
}