**EXTENSION**

# `ApolloClient`
```swift
extension ApolloClient: ApolloClientProtocol
```

## Properties
### `cacheKeyForObject`

```swift
public var cacheKeyForObject: CacheKeyForObject?
```

## Methods
### `clearCache(callbackQueue:completion:)`

```swift
public func clearCache(callbackQueue: DispatchQueue = .main, completion: ((Result<Void, Error>) -> Void)? = nil)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| callbackQueue | The queue to fall back on. Should default to the main queue. |
| completion | [optional] A completion closure to execute when clearing has completed. Should default to nil. |

### `fetch(query:cachePolicy:context:queue:resultHandler:)`

```swift
@discardableResult public func fetch<Query: GraphQLQuery>(query: Query,
                                                          cachePolicy: CachePolicy = .returnCacheDataElseFetch,
                                                          context: UnsafeMutableRawPointer? = nil,
                                                          queue: DispatchQueue = DispatchQueue.main,
                                                          resultHandler: GraphQLResultHandler<Query.Data>? = nil) -> Cancellable
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| query | The query to fetch. |
| cachePolicy | A cache policy that specifies when results should be fetched from the server and when data should be loaded from the local cache. |
| context | [optional] A context to use for the cache to work with results. Should default to nil. |
| queue | A dispatch queue on which the result handler will be called. Defaults to the main queue. |
| resultHandler | [optional] A closure that is called when query results are available or when an error occurs. |

### `watch(query:cachePolicy:queue:resultHandler:)`

```swift
public func watch<Query: GraphQLQuery>(query: Query,
                                       cachePolicy: CachePolicy = .returnCacheDataElseFetch,
                                       queue: DispatchQueue = .main,
                                       resultHandler: @escaping GraphQLResultHandler<Query.Data>) -> GraphQLQueryWatcher<Query>
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| query | The query to fetch. |
| fetchHTTPMethod | The HTTP Method to be used. |
| cachePolicy | A cache policy that specifies when results should be fetched from the server or from the local cache. |
| queue | A dispatch queue on which the result handler will be called. Should default to the main queue. |
| resultHandler | [optional] A closure that is called when query results are available or when an error occurs. |

### `perform(mutation:context:queue:resultHandler:)`

```swift
public func perform<Mutation: GraphQLMutation>(mutation: Mutation,
                                               context: UnsafeMutableRawPointer? = nil,
                                               queue: DispatchQueue = DispatchQueue.main,
                                               resultHandler: GraphQLResultHandler<Mutation.Data>? = nil) -> Cancellable
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| mutation | The mutation to perform. |
| context | [optional] A context to use for the cache to work with results. Should default to nil. |
| queue | A dispatch queue on which the result handler will be called. Defaults to the main queue. |
| resultHandler | An optional closure that is called when mutation results are available or when an error occurs. |

### `upload(operation:context:files:queue:resultHandler:)`

```swift
public func upload<Operation: GraphQLOperation>(operation: Operation,
                                                context: UnsafeMutableRawPointer? = nil,
                                                files: [GraphQLFile],
                                                queue: DispatchQueue = .main,
                                                resultHandler: GraphQLResultHandler<Operation.Data>? = nil) -> Cancellable
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| operation | The operation to send |
| context | [optional] A context to use for the cache to work with results. Should default to nil. |
| files | An array of `GraphQLFile` objects to send. |
| queue | A dispatch queue on which the result handler will be called. Should default to the main queue. |
| completionHandler | The completion handler to execute when the request completes or errors |

### `subscribe(subscription:queue:resultHandler:)`

```swift
public func subscribe<Subscription: GraphQLSubscription>(subscription: Subscription,
                                                         queue: DispatchQueue = .main,
                                                         resultHandler: @escaping GraphQLResultHandler<Subscription.Data>) -> Cancellable
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| subscription | The subscription to subscribe to. |
| fetchHTTPMethod | The HTTP Method to be used. |
| queue | A dispatch queue on which the result handler will be called. Defaults to the main queue. |
| resultHandler | An optional closure that is called when mutation results are available or when an error occurs. |