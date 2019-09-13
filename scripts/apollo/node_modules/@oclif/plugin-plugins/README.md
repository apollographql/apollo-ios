@oclif/plugin-plugins
=====================

plugins plugin for oclif

[![Version](https://img.shields.io/npm/v/@oclif/plugin-plugins.svg)](https://npmjs.org/package/@oclif/plugin-plugins)
[![CircleCI](https://circleci.com/gh/oclif/plugin-plugins/tree/master.svg?style=shield)](https://circleci.com/gh/oclif/plugin-plugins/tree/master)
[![Appveyor CI](https://ci.appveyor.com/api/projects/status/github/oclif/plugin-plugins?branch=master&svg=true)](https://ci.appveyor.com/project/oclif/plugin-plugins/branch/master)
[![Codecov](https://codecov.io/gh/oclif/plugin-plugins/branch/master/graph/badge.svg)](https://codecov.io/gh/oclif/plugin-plugins)
[![Known Vulnerabilities](https://snyk.io/test/github/oclif/plugin-plugins/badge.svg)](https://snyk.io/test/github/oclif/plugin-plugins)
[![Downloads/week](https://img.shields.io/npm/dw/@oclif/plugin-plugins.svg)](https://npmjs.org/package/@oclif/plugin-plugins)
[![License](https://img.shields.io/npm/l/@oclif/plugin-plugins.svg)](https://github.com/oclif/plugin-plugins/blob/master/package.json)

<!-- toc -->
* [What is this?](#what-is-this)
* [Usage](#usage)
* [Friendly names](#friendly-names)
* [Aliases/Blacklist](#aliasesblacklist)
* [Commands](#commands)
<!-- tocstop -->

# What is this?

This plugin is used to allow users to install plugins into your oclif CLI at runtime. For example, in the Heroku CLI this is used to allow people to install plugins such as the Heroku Kafka plugin:

```sh-session
$ heroku plugins:install heroku-kafka
$ heroku kafka
```

This is useful to allow users to create their own plugins to work in your CLI or to allow you to build functionality that users can optionally install.

One particular way this is useful is for building functionality you aren't ready to include in a public repository. Build your plugin separately as a plugin, then include it as a core plugin later into your CLI.

# Usage

First add the plugin to your project with `yarn add @oclif/plugin-plugins`, then add it to the `package.json` of the oclif CLI:

```js
{
  "name": "mycli",
  "version": "0.0.0",
  // ...
  "oclif": {
    "plugins": ["@oclif/plugin-help", "@oclif/plugin-plugins"]
  }
}
```

Now the user can run any of the commands below to manage plugins at runtime.

# Friendly names

To make it simpler for users to install plugins, we have "friendly name" functionality. With this, you can run `mycli plugins:install myplugin` and it will first check if `@mynpmorg/plugin-myplugin` exists on npm before trying to install `myplugin`. This is useful if you want to use a generic name that's already taken in npm.

To set this up, simply set the `oclif.scope` to the name of your npm org. In the example above, this would be `mynpmorg`.

# Aliases/Blacklist

Over time in the Heroku CLI we've changed plugin names, brought plugins into the core of the CLI, or sunset old plugins that no longer function. There is support in this plugin for dealing with these situations.

For renaming plugins, add an alias section to `oclif.aliases` in `package.json`:

```json
"aliases": {
  "old-name-plugin": "new-name-plugin"
}
```

If a user had `old-name-plugin` installed, the next time the CLI is updated it will remove `old-name-plugin` and install `new-name-plugin`. If a user types `mycli plugins:install old-name-plugin` it will actually install `new-name-plugin` instead.

For removing plugins that are no longer needed (either because they're sunset or because they've been moved into core), set the alias to null:

```json
"aliases": {
  "old-name-plugin": null
}
```

`old-name-plugin` will be autoremoved on the next update and will not be able to be installed with `mycli plugins:install old-name-plugin`.

# Commands
<!-- commands -->
* [`mycli plugins`](#mycli-plugins)
* [`mycli plugins:install PLUGIN...`](#mycli-pluginsinstall-plugin)
* [`mycli plugins:link PLUGIN`](#mycli-pluginslink-plugin)
* [`mycli plugins:uninstall PLUGIN...`](#mycli-pluginsuninstall-plugin)
* [`mycli plugins:update`](#mycli-pluginsupdate)

## `mycli plugins`

list installed plugins

```
USAGE
  $ mycli plugins

OPTIONS
  --core  show core plugins

EXAMPLE
  $ mycli plugins
```

_See code: [src/commands/plugins/index.ts](https://github.com/oclif/plugin-plugins/blob/v1.7.8/src/commands/plugins/index.ts)_

## `mycli plugins:install PLUGIN...`

installs a plugin into the CLI

```
USAGE
  $ mycli plugins:install PLUGIN...

ARGUMENTS
  PLUGIN  plugin to install

OPTIONS
  -f, --force    yarn install with force flag
  -h, --help     show CLI help
  -v, --verbose

DESCRIPTION
  Can be installed from npm or a git url.

  Installation of a user-installed plugin will override a core plugin.

  e.g. If you have a core plugin that has a 'hello' command, installing a user-installed plugin with a 'hello' command 
  will override the core plugin implementation. This is useful if a user needs to update core plugin functionality in 
  the CLI without the need to patch and update the whole CLI.

ALIASES
  $ mycli plugins:add

EXAMPLES
  $ mycli plugins:install myplugin 
  $ mycli plugins:install https://github.com/someuser/someplugin
  $ mycli plugins:install someuser/someplugin
```

_See code: [src/commands/plugins/install.ts](https://github.com/oclif/plugin-plugins/blob/v1.7.8/src/commands/plugins/install.ts)_

## `mycli plugins:link PLUGIN`

links a plugin into the CLI for development

```
USAGE
  $ mycli plugins:link PLUGIN

ARGUMENTS
  PATH  [default: .] path to plugin

OPTIONS
  -h, --help     show CLI help
  -v, --verbose

DESCRIPTION
  Installation of a linked plugin will override a user-installed or core plugin.

  e.g. If you have a user-installed or core plugin that has a 'hello' command, installing a linked plugin with a 'hello' 
  command will override the user-installed or core plugin implementation. This is useful for development work.

EXAMPLE
  $ mycli plugins:link myplugin
```

_See code: [src/commands/plugins/link.ts](https://github.com/oclif/plugin-plugins/blob/v1.7.8/src/commands/plugins/link.ts)_

## `mycli plugins:uninstall PLUGIN...`

removes a plugin from the CLI

```
USAGE
  $ mycli plugins:uninstall PLUGIN...

ARGUMENTS
  PLUGIN  plugin to uninstall

OPTIONS
  -h, --help     show CLI help
  -v, --verbose

ALIASES
  $ mycli plugins:unlink
  $ mycli plugins:remove
```

_See code: [src/commands/plugins/uninstall.ts](https://github.com/oclif/plugin-plugins/blob/v1.7.8/src/commands/plugins/uninstall.ts)_

## `mycli plugins:update`

update installed plugins

```
USAGE
  $ mycli plugins:update

OPTIONS
  -h, --help     show CLI help
  -v, --verbose
```

_See code: [src/commands/plugins/update.ts](https://github.com/oclif/plugin-plugins/blob/v1.7.8/src/commands/plugins/update.ts)_
<!-- commandsstop -->
