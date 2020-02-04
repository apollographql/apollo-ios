**STRUCT**

# `ApolloSchemaOptions`

```swift
public struct ApolloSchemaOptions
```

> Options for running the Apollo Schema Downloader.

## Properties
### `apiKey`

```swift
public let apiKey: String?
```

### `endpointURL`

```swift
public let endpointURL: URL
```

### `header`

```swift
public let header: String?
```

### `outputURL`

```swift
public let outputURL: URL
```

## Methods
### `init(apiKey:endpointURL:header:outputURL:)`

```swift
public init(apiKey: String? = nil,
            endpointURL: URL,
            header: String? = nil,
            outputURL: URL)
```

> Designated Initializer
>
> - Parameter apiKey: [optional] The API key to use when retrieving your schema. Defaults to nil.
> - Parameter endpointURL: The endpoint to hit to download your schema.
> - Parameter header: [optional] Any additional headers to include when retrieving your schema. Defaults to nil
> - Parameter outputURL: The file URL where the downloaded schema should be written

#### Parameters

| Name | Description |
| ---- | ----------- |
| apiKey | [optional] The API key to use when retrieving your schema. Defaults to nil. |
| endpointURL | The endpoint to hit to download your schema. |
| header | [optional] Any additional headers to include when retrieving your schema. Defaults to nil |
| outputURL | The file URL where the downloaded schema should be written |