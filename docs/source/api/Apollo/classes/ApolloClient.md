**CLASS**

# `ApolloClient`

```swift
public class ApolloClient
```

> The `ApolloClient` class provides the core API for Apollo. This API provides methods to fetch and watch queries, and to perform mutations.

## Properties
### `store`

```swift
public let store: ApolloStore
```

### `cacheKeyForObject`

```swift
public var cacheKeyForObject: CacheKeyForObject?
```

## Methods
### `init(networkTransport:store:)`

```swift
public init(networkTransport: NetworkTransport, store: ApolloStore = ApolloStore(cache: InMemoryNormalizedCache()))
```

> Creates a client with the specified network transport and store.
>
> - Parameters:
>   - networkTransport: A network transport used to send operations to a server.
>   - store: A store used as a local cache. Defaults to an empty store backed by an in memory cache.

#### Parameters

| Name | Description |
| ---- | ----------- |
| networkTransport | A network transport used to send operations to a server. |
| store | A store used as a local cache. Defaults to an empty store backed by an in memory cache. |

### `init(url:)`

```swift
public convenience init(url: URL)
```

> Creates a client with an HTTP network transport connecting to the specified URL.
>
> - Parameter url: The URL of a GraphQL server to connect to.

#### Parameters

| Name | Description |
| ---- | ----------- |
| url | The URL of a GraphQL server to connect to. |

### `clearCache()`

```swift
public func clearCache() -> Promise<Void>
```

> Clears apollo cache
>
> - Returns: Promise

### `fetch(query:cachePolicy:context:queue:resultHandler:)`

```swift
@discardableResult public func fetch<Query: GraphQLQuery>(query: Query, cachePolicy: CachePolicy = .returnCacheDataElseFetch, context: UnsafeMutableRawPointer? = nil, queue: DispatchQueue = DispatchQueue.main, resultHandler: GraphQLResultHandler<Query.Data>? = nil) -> Cancellable
```

> Fetches a query from the server or from the local cache, depending on the current contents of the cache and the specified cache policy.
>
> - Parameters:
>   - query: The query to fetch.
>   - cachePolicy: A cache policy that specifies when results should be fetched from the server and when data should be loaded from the local cache.
>   - queue: A dispatch queue on which the result handler will be called. Defaults to the main queue.
>   - resultHandler: An optional closure that is called when query results are available or when an error occurs.
> - Returns: An object that can be used to cancel an in progress fetch.

#### Parameters

| Name | Description |
| ---- | ----------- |
| query | The query to fetch. |
| cachePolicy | A cache policy that specifies when results should be fetched from the server and when data should be loaded from the local cache. |
| queue | A dispatch queue on which the result handler will be called. Defaults to the main queue. |
| resultHandler | An optional closure that is called when query results are available or when an error occurs. |

### `watch(query:cachePolicy:queue:resultHandler:)`

```swift
public func watch<Query: GraphQLQuery>(query: Query, cachePolicy: CachePolicy = .returnCacheDataElseFetch, queue: DispatchQueue = DispatchQueue.main, resultHandler: @escaping GraphQLResultHandler<Query.Data>) -> GraphQLQueryWatcher<Query>
```

> Watches a query by first fetching an initial result from the server or from the local cache, depending on the current contents of the cache and the specified cache policy. After the initial fetch, the returned query watcher object will get notified whenever any of the data the query result depends on changes in the local cache, and calls the result handler again with the new result.
>
> - Parameters:
>   - query: The query to fetch.
>   - fetchHTTPMethod: The HTTP Method to be used.
>   - cachePolicy: A cache policy that specifies when results should be fetched from the server or from the local cache.
>   - queue: A dispatch queue on which the result handler will be called. Defaults to the main queue.
>   - resultHandler: An optional closure that is called when query results are available or when an error occurs.
> - Returns: A query watcher object that can be used to control the watching behavior.

#### Parameters

| Name | Description |
| ---- | ----------- |
| query | The query to fetch. |
| fetchHTTPMethod | The HTTP Method to be used. |
| cachePolicy | A cache policy that specifies when results should be fetched from the server or from the local cache. |
| queue | A dispatch queue on which the result handler will be called. Defaults to the main queue. |
| resultHandler | An optional closure that is called when query results are available or when an error occurs. |

### `perform(mutation:context:queue:resultHandler:)`

```swift
@discardableResult public func perform<Mutation: GraphQLMutation>(mutation: Mutation, context: UnsafeMutableRawPointer? = nil, queue: DispatchQueue = DispatchQueue.main, resultHandler: GraphQLResultHandler<Mutation.Data>? = nil) -> Cancellable
```

> Performs a mutation by sending it to the server.
>
> - Parameters:
>   - mutation: The mutation to perform.
>   - fetchHTTPMethod: The HTTP Method to be used.
>   - queue: A dispatch queue on which the result handler will be called. Defaults to the main queue.
>   - resultHandler: An optional closure that is called when mutation results are available or when an error occurs.
> - Returns: An object that can be used to cancel an in progress mutation.

#### Parameters

| Name | Description |
| ---- | ----------- |
| mutation | The mutation to perform. |
| fetchHTTPMethod | The HTTP Method to be used. |
| queue | A dispatch queue on which the result handler will be called. Defaults to the main queue. |
| resultHandler | An optional closure that is called when mutation results are available or when an error occurs. |

### `subscribe(subscription:queue:resultHandler:)`

```swift
@discardableResult public func subscribe<Subscription: GraphQLSubscription>(subscription: Subscription, queue: DispatchQueue = DispatchQueue.main, resultHandler: @escaping GraphQLResultHandler<Subscription.Data>) -> Cancellable
```

> Subscribe to a subscription
>
> - Parameters:
>   - subscription: The subscription to subscribe to.
>   - fetchHTTPMethod: The HTTP Method to be used.
>   - queue: A dispatch queue on which the result handler will be called. Defaults to the main queue.
>   - resultHandler: An optional closure that is called when mutation results are available or when an error occurs.
> - Returns: An object that can be used to cancel an in progress subscription.

#### Parameters

| Name | Description |
| ---- | ----------- |
| subscription | The subscription to subscribe to. |
| fetchHTTPMethod | The HTTP Method to be used. |
| queue | A dispatch queue on which the result handler will be called. Defaults to the main queue. |
| resultHandler | An optional closure that is called when mutation results are available or when an error occurs. |