# Apollo iOS CLI

```
OVERVIEW: A command line utility for Apollo iOS code generation.

USAGE: apollo-ios-cli <subcommand>

OPTIONS:
  --version               Show the version.
  -h, --help              Show help information.

SUBCOMMANDS:
  init                    Initialize a new configuration with defaults.
  generate                Generate Swift source code based on a code generation configuration.
  fetch-schema            Download a GraphQL schema from the Apollo Registry or GraphQL introspection.
  generate-operation-manifest
                          Generate Persisted Queries operation manifest based on a code generation configuration.

  See 'apollo-ios-cli help <subcommand>' for detailed help.
```

## Initialize
```
OVERVIEW: Initialize a new configuration with defaults.

USAGE: apollo-ios-cli init --schema-namespace <schema-namespace> --module-type <module-type> [--target-name <target-name>] [--path <path>] [--overwrite] [--print]

OPTIONS:
  --schema-name <schema-name>
                          DEPRECATED - Use --schema-namespace instead.
  -n, --schema-namespace <schema-namespace>
                          Name used to scope the generated schema type files.
  -m, --module-type <module-type>
                          How to package the schema types for dependency management. Possible types: embeddedInTarget, 
                          swiftPackageManager, other.
  -t, --target-name <target-name>
                          Name of the target in which the schema types files will be manually embedded. This is required
                          for the "embeddedInTarget" module type and will be ignored for all other module types.
  -p, --path <path>       Write the configuration to a file at the path. (default: ./apollo-codegen-config.json)
  -w, --overwrite         Overwrite any file at --path. If init is called without --overwrite and a config file already 
                          exists at --path, the command will fail.
  -s, --print             Print the configuration to stdout.
  --version               Show the version.
  -h, --help              Show help information.
```

## Generate
```
OVERVIEW: Generate Swift source code based on a code generation configuration.

USAGE: apollo-ios-cli generate [--path <path>] [--string <string>] [--verbose] [--fetch-schema] [--ignore-version-mismatch]

OPTIONS:
  -p, --path <path>       Read the configuration from a file at the path. --string overrides this option if used 
                          together. (default: ./apollo-codegen-config.json)
  -s, --string <string>   Configuration string in JSON format. This option overrides --path.
  -v, --verbose           Increase verbosity to include debug output.
  -f, --fetch-schema      Fetch the GraphQL schema before Swift code generation.
  --ignore-version-mismatch
                          Ignore Apollo version mismatch errors. Warning: This may lead to incompatible generated 
                          objects.
  --version               Show the version.
  -h, --help              Show help information.
```

## Fetch Schema
```
OVERVIEW: Download a GraphQL schema from the Apollo Registry or GraphQL introspection.

USAGE: apollo-ios-cli fetch-schema [--path <path>] [--string <string>] [--verbose]

OPTIONS:
  -p, --path <path>       Read the configuration from a file at the path. --string overrides this option if used 
                          together. (default: ./apollo-codegen-config.json)
  -s, --string <string>   Configuration string in JSON format. This option overrides --path.
  -v, --verbose           Increase verbosity to include debug output.
  --version               Show the version.
  -h, --help              Show help information.
```
## Generate Operation Manifest
```
OVERVIEW: Generate Persisted Queries operation manifest based on a code generation configuration.

USAGE: apollo-ios-cli generate-operation-manifest [--path <path>] [--string <string>] [--verbose] [--ignore-version-mismatch]

OPTIONS:
  -p, --path <path>       Read the configuration from a file at the path. --string overrides this option if used together. (default: ./apollo-codegen-config.json)
  -s, --string <string>   Configuration string in JSON format. This option overrides --path.
  -v, --verbose           Increase verbosity to include debug output.
  --ignore-version-mismatch
                          Ignore Apollo version mismatch errors. Warning: This may lead to incompatible generated objects.
  --version               Show the version.
  -h, --help              Show help information.
```