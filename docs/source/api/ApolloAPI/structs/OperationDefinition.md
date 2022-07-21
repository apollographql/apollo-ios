**STRUCT**

# `OperationDefinition`

```swift
public struct OperationDefinition
```

The definition of an operation to be provided over network transport.

This data represents the `Definition` for a `Document` as defined in the GraphQL Spec.
In the case of the Apollo client, the definition will always be an `ExecutableDefinition`.
- See: [GraphQLSpec - Document](https://spec.graphql.org/draft/#Document)

## Properties
### `queryDocument`

```swift
public var queryDocument: String
```

## Methods
### `init(_:fragments:)`

```swift
public init(_ definition: String, fragments: [Fragment.Type]? = nil)
```
