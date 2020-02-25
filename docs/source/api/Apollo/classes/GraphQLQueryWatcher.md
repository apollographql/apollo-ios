**CLASS**

# `GraphQLQueryWatcher`

```swift
public final class GraphQLQueryWatcher<Query: GraphQLQuery>: Cancellable, ApolloStoreSubscriber
```

> A `GraphQLQueryWatcher` is responsible for watching the store, and calling the result handler with a new result whenever any of the data the previous result depends on changes.

## Properties
### `query`

```swift
public let query: Query
```

## Methods
### `init(client:query:resultHandler:)`

```swift
public init(client: ApolloClientProtocol,
            query: Query,
            resultHandler: @escaping GraphQLResultHandler<Query.Data>)
```

> Designated initializer
>
> - Parameters:
>   - client: The client protocol to pass in
>   - query: The query to watch
>   - resultHandler: The result handler to call with changes.

#### Parameters

| Name | Description |
| ---- | ----------- |
| client | The client protocol to pass in |
| query | The query to watch |
| resultHandler | The result handler to call with changes. |

### `refetch()`

```swift
public func refetch()
```

> Refetch a query from the server.

### `cancel()`

```swift
public func cancel()
```

> Cancel any in progress fetching operations and unsubscribe from the store.
