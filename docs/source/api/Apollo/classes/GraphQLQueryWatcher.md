**CLASS**

# `GraphQLQueryWatcher`

```swift
public final class GraphQLQueryWatcher<Query: GraphQLQuery>: Cancellable, ApolloStoreSubscriber
```

A `GraphQLQueryWatcher` is responsible for watching the store, and calling the result handler with a new result whenever any of the data the previous result depends on changes.

NOTE: The store retains the watcher while subscribed. You must call `cancel()` on your query watcher when you no longer need results. Failure to call `cancel()` before releasing your reference to the returned watcher will result in a memory leak.

## Properties
### `query`

```swift
public let query: Query
```

## Methods
### `init(client:query:callbackQueue:resultHandler:)`

```swift
public init(client: ApolloClientProtocol,
            query: Query,
            callbackQueue: DispatchQueue = .main,
            resultHandler: @escaping GraphQLResultHandler<Query.Data>)
```

Designated initializer

- Parameters:
  - client: The client protocol to pass in.
  - query: The query to watch.
  - callbackQueue: The queue for the result handler. Defaults to the main queue.
  - resultHandler: The result handler to call with changes.

#### Parameters

| Name | Description |
| ---- | ----------- |
| client | The client protocol to pass in. |
| query | The query to watch. |
| callbackQueue | The queue for the result handler. Defaults to the main queue. |
| resultHandler | The result handler to call with changes. |

### `refetch(cachePolicy:)`

```swift
public func refetch(cachePolicy: CachePolicy = .fetchIgnoringCacheData)
```

Refetch a query from the server.

### `cancel()`

```swift
public func cancel()
```

Cancel any in progress fetching operations and unsubscribe from the store.
