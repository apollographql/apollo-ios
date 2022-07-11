**STRUCT**

# `ApolloCodegenConfiguration.FileInput`

```swift
public struct FileInput: Codable, Equatable
```

The input paths and files required for code generation.

## Properties
### `schemaSearchPaths`

```swift
public let schemaSearchPaths: [String]
```

An array of path matching pattern strings used to find GraphQL schema
files to be included for code generation.

Schema files may contain only spec-compliant
[`TypeSystemDocument`](https://spec.graphql.org/draft/#sec-Type-System) or
[`TypeSystemExtension`](https://spec.graphql.org/draft/#sec-Type-System-Extensions)
definitions in SDL or JSON format.
This includes:
  - [Schema Definitions](https://spec.graphql.org/draft/#SchemaDefinition)
  - [Type Definitions](https://spec.graphql.org/draft/#TypeDefinition)
  - [Directive Definitions](https://spec.graphql.org/draft/#DirectiveDefinition)
  - [Schema Extensions](https://spec.graphql.org/draft/#SchemaExtension)
  - [Type Extensions](https://spec.graphql.org/draft/#TypeExtension)

You can use absolute or relative paths in path matching patterns. Relative paths will be
based off the current working directory from `FileManager`.

Each path matching pattern can include the following characters:
 - `*` matches everything but the directory separator (shallow), eg: `*.graphql`
 - `?` matches any single character, eg: `file-?.graphql`
 - `**` matches all subdirectories (deep), eg: `**/*.graphql`
 - `!` excludes any match only if the pattern starts with a `!` character, eg: `!file.graphql`

- Precondition: JSON format schema files must have the file extension ".json".
When using a JSON format schema file, only a single JSON schema can be provided with any
number of additional SDL schema extension files.

### `operationSearchPaths`

```swift
public let operationSearchPaths: [String]
```

An array of path matching pattern strings used to find GraphQL
operation files to be included for code generation.

 Operation files may contain only spec-compliant
 [`ExecutableDocument`](https://spec.graphql.org/draft/#ExecutableDocument)
 definitions in SDL format.
 This includes:
   - [Operation Definitions](https://spec.graphql.org/draft/#sec-Language.Operations)
   (ie. `query`, `mutation`, or `subscription`)
   - [Fragment Definitions](https://spec.graphql.org/draft/#sec-Language.Fragments)

You can use absolute or relative paths in path matching patterns. Relative paths will be
based off the current working directory from `FileManager`.

Each path matching pattern can include the following characters:
 - `*` matches everything but the directory separator (shallow), eg: `*.graphql`
 - `?` matches any single character, eg: `file-?.graphql`
 - `**` matches all subdirectories (deep), eg: `**/*.graphql`
 - `!` excludes any match only if the pattern starts with a `!` character, eg: `!file.graphql`

## Methods
### `init(schemaSearchPaths:operationSearchPaths:)`

```swift
public init(
  schemaSearchPaths: [String] = ["**/*.graphqls"],
  operationSearchPaths: [String] = ["**/*.graphql"]
)
```

Designated initializer.

- Parameters:
  - schemaSearchPaths: An array of path matching pattern strings used to find GraphQL schema
  files to be included for code generation.
  Schema files may contain only spec-compliant
  [`TypeSystemDocument`](https://spec.graphql.org/draft/#sec-Type-System) or
  [`TypeSystemExtension`](https://spec.graphql.org/draft/#sec-Type-System-Extensions)
  definitions in SDL or JSON format.
  This includes:
    - [Schema Definitions](https://spec.graphql.org/draft/#SchemaDefinition)
    - [Type Definitions](https://spec.graphql.org/draft/#TypeDefinition)
    - [Directive Definitions](https://spec.graphql.org/draft/#DirectiveDefinition)
    - [Schema Extensions](https://spec.graphql.org/draft/#SchemaExtension)
    - [Type Extensions](https://spec.graphql.org/draft/#TypeExtension)

    Defaults to `["**/*.graphqls"]`.

  - operationSearchPaths: An array of path matching pattern strings used to find GraphQL
  operation files to be included for code generation.
  Operation files may contain only spec-compliant
  [`ExecutableDocument`](https://spec.graphql.org/draft/#ExecutableDocument)
  definitions in SDL format.
  This includes:
    - [Operation Definitions](https://spec.graphql.org/draft/#sec-Language.Operations)
    (ie. `query`, `mutation`, or `subscription`)
    - [Fragment Definitions](https://spec.graphql.org/draft/#sec-Language.Fragments)

    Defaults to `["**/*.graphql"]`.

 You can use absolute or relative paths in path matching patterns. Relative paths will be
 based off the current working directory from `FileManager`.

 Each path matching pattern can include the following characters:
  - `*` matches everything but the directory separator (shallow), eg: `*.graphql`
  - `?` matches any single character, eg: `file-?.graphql`
  - `**` matches all subdirectories (deep), eg: `**/*.graphql`
  - `!` excludes any match only if the pattern starts with a `!` character, eg: `!file.graphql`

- Precondition: JSON format schema files must have the file extension ".json".
When using a JSON format schema file, only a single JSON schema can be provided with any
number of additional SDL schema extension files.

#### Parameters

| Name | Description |
| ---- | ----------- |
| schemaSearchPaths | An array of path matching pattern strings used to find GraphQL schema files to be included for code generation. Schema files may contain only spec-compliant  or  definitions in SDL or JSON format. This includes: Defaults to `["**/*.graphqls"]`. |
| operationSearchPaths | An array of path matching pattern strings used to find GraphQL operation files to be included for code generation. Operation files may contain only spec-compliant  definitions in SDL format. This includes: Defaults to `["**/*.graphql"]`. |

### `init(schemaPath:operationSearchPaths:)`

```swift
public init(
  schemaPath: String,
  operationSearchPaths: [String] = ["**/*.graphql"]
)
```

Convenience initializer.

- Parameters:
  - schemaPath: The path to a local GraphQL schema file to be used for code generation.
  Schema files may contain only spec-compliant
  [`TypeSystemDocument`](https://spec.graphql.org/draft/#sec-Type-System) or
  [`TypeSystemExtension`](https://spec.graphql.org/draft/#sec-Type-System-Extensions)
  definitions in SDL or JSON format.
  This includes:
    - [Schema Definitions](https://spec.graphql.org/draft/#SchemaDefinition)
    - [Type Definitions](https://spec.graphql.org/draft/#TypeDefinition)
    - [Directive Definitions](https://spec.graphql.org/draft/#DirectiveDefinition)
    - [Schema Extensions](https://spec.graphql.org/draft/#SchemaExtension)
    - [Type Extensions](https://spec.graphql.org/draft/#TypeExtension)

  - operationSearchPaths: An array of path matching pattern strings used to find GraphQL
  operation files to be included for code generation.
  Operation files may contain only spec-compliant
  [`ExecutableDocument`](https://spec.graphql.org/draft/#ExecutableDocument)
  definitions in SDL format.
  This includes:
    - [Operation Definitions](https://spec.graphql.org/draft/#sec-Language.Operations)
    (ie. `query`, `mutation`, or `subscription`)
    - [Fragment Definitions](https://spec.graphql.org/draft/#sec-Language.Fragments)

    Defaults to `["**/*.graphql"]`.

 You can use absolute or relative paths in path matching patterns. Relative paths will be
 based off the current working directory from `FileManager`.

 Each path matching pattern can include the following characters:
  - `*` matches everything but the directory separator (shallow), eg: `*.graphql`
  - `?` matches any single character, eg: `file-?.graphql`
  - `**` matches all subdirectories (deep), eg: `**/*.graphql`
  - `!` excludes any match only if the pattern starts with a `!` character, eg: `!file.graphql`

- Precondition: JSON format schema files must have the file extension ".json".
When using a JSON format schema file, only a single JSON schema can be provided with any
number of additional SDL schema extension files.

#### Parameters

| Name | Description |
| ---- | ----------- |
| schemaPath | The path to a local GraphQL schema file to be used for code generation. Schema files may contain only spec-compliant  or  definitions in SDL or JSON format. This includes: |
| operationSearchPaths | An array of path matching pattern strings used to find GraphQL operation files to be included for code generation. Operation files may contain only spec-compliant  definitions in SDL format. This includes: Defaults to `["**/*.graphql"]`. |