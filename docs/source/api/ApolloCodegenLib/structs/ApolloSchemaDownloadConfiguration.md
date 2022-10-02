**STRUCT**

# `ApolloSchemaDownloadConfiguration`

```swift
public struct ApolloSchemaDownloadConfiguration: Equatable, Codable
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

The maximum time (in seconds) to wait before indicating that the download timed out.
Defaults to 30 seconds.

### `headers`

```swift
public let headers: [HTTPHeader]
```

Any additional headers to include when retrieving your schema. Defaults to nil.

### `outputPath`

```swift
public let outputPath: String
```

The local path where the downloaded schema should be written to.

### `outputFormat`

```swift
public var outputFormat: DownloadMethod.OutputFormat
```

## Methods
### `init(using:timeout:headers:outputPath:)`

```swift
public init(
  using downloadMethod: DownloadMethod,
  timeout downloadTimeout: Double = 30.0,
  headers: [HTTPHeader] = [],
  outputPath: String
)
```

Designated Initializer

- Parameters:
  - downloadMethod: How to download your schema.
  - downloadTimeout: The maximum time (in seconds) to wait before indicating that the
  download timed out. Defaults to 30 seconds.
  - headers: [optional] Any additional headers to include when retrieving your schema.
  Defaults to nil
  - outputPath: The local path where the downloaded schema should be written to.

#### Parameters

| Name | Description |
| ---- | ----------- |
| downloadMethod | How to download your schema. |
| downloadTimeout | The maximum time (in seconds) to wait before indicating that the download timed out. Defaults to 30 seconds. |
| headers | [optional] Any additional headers to include when retrieving your schema. Defaults to nil |
| outputPath | The local path where the downloaded schema should be written to. |