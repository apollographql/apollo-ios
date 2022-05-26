# CodegenCLI

```
OVERVIEW: A command line utility for Apollo iOS code generation.

USAGE: apollo-ios-codegen <subcommand>

OPTIONS:
  --version               Show the version.
  -h, --help              Show help information.

SUBCOMMANDS:
  init                    Initialize a new configuration with defaults.
  validate                Validate a configuration file or JSON formatted string.
  generate                Generate Swift source code based on a code generation configuration.

  See 'apollo-ios-codegen help <subcommand>' for detailed help.
```

## Initialize
```
OVERVIEW: Initialize a new configuration with defaults.

USAGE: apollo-ios-codegen init [--output <output>] [--path <path>] [--overwrite]

OPTIONS:
  -o, --output <output>   Destination for the new configuration. (default: file)
  -p, --path <path>       Write the configuration to a file at the path. (default: ./apollo-codegen-config.json)
  -w, --overwrite         Overwrite any file at --path.
  --version               Show the version.
  -h, --help              Show help information.
```

## Validate
```
OVERVIEW: Validate a configuration file or JSON formatted string.

USAGE: apollo-ios-codegen validate --input <input> [--path <path>] [--string <string>]

OPTIONS:
  -i, --input <input>     Configuration source.
  -p, --path <path>       Read the configuration from a file at the path.
  -s, --string <string>   Configuration string in JSON format.
  --version               Show the version.
  -h, --help              Show help information.
```

## Generate
```
OVERVIEW: Generate Swift source code based on a code generation configuration.

USAGE: apollo-ios-codegen generate [--input <input>] [--path <path>] [--string <string>]

OPTIONS:
  -i, --input <input>     Configuration source. (default: file)
  -p, --path <path>       Read the configuration from a file at the path. (default: ./apollo-codegen-config.json)
  -s, --string <string>   Configuration string in JSON format.
  --version               Show the version.
  -h, --help              Show help information.
```