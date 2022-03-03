**PROTOCOL**

# `ApolloClientProtocol`

```swift
public protocol ApolloClientProtocol: AnyObject
```

The `ApolloClientProtocol` provides the core API for Apollo. This API provides methods to fetch and watch queries, and to perform mutations.

## Properties
### `store`

```swift
var store: ApolloStore
```

A store used as a local cache.

### `cacheKeyForObject`

```swift
var cacheKeyForObject: CacheKeyForObject?
```

A function that returns a cache key for a particular result object. If it returns `nil`, a default cache key based on the field path will be used.

## Methods
### `clearCache(callbackQueue:completion:)`

```swift
func clearCache(callbackQueue: DispatchQueue, completion: ((Result<Void, Error>) -> Void)?)
```

Clears the underlying cache.
Be aware: In more complex setups, the same underlying cache can be used across multiple instances, so if you call this on one instance, it'll clear that cache across all instances which share that cache.

- Parameters:
  - callbackQueue: The queue to fall back on. Should default to the main queue.
  - completion: [optional] A completion closure to execute when clearing has completed. Should default to nil.

#### Parameters

| Name | Description |
| ---- | ----------- |
| callbackQueue | The queue to fall back on. Should default to the main queue. |
| completion | [optional] A completion closure to execute when clearing has completed. Should default to nil. |

### `fetch(query:cachePolicy:contextIdentifier:queue:resultHandler:)`

```swift
func fetch<Query: GraphQLQuery>(query: Query,
                                cachePolicy: CachePolicy,
                                contextIdentifier: UUID?,
                                queue: DispatchQueue,
                                resultHandler: GraphQLResultHandler<Query.Data>?) -> Cancellable
```

Fetches a query from the server or from the local cache, depending on the current contents of the cache and the specified cache policy.

- Parameters:
  - query: The query to fetch.
  - cachePolicy: A cache policy that specifies when results should be fetched from the server and when data should be loaded from the local cache.
  - queue: A dispatch queue on which the result handler will be called. Should default to the main queue.
  - contextIdentifier: [optional] A unique identifier for this request, to help with deduping cache hits for watchers. Should default to `nil`.
  - resultHandler: [optional] A closure that is called when query results are available or when an error occurs.
- Returns: An object that can be used to cancel an in progress fetch.

#### Parameters

| Name | Description |
| ---- | ----------- |
| query | The query to fetch. |
| cachePolicy | A cache policy that specifies when results should be fetched from the server and when data should be loaded from the local cache. |
| queue | A dispatch queue on which the result handler will be called. Should default to the main queue. |
| contextIdentifier | [optional] A unique identifier for this request, to help with deduping cache hits for watchers. Should default to `nil`. |
| resultHandler | [optional] A closure that is called when query results are available or when an error occurs. |

### `watch(query:cachePolicy:callbackQueue:resultHandler:)`

```swift
func watch<Query: GraphQLQuery>(query: Query,
                                cachePolicy: CachePolicy,
                                callbackQueue: DispatchQueue,
                                resultHandler: @escaping GraphQLResultHandler<Query.Data>) -> GraphQLQueryWatcher<Query>
```

Watches a query by first fetching an initial result from the server or from the local cache, depending on the current contents of the cache and the specified cache policy. After the initial fetch, the returned query watcher object will get notified whenever any of the data the query result depends on changes in the local cache, and calls the result handler again with the new result.

- Parameters:
  - query: The query to fetch.
  - cachePolicy: A cache policy that specifies when results should be fetched from the server or from the local cache.
  - callbackQueue: A dispatch queue on which the result handler will be called. Should default to the main queue.
  - resultHandler: [optional] A closure that is called when query results are available or when an error occurs.
- Returns: A query watcher object that can be used to control the watching behavior.

#### Parameters

| Name | Description |
| ---- | ----------- |
| query | The query to fetch. |
| cachePolicy | A cache policy that specifies when results should be fetched from the server or from the local cache. |
| callbackQueue | A dispatch queue on which the result handler will be called. Should default to the main queue. |
| resultHandler | [optional] A closure that is called when query results are available or when an error occurs. |

### `perform(mutation:publishResultToStore:queue:resultHandler:)`

```swift
func perform<Mutation: GraphQLMutation>(mutation: Mutation,
                                        publishResultToStore: Bool,
                                        queue: DispatchQueue,
                                        resultHandler: GraphQLResultHandler<Mutation.Data>?) -> Cancellable
```

Performs a mutation by sending it to the server.

- Parameters:
  - mutation: The mutation to perform.
  - publishResultToStore: If `true`, this will publish the result returned from the operation to the cache store. Default is `true`.
  - queue: A dispatch queue on which the result handler will be called. Should default to the main queue.
  - resultHandler: An optional closure that is called when mutation results are available or when an error occurs.
- Returns: An object that can be used to cancel an in progress mutation.

#### Parameters

| Name | Description |
| ---- | ----------- |
| mutation | The mutation to perform. |
| publishResultToStore | If `true`, this will publish the result returned from the operation to the cache store. Default is `true`. |
| queue | A dispatch queue on which the result handler will be called. Should default to the main queue. |
| resultHandler | An optional closure that is called when mutation results are available or when an error occurs. |

### `upload(operation:files:queue:resultHandler:)`

```swift
func upload<Operation: GraphQLOperation>(operation: Operation,
                                         files: [GraphQLFile],
                                         queue: DispatchQueue,
                                         resultHandler: GraphQLResultHandler<Operation.Data>?) -> Cancellable
```

Uploads the given files with the given operation.

- Parameters:
  - operation: The operation to send
  - files: An array of `GraphQLFile` objects to send.
  - queue: A dispatch queue on which the result handler will be called. Should default to the main queue.
  - completionHandler: The completion handler to execute when the request completes or errors. Note that an error will be returned If your `networkTransport` does not also conform to `UploadingNetworkTransport`.
- Returns: An object that can be used to cancel an in progress request.

#### Parameters

| Name | Description |
| ---- | ----------- |
| operation | The operation to send |
| files | An array of `GraphQLFile` objects to send. |
| queue | A dispatch queue on which the result handler will be called. Should default to the main queue. |
| completionHandler | The completion handler to execute when the request completes or errors. Note that an error will be returned If your `networkTransport` does not also conform to `UploadingNetworkTransport`. |

### `subscribe(subscription:queue:resultHandler:)`

```swift
func subscribe<Subscription: GraphQLSubscription>(subscription: Subscription,
                                                  queue: DispatchQueue,
                                                  resultHandler: @escaping GraphQLResultHandler<Subscription.Data>) -> Cancellable
```

Subscribe to a subscription

- Parameters:
  - subscription: The subscription to subscribe to.
  - fetchHTTPMethod: The HTTP Method to be used.
  - queue: A dispatch queue on which the result handler will be called. Should default to the main queue.
  - resultHandler: An optional closure that is called when mutation results are available or when an error occurs.
- Returns: An object that can be used to cancel an in progress subscription.

#### Parameters

| Name | Description |
| ---- | ----------- |
| subscription | The subscription to subscribe to. |
| fetchHTTPMethod | The HTTP Method to be used. |
| queue | A dispatch queue on which the result handler will be called. Should default to the main queue. |
| resultHandler | An optional closure that is called when mutation results are available or when an error occurs. |