**STRUCT**

# `ApolloSchemaDownloader`

```swift
public struct ApolloSchemaDownloader
```

A wrapper to facilitate downloading a schema with the Apollo node CLI

## Methods
### `run(with:options:)`

```swift
public static func run(with cliFolderURL: URL,
                       options: ApolloSchemaOptions) throws -> String
```

Runs code generation from the given folder with the passed-in options

- Parameters:
  - cliFolderURL: The folder where the Apollo CLI is/should be downloaded.
  - options: The `ApolloSchemaOptions` object to use to download the schema.
- Returns: Output from a successful run

#### Parameters

| Name | Description |
| ---- | ----------- |
| cliFolderURL | The folder where the Apollo CLI is/should be downloaded. |
| options | The `ApolloSchemaOptions` object to use to download the schema. |