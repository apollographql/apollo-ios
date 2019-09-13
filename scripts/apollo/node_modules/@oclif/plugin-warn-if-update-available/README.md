@oclif/plugin-warn-if-update-available
======================================

warns if there is a newer version of CLI released

[![Version](https://img.shields.io/npm/v/@oclif/plugin-warn-if-update-available.svg)](https://npmjs.org/package/@oclif/plugin-warn-if-update-available)
[![CircleCI](https://circleci.com/gh/oclif/plugin-warn-if-update-available/tree/master.svg?style=shield)](https://circleci.com/gh/oclif/plugin-warn-if-update-available/tree/master)
[![Appveyor CI](https://ci.appveyor.com/api/projects/status/github/oclif/plugin-warn-if-update-available?branch=master&svg=true)](https://ci.appveyor.com/project/oclif/plugin-warn-if-update-available/branch/master)
[![Codecov](https://codecov.io/gh/oclif/plugin-warn-if-update-available/branch/master/graph/badge.svg)](https://codecov.io/gh/oclif/plugin-warn-if-update-available)
[![Downloads/week](https://img.shields.io/npm/dw/@oclif/plugin-warn-if-update-available.svg)](https://npmjs.org/package/@oclif/plugin-warn-if-update-available)
[![License](https://img.shields.io/npm/l/@oclif/plugin-warn-if-update-available.svg)](https://github.com/oclif/plugin-warn-if-update-available/blob/master/package.json)

<!-- toc -->
* [What is this?](#what-is-this)
* [How it works](#how-it-works)
* [Installation](#installation)
* [Configuration](#configuration)
<!-- tocstop -->

# What is this?

This plugin shows a warning message if a user is running an out of date CLI.

![screenshot](./assets/screenshot.png)

# How it works

This checks the version against the npm registry asynchronously in a forked process, at most once per 7 days. It then saves a version file to the cache directory that will enable the warning. The upside of this method is that it won't block a user while they're using your CLI—the downside is that it will only display _after_ running a command that fetches the new version.

# Installation

Add the plugin to your project with `yarn add @oclif/plugin-warn-if-update-available`, then add it to the `package.json` of the oclif CLI:

```js
{
  "name": "mycli",
  "version": "0.0.0",
  // ...
  "oclif": {
    "plugins": ["@oclif/plugin-help", "@oclif/plugin-warn-if-update-available"]
  }
}
```

# Configuration

In `package.json`, set `oclif['warn-if-update-available']` to an object with
any of the following configuration properties:

- `timeoutInDays` - Duration between update checks. Defaults to 60.
- `message` - Customize update message.
- `registry` - URL of registry. Defaults to the public npm registry: `https://registry.npmjs.org`
- `authorization` - Authorization header value for registries that require auth.

## Example configuration

```json
{
  "oclif": {
    "plugins": [
      "@oclif/plugin-warn-if-update-available"
    ],
    "warn-if-update-available": {
      "timeoutInDays": 7,
      "message": "<%= config.name %> update available from <%= chalk.greenBright(config.version) %> to <%= chalk.greenBright(latest) %>.",
      "registry": "https://my.example.com/module/registry",
      "authorization": "Basic <SOME READ ONLY AUTH TOKEN>"
    }
  }
}
```
