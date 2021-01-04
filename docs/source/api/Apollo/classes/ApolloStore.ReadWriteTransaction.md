**CLASS**

# `ApolloStore.ReadWriteTransaction`

```swift
public final class ReadWriteTransaction: ReadTransaction
```

## Methods
### `update(query:_:)`

```swift
public func update<Query: GraphQLQuery>(query: Query, _ body: (inout Query.Data) throws -> Void) throws
```

### `updateObject(ofType:withKey:variables:_:)`

```swift
public func updateObject<SelectionSet: GraphQLSelectionSet>(ofType type: SelectionSet.Type,
                                                            withKey key: CacheKey,
                                                            variables: GraphQLMap? = nil,
                                                            _ body: (inout SelectionSet) throws -> Void) throws
```

### `removeObject(for:)`

```swift
public func removeObject(for key: CacheKey) throws
```

Removes the object for the specified cache key. Does not cascade
or allow removal of only certain fields. Does nothing if an object
does not exist for the given key.

- Parameters:
  - key: The cache key to remove the object for

#### Parameters

| Name | Description |
| ---- | ----------- |
| key | The cache key to remove the object for |

### `write(data:forQuery:)`

```swift
public func write<Query: GraphQLQuery>(data: Query.Data, forQuery query: Query) throws
```

### `write(object:withKey:variables:)`

```swift
public func write(object: GraphQLSelectionSet,
                  withKey key: CacheKey,
                  variables: GraphQLMap? = nil) throws
```
