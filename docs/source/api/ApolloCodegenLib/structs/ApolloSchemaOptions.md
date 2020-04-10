**STRUCT**

# `ApolloSchemaOptions`

```swift
public struct ApolloSchemaOptions
```

> Options for running the Apollo Schema Downloader.

## Methods
### `init(schemaFileName:schemaFileType:apiKey:endpointURL:header:outputFolderURL:downloadTimeout:)`

```swift
public init(schemaFileName: String = "schema",
            schemaFileType: SchemaFileType = .json,
            apiKey: String? = nil,
            endpointURL: URL,
            header: String? = nil,
            outputFolderURL: URL,
            downloadTimeout: Double = 30.0)
```

> Designated Initializer
>
> - Parameters:
>   - schemaFileName: The name, without an extension, for your schema file. Defaults to `"schema"`
>   - schemaFileType: The `SchemaFileType` to download the schema as. Defaults to `.json`.
>   - apiKey: [optional] The API key to use when retrieving your schema. Defaults to nil.
>   - endpointURL: The endpoint to hit to download your schema.
>   - header: [optional] Any additional headers to include when retrieving your schema. Defaults to nil
>   - outputFolderURL: The URL of the folder in which the downloaded schema should be written
>  - downloadTimeout: The maximum time to wait before indicating that the download timed out, in seconds. Defaults to 30 seconds.

#### Parameters

| Name | Description |
| ---- | ----------- |
| schemaFileName | The name, without an extension, for your schema file. Defaults to `"schema"` |
| schemaFileType | The `SchemaFileType` to download the schema as. Defaults to `.json`. |
| apiKey | [optional] The API key to use when retrieving your schema. Defaults to nil. |
| endpointURL | The endpoint to hit to download your schema. |
| header | [optional] Any additional headers to include when retrieving your schema. Defaults to nil |
| outputFolderURL | The URL of the folder in which the downloaded schema should be written |