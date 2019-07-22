**CLASS**

# `ReadTransaction`

```swift
public class ReadTransaction
```

## Methods
### `read(query:)`

```swift
public func read<Query: GraphQLQuery>(query: Query) throws -> Query.Data
```

### `readObject(ofType:withKey:variables:)`

```swift
public func readObject<SelectionSet: GraphQLSelectionSet>(ofType type: SelectionSet.Type, withKey key: CacheKey, variables: GraphQLMap? = nil) throws -> SelectionSet
```

### `loadRecords(forKeys:)`

```swift
public func loadRecords(forKeys keys: [CacheKey]) -> Promise<[Record?]>
```
