**CLASS**

# `GraphQLResponse`

```swift
public final class GraphQLResponse<Data: GraphQLSelectionSet>: Parseable
```

Represents a GraphQL response received from a server.

## Properties
### `body`

```swift
public let body: JSONObject
```

## Methods
### `init(from:decoder:)`

```swift
public init<T>(from data: Foundation.Data, decoder: T) throws where T : FlexibleDecoder
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| data | The data to decode |
| decoder | The decoder to use to decode it |

### `init(operation:body:)`

```swift
public init<Operation: GraphQLOperation>(operation: Operation, body: JSONObject) where Operation.Data == Data
```

### `parseResultWithCompletion(cacheKeyForObject:completion:)`

```swift
public func parseResultWithCompletion(cacheKeyForObject: CacheKeyForObject? = nil,
                                      completion: (Result<(GraphQLResult<Data>, RecordSet?), Error>) -> Void)
```

### `parseErrorsOnlyFast()`

```swift
public func parseErrorsOnlyFast() -> [GraphQLError]?
```

### `parseResultFast()`

```swift
public func parseResultFast() throws -> GraphQLResult<Data>
```
