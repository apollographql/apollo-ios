**CLASS**

# `GraphQLResponse`

```swift
public final class GraphQLResponse<Data: RootSelectionSet>
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

### `parseResult()`

```swift
public func parseResult() throws -> (GraphQLResult<Data>, RecordSet?)
```

Parses a response into a `GraphQLResult` and a `RecordSet`.
The result can be sent to a completion block for a request.
The `RecordSet` can be merged into a local cache.
- Returns: A `GraphQLResult` and a `RecordSet`.

### `parseResultFast()`

```swift
public func parseResultFast() throws -> GraphQLResult<Data>
```

Parses a response into a `GraphQLResult` for use without the cache. This parsing does not
create dependent keys or a `RecordSet` for the cache.

This is faster than `parseResult()` and should be used when cache the response is not needed.
