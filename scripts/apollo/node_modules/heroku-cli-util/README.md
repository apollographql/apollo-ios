# heroku-cli-util [![Circle CI](https://circleci.com/gh/heroku/heroku-cli-util/tree/master.svg?style=svg)](https://circleci.com/gh/heroku/heroku-cli-util/tree/master)

[![Code Climate](https://codeclimate.com/github/heroku/heroku-cli-util/badges/gpa.svg)](https://codeclimate.com/github/heroku/heroku-cli-util)
[![Test Coverage](https://codeclimate.com/github/heroku/heroku-cli-util/badges/coverage.svg)](https://codeclimate.com/github/heroku/heroku-cli-util/coverage)
[![npm version](https://badge.fury.io/js/heroku-cli-util.svg)](http://badge.fury.io/js/heroku-cli-util)
[![License](https://img.shields.io/github/license/heroku/heroku-cli-util.svg)](https://github.com/heroku/heroku-cli-util/blob/master/LICENSE)

Set of helpful CLI utilities

## Installation

```sh
npm install heroku-cli-util --save
```

## Action

```js
let cli = require('heroku-cli-util');
yield cli.action('restarting dynos', co(function* () {
  let app = yield heroku.get(`/apps/${context.app}`);
  yield heroku.request({method: 'DELETE', path: `/apps/${app.name}/dynos`});
}));

// restarting dynos... done
```

## Prompt

```js
let cli   = require('heroku-cli-util');
let email = yield cli.prompt('email', {});
console.log(`your email is: ${email}`);
```

**cli.prompt options**

```js
cli.prompt('email', {
  mask: true, // mask input field after submitting
  hide: true // mask characters while entering
});
```

## Confirm App

Supports the same async styles as `prompt()`. Errors if not confirmed.

Basic

```js
let cli = require('heroku-cli-util');
yield cli.confirmApp('appname', context.flags.confirm);

// !     WARNING: Destructive Action
// !     This command will affect the app appname
// !     To proceed, type appname or re-run this command with --confirm appname

> appname
```

Custom message

```js
let cli = require('heroku-cli-util');
yield cli.confirmApp('appname', context.flags.confirm, 'foo');

// !     foo
// !     To proceed, type appname or re-run this command with --confirm appname

> appname
```

Note that you will still need to define a `confirm` flag for your command.

## Errors

```js
let cli = require('heroku-cli-util');
cli.error("App not found");
// !    App not found
```

## Warnings

```js
let cli = require('heroku-cli-util');
cli.warn("App not found");
// !    App not found
```

## Dates

```js
let cli = require('heroku-cli-util');
let d   = new Date();
console.log(cli.formatDate(d));
// 2001-01-01T08:00:00.000Z
```

## Hush

Use hush for verbose logging when `HEROKU_DEBUG=1`.

```js
let cli = require('heroku-cli-util');
cli.hush('foo');
// only prints if HEROKU_DEBUG is set
```

## Debug

Pretty print an object.

```js
let cli = require('heroku-cli-util');
cli.debug({foo: [1,2,3]});
// { foo: [ 1, 2, 3 ] }
```

## Stylized output

Pretty print a header, hash, and JSON
```js
let cli = require('heroku-cli-util');
cli.styledHeader("MyApp");
cli.styledHash({name: "myapp", collaborators: ["user1@example.com", "user2@example.com"]});
cli.styledJSON({name: "myapp"});
```

Produces

```
=== MyApp
Collaborators: user1@example.com
               user1@example.com
Name:          myapp

{
  "name": "myapp"
}
```

## Table

```js
cli.table([
  {app: 'first-app',  language: 'ruby', dyno_count: 3},
  {app: 'second-app', language: 'node', dyno_count: 2},
], {
  columns: [
    {key: 'app'},
    {key: 'dyno_count', label: 'Dyno Count'},
    {key: 'language', format: language => cli.color.red(language)},
  ]
});
```

Produces:

```
app         Dyno Count  language
──────────  ──────────  ────────
first-app   3           ruby
second-app  2           node
```

## Linewrap

Used to indent output with wrapping around words:

```js
cli.log(cli.linewrap(2, 10, 'this is text is longer than 10 characters'));
// Outputs:
//
// this
// text is
//  longer
//  than 10
//  characters`);
```

Useful with `process.stdout.columns || 80`.

## Open Web Browser

```js
yield cli.open('https://github.com');
```

## HTTP calls

`heroku-cli-util` includes an instance of [got](https://www.npmjs.com/package/got) that will correctly use HTTP proxies.

```js
let cli = require('heroku-cli-util');
let rsp = yield cli.got('https://google.com');
```

## Mocking

Mock stdout and stderr by using `cli.log()` and `cli.error()`.

```js
let cli = require('heroku-cli-util');
cli.log('message 1'); // prints 'message 1'
cli.mockConsole();
cli.log('message 2'); // prints nothing
cli.stdout.should.eq('message 2\n');
```

## Command

Used for initializing a plugin command.
give you an auth'ed instance of `heroku-client` and cleanly handle API exceptions.

It expects you to return a promise chain. This is usually done with [co](https://github.com/tj/co).

```js
let cli = require('heroku-cli-util');
let co  = require('co');
module.exports.commands = [
  {
    topic: 'apps',
    command: 'info',
    needsAuth: true,
    needsApp: true,
    run: cli.command(function (context, heroku) {
      return co(function* () {
        let app = yield heroku.get(`/apps/${context.app}`);
        console.dir(app);
      });
    })
  }
];
```

With options:

```js
let cli = require('heroku-cli-util');
let co  = require('co');
module.exports.commands = [
  {
    topic: 'apps',
    command: 'info',
    needsAuth: true,
    needsApp: true,
    run: cli.command(
      {preauth: true},
      function (context, heroku) {
        return co(function* () {
          let app = yield heroku.get(`/apps/${context.app}`);
          console.dir(app);
        });
      }
    )
  }
];
```

If the command has a `two_factor` API error, it will ask the user for a 2fa code and retry.
If you set `preauth: true` it will preauth against the current app instead of just setting the header on an app. (This is necessary if you need to do more than 1 API call that will require 2fa)

## Tests

```sh
npm install
npm test
```

## License

ISC
