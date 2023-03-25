**STRUCT**

# `ApolloCodegenConfiguration`

```swift
public struct ApolloCodegenConfiguration: Codable, Equatable
```

A configuration object that defines behavior for code generation.

## Properties
### `schemaNamespace`

```swift
public let schemaNamespace: String
```

Name used to scope the generated schema type files.

### `input`

```swift
public let input: FileInput
```

The input files required for code generation.

### `output`

```swift
public let output: FileOutput
```

The paths and files output by code generation.

### `options`

```swift
public let options: OutputOptions
```

Rules and options to customize the generated code.

### `experimentalFeatures`

```swift
public let experimentalFeatures: ExperimentalFeatures
```

Allows users to enable experimental features.

Note: These features could change at any time and they are not guaranteed to always be
available.

### `schemaDownloadConfiguration`

```swift
public let schemaDownloadConfiguration: ApolloSchemaDownloadConfiguration?
```

Schema download configuration.

## Methods
### `init(schemaNamespace:input:output:options:experimentalFeatures:schemaDownloadConfiguration:)`

```swift
public init(
  schemaNamespace: String,
  input: FileInput,
  output: FileOutput,
  options: OutputOptions = OutputOptions(),
  experimentalFeatures: ExperimentalFeatures = ExperimentalFeatures(),
  schemaDownloadConfiguration: ApolloSchemaDownloadConfiguration? = nil
)
```

Designated initializer.

- Parameters:
 - schemaNamespace: Name used to scope the generated schema type files.
 - input: The input files required for code generation.
 - output: The paths and files output by code generation.
 - options: Rules and options to customize the generated code.
 - experimentalFeatures: Allows users to enable experimental features.
