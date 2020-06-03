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
