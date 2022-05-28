# Apollo iOS CLI

```
OVERVIEW: A command line utility for Apollo iOS code generation.

USAGE: apollo-ios-cli <subcommand>

OPTIONS:
  --version               Show the version.
  -h, --help              Show help information.

SUBCOMMANDS:
  init                    Initialize a new configuration with defaults.
  validate                Validate a configuration file or JSON formatted string.
  generate                Generate Swift source code based on a code generation configuration.

  See 'apollo-ios-cli help <subcommand>' for detailed help.
```

## Initialize
```
OVERVIEW: Initialize a new configuration with defaults.

USAGE: apollo-ios-cli init [--path <path>] [--overwrite] [--print]

OPTIONS:
  -p, --path <path>       Write the configuration to a file at the path. (default: ./apollo-codegen-config.json)
  -w, --overwrite         Overwrite any file at --path. If init is called without --overwrite and a config file already
                          exists at --path, the command will fail.
  -s, --print             Print the configuration to stdout.
  --version               Show the version.
  -h, --help              Show help information.
```

## Validate
```
OVERVIEW: Validate a configuration file or JSON formatted string.

USAGE: apollo-ios-cli validate [--path <path>] [--string <string>]

OPTIONS:
  -p, --path <path>       Read the configuration from a file at the path.
  -s, --string <string>   Configuration string in JSON format.
  --version               Show the version.
  -h, --help              Show help information.
```

## Generate
```
OVERVIEW: Generate Swift source code based on a code generation configuration.

USAGE: apollo-ios-cli generate [--path <path>] [--string <string>]

OPTIONS:
  -p, --path <path>       Read the configuration from a file at the path. (default: ./apollo-codegen-config.json)
  -s, --string <string>   Configuration string in JSON format.
  --version               Show the version.
  -h, --help              Show help information.
```
