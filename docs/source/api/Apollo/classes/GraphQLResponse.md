**CLASS**

# `GraphQLResponse`

```swift
public final class GraphQLResponse<Data: GraphQLSelectionSet>
```

Represents a GraphQL response received from a server.

## Properties
### `body`

```swift
public let body: JSONObject
```

## Methods
### `init(operation:body:)`

```swift
public init<Operation: GraphQLOperation>(operation: Operation, body: JSONObject) where Operation.Data == Data
```

### `parseResult(cacheKeyForObject:)`

```swift
public func parseResult(cacheKeyForObject: CacheKeyForObject? = nil) throws -> (GraphQLResult<Data>, RecordSet?)
```

Parses a response into a `GraphQLResult` and a `RecordSet`.
The result can be sent to a completion block for a request.
The `RecordSet` can be merged into a local cache.
- Parameter cacheKeyForObject: See `CacheKeyForObject`
- Returns: A `GraphQLResult` and a `RecordSet`.

#### Parameters

| Name | Description |
| ---- | ----------- |
| cacheKeyForObject | See `CacheKeyForObject` |

### `parseErrorsOnlyFast()`

```swift
public func parseErrorsOnlyFast() -> [GraphQLError]?
```

### `parseResultFast()`

```swift
public func parseResultFast() throws -> GraphQLResult<Data>
```
