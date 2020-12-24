**CLASS**

# `HTTPResponse`

```swift
public class HTTPResponse<Operation: GraphQLOperation>
```

Data about a response received by an HTTP request.

## Properties
### `httpResponse`

```swift
public var httpResponse: HTTPURLResponse
```

The `HTTPURLResponse` received from the URL loading system

### `rawData`

```swift
public var rawData: Data
```

The raw data received from the URL loading system

### `parsedResponse`

```swift
public var parsedResponse: GraphQLResult<Operation.Data>?
```

[optional] The data as parsed into a `GraphQLResult`, which can eventually be returned to the UI. Will be nil if not yet parsed.

### `legacyResponse`

```swift
public var legacyResponse: GraphQLResponse<Operation.Data>? = nil
```

[optional] The data as parsed into a `GraphQLResponse` for legacy caching purposes. If you're not using the `LegacyParsingInterceptor`, you probably shouldn't be using this property.
**NOTE:** This property will be removed when the transition to a Codable-based Codegen is complete.

## Methods
### `init(response:rawData:parsedResponse:)`

```swift
public init(response: HTTPURLResponse,
            rawData: Data,
            parsedResponse: GraphQLResult<Operation.Data>?)
```

Designated initializer

- Parameters:
  - response: The `HTTPURLResponse` received from the server.
  - rawData: The raw, unparsed data received from the server.
  - parsedResponse: [optional] The response parsed into the `ParsedValue` type. Will be nil if not yet parsed, or if parsing failed.

#### Parameters

| Name | Description |
| ---- | ----------- |
| response | The `HTTPURLResponse` received from the server. |
| rawData | The raw, unparsed data received from the server. |
| parsedResponse | [optional] The response parsed into the `ParsedValue` type. Will be nil if not yet parsed, or if parsing failed. |