# heroku-client

[![Build Status](https://travis-ci.org/heroku/node-heroku-client.png?branch=master)](https://travis-ci.org/heroku/node-heroku-client)
[![codecov](https://codecov.io/gh/heroku/node-heroku-client/branch/master/graph/badge.svg)](https://codecov.io/gh/heroku/node-heroku-client)
[![Code Climate](https://codeclimate.com/github/heroku/node-heroku-client/badges/gpa.svg)](https://codeclimate.com/github/heroku/node-heroku-client)

A wrapper around the [v3 Heroku API][platform-api-reference].

- [Install](#install)
- [Usage](#usage)
  - [Generators](#generators)
  - [HTTP Proxies](#http-proxies)
- [Caching](#caching)
  - [Custom caching](#custom-caching)
- [Contributing](#contributing)
  - [Running tests](#running-tests)

## Install

```sh
$ npm install heroku-client --save
```

## Usage

To begin, require the Heroku module and create a client, passing in an API
token:

```javascript
const Heroku = require('heroku-client')
const heroku = new Heroku({ token: process.env.HEROKU_API_TOKEN })
```

heroku-client has `get`, `post`, `patch`, and `delete` functions which can make
requests with the specified HTTP method to any endpoint:

```javascript

// GET requests
heroku.get('/apps').then(apps => {
  // do something with apps
})

// POST requests
heroku.post('/apps').then(app => {})

// POST requests with body
heroku.post('/apps', {body: {name: 'my-new-app'}}).then(app => {})

// PATCH requests with body
heroku.patch('/apps/my-app', {body: {name: 'my-renamed-app'}}).then(app => {})

// DELETE requests
heroku.delete('/apps/my-old-app').then(app => {})
```

There is also an even more generic `request` function that can accept many more
options:

```javascript
heroku.request({
  method: 'GET',
  path: '/apps',
  headers: {
    'Foo': 'Bar'
  },
  parseJSON: false
}).then(response => {})
```

### Generators

It's easy to get heroku-client working with [generators][generators]. In this
example, I'll use the [co][co] library to wrap a function that will get the list
of all of my apps, and then get the dynos for each of those apps:

```javascript
const co     = require('co')
const heroku = require('heroku-client')
const hk     = heroku.createClient({ token: process.env.HEROKU_API_KEY })

let main = function * () {
  let apps  = yield hk.get('/apps')
  let dynos = yield apps.map(getDynos)

  console.log(dynos)

  function getDynos(app) {
    return hk.get(`/apps/${app.name}/dynos`)
  }
}

co(main)()
```

Hooray, no callbacks or promises in sight!

### HTTP Proxies

If you'd like to make requests through an HTTP proxy, set the
`HEROKU_HTTP_PROXY_HOST` environment variable with your proxy host, and
`HEROKU_HTTP_PROXY_PORT` with the desired port (defaults to 8080). heroku-client
will then make requests through this proxy instead of directly to
api.heroku.com.

## Caching

heroku-client can optionally perform caching of API requests.

heroku-client will cache any response from the Heroku API that comes with an
`ETag` header, and each response is cached individually (i.e. even though the
client might make multiple calls for a user's apps and then aggregate them into
a single JSON array, each required API call is individually cached). For each
API request it performs, heroku-client sends an `If-None-Match` header if there
is a cached response for the API request. If API returns a 304 response code,
heroku-client returns the cached response. Otherwise, it writes the new API
response to the cache and returns that.

To tell heroku-client to perform caching, add a config object to the options
with store and encryptor objects. These can be instances of memjs and
simple-encryptor, respectively.

```js
var Heroku    = require('heroku-client');
var memjs     = require('memjs').Client.create();
var encryptor = require('simple-encryptor')(SECRET_CACHE_KEY);
var hk        = new Heroku({
  cache: { store: memjs, encryptor: encryptor }
});
```

### Custom caching

Alternatively you can specify a custom cache implementation. Your custom implementation must define `get(key, cb(err, value))` and `set(key, value)` functions.

Here's a sample implementation that uses Redis to cache API responses for 5-minutes each:

```javascript
var redis        = require('redis');
var client       = redis.createClient();
var cacheTtlSecs = 5 * 60; // 5 minutes

var redisStore = {
  get: function(key, cb) {
    // Namespace the keys:
    var redisKey = 'heroku:api:' + key;
    client.GET(redisKey, cb);
  },

  set: function(key, value) {
    // Namespace the keys:
    var redisKey = 'heroku:api:' + key;
    client.SETEX(redisKey, cacheTtlSecs, value, function(err) {
      // ignore errors on set
    });
  }
};

var encryptor = require('simple-encryptor')(SECRET_CACHE_KEY);
var Heroku    = require('heroku-client');
var hk        = new Heroku({
  cache: {store: redisStore, encryptor: encryptor}
});
```

## Contributing

Inspect your changes, and
[bump the version number accordingly](http://semver.org/) when cutting a
release.

### Running tests

heroku-client uses [ava](https://github.com/avajs/ava) for tests:

```bash
$ npm test
```

[platform-api-reference]: https://devcenter.heroku.com/articles/platform-api-reference
[memjs]: https://github.com/alevy/memjs
[generators]: https://github.com/JustinDrake/node-es6-examples#generators
[co]: https://github.com/visionmedia/co
