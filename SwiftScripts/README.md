# Internal Tooling

```
OVERVIEW: A Swift package that provides functionality for internal tooling and testing.

USAGE: Swift run <subcommand>

SUBCOMMANDS:
  Codegen                 Generate Swift code for the specified targets and package.
  DocumentationGenerator  Generate API reference documentation for apollo-ios.
  SchemaDownload          Download the GraphQL schema from all targets in SDL format.
``` 

## Code Generator

```
OVERVIEW: Generate Swift code for the specified targets and package.

USAGE: codegen [--target <target> ...] --package-type <package-type>

OPTIONS:
  -t, --target <target>   The target to generate code for.
  -p, --package-type <package-type>
                          The package manager for the generated module - Required.
  -h, --help              Show help information.
```

## Documentation Generator

```
OVERVIEW: Generate API reference documentation for apollo-ios.

USAGE: DocumentationGenerator

OPTIONS: None
```

## Schema Download

```
OVERVIEW: Download the GraphQL schema from all targets in SDL format.

USAGE: SchemaDownload

OPTIONS: None
```
