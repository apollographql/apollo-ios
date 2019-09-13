@oclif/command
===============

oclif base command

[![Version](https://img.shields.io/npm/v/@oclif/command.svg)](https://npmjs.org/package/@oclif/command)
[![CircleCI](https://circleci.com/gh/oclif/command/tree/master.svg?style=shield)](https://circleci.com/gh/oclif/command/tree/master)
[![Appveyor CI](https://ci.appveyor.com/api/projects/status/github/oclif/command?branch=master&svg=true)](https://ci.appveyor.com/project/heroku/command/branch/master)
[![Codecov](https://codecov.io/gh/oclif/command/branch/master/graph/badge.svg)](https://codecov.io/gh/oclif/command)
[![Known Vulnerabilities](https://snyk.io/test/npm/@oclif/command/badge.svg)](https://snyk.io/test/npm/@oclif/command)
[![Downloads/week](https://img.shields.io/npm/dw/@oclif/command.svg)](https://npmjs.org/package/@oclif/command)
[![License](https://img.shields.io/npm/l/@oclif/command.svg)](https://github.com/oclif/command/blob/master/package.json)

This is about half of the main codebase for oclif. The other half lives in [@oclif/config](https://github.com/oclif/config). This can be used directly, but it probably makes more sense to build your CLI with the [generator](https://github.com/oclif/oclif).

Usage
=====

Without the generator, you can create a simple CLI like this:

**TypeScript**
```js
#!/usr/bin/env ts-node

import * as fs from 'fs'
import {Command, flags} from '@oclif/command'

class LS extends Command {
  static flags = {
    version: flags.version(),
    help: flags.help(),
    // run with --dir= or -d=
    dir: flags.string({
      char: 'd',
      default: process.cwd(),
    }),
  }

  async run() {
    const {flags} = this.parse(LS)
    let files = fs.readdirSync(flags.dir)
    for (let f of files) {
      this.log(f)
    }
  }
}

LS.run()
.catch(require('@oclif/errors/handle'))
```

**JavaScript**
```js
#!/usr/bin/env node

const fs = require('fs')
const {Command, flags} = require('@oclif/command')

class LS extends Command {
  async run() {
    const {flags} = this.parse(LS)
    let files = fs.readdirSync(flags.dir)
    for (let f of files) {
      this.log(f)
    }
  }
}

LS.flags = {
  version: flags.version(),
  help: flags.help(),
  // run with --dir= or -d=
  dir: flags.string({
    char: 'd',
    default: process.cwd(),
  }),
}

LS.run()
.catch(require('@oclif/errors/handle'))
```

Then run either of these with:

```sh-session
$ ./myscript
...files in current dir...
$ ./myscript --dir foobar
...files in ./foobar...
$ ./myscript --version
myscript/0.0.0 darwin-x64 node-v9.5.0
$ ./myscript --help
USAGE
  $ @oclif/command

OPTIONS
  -d, --dir=dir  [default: /Users/jdickey/src/github.com/oclif/command]
  --help         show CLI help
  --version      show CLI version
```

See the [generator](https://github.com/oclif/oclif) for all the options you can pass to the command.
