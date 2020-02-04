**STRUCT**

# `ApolloSchemaDownloader`

```swift
public struct ApolloSchemaDownloader
```

> A wrapper to facilitate downloading a schema with the Apollo node CLI

## Methods
### `run(from:binaryFolderURL:options:)`

```swift
public static func run(from folder: URL,
                       binaryFolderURL: URL,
                       options: ApolloSchemaOptions) throws -> String
```

> Runs code generation from the given folder with the passed-in options
>
> - Parameter folder: The folder to run the script from
> - Parameter binaryFolderURL: The folder where the Apollo binaries have been unzipped.
> - Parameter options: The options object to use to download the schema.

#### Parameters

| Name | Description |
| ---- | ----------- |
| folder | The folder to run the script from |
| binaryFolderURL | The folder where the Apollo binaries have been unzipped. |
| options | The options object to use to download the schema. |