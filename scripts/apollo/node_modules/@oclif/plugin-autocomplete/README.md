@oclif/plugin-autocomplete
==========================

autocomplete plugin for oclif (bash & zsh)

[![Version](https://img.shields.io/npm/v/@oclif/plugin-autocomplete.svg)](https://npmjs.org/package/@oclif/plugin-autocomplete)
[![CircleCI](https://circleci.com/gh/oclif/plugin-autocomplete/tree/master.svg?style=shield)](https://circleci.com/gh/oclif/plugin-autocomplete/tree/master)
[![Appveyor CI](https://ci.appveyor.com/api/projects/status/github/oclif/plugin-autocomplete?branch=master&svg=true)](https://ci.appveyor.com/project/oclif/plugin-autocomplete/branch/master)
[![Codecov](https://codecov.io/gh/oclif/plugin-autocomplete/branch/master/graph/badge.svg)](https://codecov.io/gh/oclif/plugin-autocomplete)
[![Downloads/week](https://img.shields.io/npm/dw/@oclif/plugin-autocomplete.svg)](https://npmjs.org/package/@oclif/plugin-autocomplete)
[![License](https://img.shields.io/npm/l/@oclif/plugin-autocomplete.svg)](https://github.com/oclif/plugin-autocomplete/blob/master/package.json)

<!-- toc -->
* [Usage](#usage)
* [Commands](#commands)
<!-- tocstop -->
# Usage
See https://oclif.io/docs/plugins.html
# Commands
<!-- commands -->
* [`oclif-example autocomplete [SHELL]`](#oclif-example-autocomplete-shell)

## `oclif-example autocomplete [SHELL]`

display autocomplete installation instructions

```
USAGE
  $ oclif-example autocomplete [SHELL]

ARGUMENTS
  SHELL  shell type

OPTIONS
  -r, --refresh-cache  Refresh cache (ignores displaying instructions)

EXAMPLES
  $ oclif-example autocomplete
  $ oclif-example autocomplete bash
  $ oclif-example autocomplete zsh
  $ oclif-example autocomplete --refresh-cache
```

_See code: [src/commands/autocomplete/index.ts](https://github.com/oclif/plugin-autocomplete/blob/v0.1.3/src/commands/autocomplete/index.ts)_
<!-- commandsstop -->
