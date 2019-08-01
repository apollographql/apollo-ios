**CLASS**

# `GraphQLQueryWatcher`

```swift
public final class GraphQLQueryWatcher<Query: GraphQLQuery>: Cancellable, ApolloStoreSubscriber
```

> A `GraphQLQueryWatcher` is responsible for watching the store, and calling the result handler with a new result whenever any of the data the previous result depends on changes.

## Methods
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
