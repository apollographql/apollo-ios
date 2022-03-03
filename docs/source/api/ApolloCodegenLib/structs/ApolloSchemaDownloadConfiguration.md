**STRUCT**

# `ApolloSchemaDownloadConfiguration`

```swift
public struct ApolloSchemaDownloadConfiguration
```

A configuration object that defines behavior for schema download.

## Properties
### `downloadMethod`

```swift
public let downloadMethod: DownloadMethod
```

How to download your schema. Supports the Apollo Registry and GraphQL Introspection methods.

### `downloadTimeout`

```swift
public let downloadTimeout: Double
```

The maximum time to wait before indicating that the download timed out, in seconds. Defaults to 30 seconds.

### `headers`

```swift
public let headers: [HTTPHeader]
```

Any additional headers to include when retrieving your schema. Defaults to nil.

### `outputURL`

```swift
public let outputURL: URL
```

The URL of the folder in which the downloaded schema should be written.

## Methods
### `init(using:timeout:headers:outputFolderURL:schemaFilename:)`

```swift
public init(using downloadMethod: DownloadMethod,
            timeout downloadTimeout: Double = 30.0,
            headers: [HTTPHeader] = [],
            outputFolderURL: URL,
            schemaFilename: String = "schema")
```

Designated Initializer

- Parameters:
  - downloadMethod: How to download your schema.
  - downloadTimeout: The maximum time to wait before indicating that the download timed out, in seconds. Defaults to 30 seconds.
  - headers: [optional] Any additional headers to include when retrieving your schema. Defaults to nil
  - outputFolderURL: The URL of the folder in which the downloaded schema should be written
  - schemaFilename: The name, without an extension, for your schema file. Defaults to `"schema"

#### Parameters

| Name | Description |
| ---- | ----------- |
| downloadMethod | How to download your schema. |
| downloadTimeout | The maximum time to wait before indicating that the download timed out, in seconds. Defaults to 30 seconds. |
| headers | [optional] Any additional headers to include when retrieving your schema. Defaults to nil |
| outputFolderURL | The URL of the folder in which the downloaded schema should be written |
| schemaFilename | The name, without an extension, for your schema file. Defaults to `“schema” |