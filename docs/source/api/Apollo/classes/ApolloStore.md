**CLASS**

# `ApolloStore`

```swift
public final class ApolloStore
```

> The `ApolloStore` class acts as a local cache for normalized GraphQL results.

## Properties
### `cacheKeyForObject`

```swift
public var cacheKeyForObject: CacheKeyForObject?
```

## Methods
### `init(cache:)`

```swift
public init(cache: NormalizedCache)
```

> Designated initializer
>
> - Parameter cache: An instance of `normalizedCache` to use to cache results.

#### Parameters

| Name | Description |
| ---- | ----------- |
| cache | An instance of `normalizedCache` to use to cache results. |

### `clearCache(callbackQueue:completion:)`

```swift
public func clearCache(callbackQueue: DispatchQueue = .main, completion: ((Result<Void, Error>) -> Void)? = nil)
```

> Clears the instance of the cache. Note that a cache can be shared across multiple `ApolloClient` objects, so clearing that underlying cache will clear it for all clients.
>
> - Returns: A promise which fulfills when the Cache is cleared.

### `withinReadTransaction(_:callbackQueue:completion:)`

```swift
public func withinReadTransaction<T>(_ body: @escaping (ReadTransaction) throws -> T,
                                     callbackQueue: DispatchQueue? = nil,
                                     completion: ((Result<T, Error>) -> Void)? = nil)
```

> Performs an operation within a read transaction
>
> - Parameters:
>   - body: The body of the operation to perform.
>   - callbackQueue: [optional] The callback queue to use to perform the completion block on. Will perform on the current queue if not provided. Defaults to nil.
>   - completion: [optional] The completion block to perform when the read transaction completes. Defaults to nil.

#### Parameters

| Name | Description |
| ---- | ----------- |
| body | The body of the operation to perform. |
| callbackQueue | [optional] The callback queue to use to perform the completion block on. Will perform on the current queue if not provided. Defaults to nil. |
| completion | [optional] The completion block to perform when the read transaction completes. Defaults to nil. |

### `withinReadWriteTransaction(_:callbackQueue:completion:)`

```swift
public func withinReadWriteTransaction<T>(_ body: @escaping (ReadWriteTransaction) throws -> T,
                                          callbackQueue: DispatchQueue? = nil,
                                          completion: ((Result<T, Error>) -> Void)? = nil)
```

> Performs an operation within a read-write transaction
>
> - Parameters:
>   - body: The body of the operation to perform
>   - callbackQueue: [optional] a callback queue to perform the action on. Will perform on the current queue if not provided. Defaults to nil.
>   - completion: [optional] a completion block to fire when the read-write transaction completes. Defaults to nil.

#### Parameters

| Name | Description |
| ---- | ----------- |
| body | The body of the operation to perform |
| callbackQueue | [optional] a callback queue to perform the action on. Will perform on the current queue if not provided. Defaults to nil. |
| completion | [optional] a completion block to fire when the read-write transaction completes. Defaults to nil. |

### `load(query:resultHandler:)`

```swift
public func load<Query: GraphQLQuery>(query: Query, resultHandler: @escaping GraphQLResultHandler<Query.Data>)
```

> Loads the results for the given query from the cache.
>
> - Parameters:
>   - query: The query to load results for
>   - resultHandler: The completion handler to execute on success or error

#### Parameters

| Name | Description |
| ---- | ----------- |
| query | The query to load results for |
| resultHandler | The completion handler to execute on success or error |