**CLASS**

# `ApolloStore.ReadWriteTransaction`

```swift
public final class ReadWriteTransaction: ReadTransaction
```

## Methods
### `update(_:_:)`

```swift
public func update<CacheMutation: LocalCacheMutation>(
  _ cacheMutation: CacheMutation,
  _ body: (inout CacheMutation.Data) throws -> Void
) throws
```

### `updateObject(ofType:withKey:variables:_:)`

```swift
public func updateObject<SelectionSet: ApolloAPI.MutableRootSelectionSet>(
  ofType type: SelectionSet.Type,
  withKey key: CacheKey,
  variables: GraphQLOperation.Variables? = nil,
  _ body: (inout SelectionSet) throws -> Void
) throws
```

### `write(data:for:)`

```swift
public func write<CacheMutation: LocalCacheMutation>(
  data: CacheMutation.Data,
  for cacheMutation: CacheMutation
) throws
```

### `write(selectionSet:withKey:variables:)`

```swift
public func write<SelectionSet: MutableRootSelectionSet>(
  selectionSet: SelectionSet,
  withKey key: CacheKey,
  variables: GraphQLOperation.Variables? = nil
) throws
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

### `removeObjects(matching:)`

```swift
public func removeObjects(matching pattern: CacheKey) throws
```

Removes records with keys that match the specified pattern. This method will only
remove whole records, it does not perform cascading deletes. This means only the
records with matched keys will be removed, and not any references to them. Key
matching is case-insensitive.

If you attempt to pass a cache path for a single field, this method will do nothing
since it won't be able to locate a record to remove based on that path.

- Note: This method can be very slow depending on the number of records in the cache.
It is recommended that this method be called in a background queue.

- Parameters:
  - pattern: The pattern that will be applied to find matching keys.

#### Parameters

| Name | Description |
| ---- | ----------- |
| pattern | The pattern that will be applied to find matching keys. |