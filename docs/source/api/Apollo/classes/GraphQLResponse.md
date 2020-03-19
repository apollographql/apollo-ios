**CLASS**

# `GraphQLResponse`

```swift
public final class GraphQLResponse<Data: GraphQLSelectionSet>
```

> Represents a GraphQL response received from a server.

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
