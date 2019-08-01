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
