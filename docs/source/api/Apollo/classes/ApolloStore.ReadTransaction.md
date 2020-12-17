**CLASS**

# `ApolloStore.ReadTransaction`

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
public func readObject<SelectionSet: GraphQLSelectionSet>(ofType type: SelectionSet.Type,
                                                          withKey key: CacheKey,
                                                          variables: GraphQLMap? = nil) throws -> SelectionSet
```
