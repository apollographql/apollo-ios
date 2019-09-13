http-call
=========

[![Greenkeeper badge](https://badges.greenkeeper.io/heroku/http-call.svg)](https://greenkeeper.io/)

Usage
-----

```js
const {HTTP} = require('http-call')
const {body: user} = await HTTP.get('https://api.github.com/users/me')
// do something with user
// automatically converts from json

// for typescript specify the type of the body with a generic:
const {body: user} = await HTTP.get<{id: string, email: string}>('https://api.github.com/users/me')

// set headers
await HTTP.get('https://api.github.com', {headers: {authorization: 'bearer auth'}})
```
