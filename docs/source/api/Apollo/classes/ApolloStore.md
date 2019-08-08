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

### `clearCache()`

```swift
public func clearCache() -> Promise<Void>
```

> Clears the instance of the cache. Note that a cache can be shared across multiple `ApolloClient` objects, so clearing that underlying cache will clear it for all clients.
>
> - Returns: A promise which fulfills when the Cache is cleared.

### `withinReadTransaction(_:)`

```swift
public func withinReadTransaction<T>(_ body: @escaping (ReadTransaction) throws -> Promise<T>) -> Promise<T>
```

### `withinReadTransaction(_:)`

```swift
public func withinReadTransaction<T>(_ body: @escaping (ReadTransaction) throws -> T) -> Promise<T>
```

### `withinReadWriteTransaction(_:)`

```swift
public func withinReadWriteTransaction<T>(_ body: @escaping (ReadWriteTransaction) throws -> Promise<T>) -> Promise<T>
```

### `withinReadWriteTransaction(_:)`

```swift
public func withinReadWriteTransaction<T>(_ body: @escaping (ReadWriteTransaction) throws -> T) -> Promise<T>
```

### `load(query:)`

```swift
public func load<Query: GraphQLQuery>(query: Query) -> Promise<GraphQLResult<Query.Data>>
```

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