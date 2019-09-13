# netrc-parser

[![Greenkeeper badge](https://badges.greenkeeper.io/jdxcode/node-netrc-parser.svg)](https://greenkeeper.io/)
[![CircleCI](https://circleci.com/gh/jdxcode/node-netrc-parser/tree/master.svg?style=shield)](https://circleci.com/gh/jdxcode/node-netrc-parser/tree/master)
[![Build status](https://ci.appveyor.com/api/projects/status/vxkkab97cm9lnwb9/branch/master?svg=true)](https://ci.appveyor.com/project/Heroku/node-netrc-parser/branch/master)
[![codecov](https://codecov.io/gh/jdxcode/node-netrc-parser/branch/master/graph/badge.svg)](https://codecov.io/gh/jdxcode/node-netrc-parser)
[![npm](https://img.shields.io/npm/v/netrc-parser.svg)](https://npmjs.org/package/netrc-parser)
[![npm](https://img.shields.io/npm/dw/netrc-parser.svg)](https://npmjs.org/package/netrc-parser)
[![npm](https://img.shields.io/npm/l/netrc-parser.svg)](https://github.com/jdxcode/node-netrc-parser/blob/master/package.json)
[![David](https://img.shields.io/david/jdxcode/node-netrc-parser.svg)](https://david-dm.org/jdxcode/node-netrc-parser)

# API

## Netrc

parses a netrc file

**Examples**

```javascript
const netrc = require('netrc-parser').default
netrc.loadSync() // or netrc.load() for async
netrc.machines['api.heroku.com'].password // get auth token from ~/.netrc
netrc.saveSync() // or netrc.save() for async
```
