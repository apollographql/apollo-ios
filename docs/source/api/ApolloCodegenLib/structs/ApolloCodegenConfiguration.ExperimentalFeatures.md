**STRUCT**

# `ApolloCodegenConfiguration.ExperimentalFeatures`

```swift
public struct ExperimentalFeatures: Codable, Equatable
```

## Properties
### `clientControlledNullability`

```swift
public let clientControlledNullability: Bool
```

 **EXPERIMENTAL**: If enabled, the parser will understand and parse Client Controlled Nullability
 Designators contained in Fields. They'll be represented in the
 `required` field of the FieldNode.

 The syntax looks like the following:

 ```graphql
   {
     nullableField!
     nonNullableField?
     nonNullableSelectionSet? {
       childField!
     }
   }
 ```
 - Note: This feature is experimental and may change or be removed in the
 future.

### `legacySafelistingCompatibleOperations`

```swift
public let legacySafelistingCompatibleOperations: Bool
```

 **EXPERIMENTAL**: If enabled, the generated operations will be transformed using a method
 that attempts to maintain compatibility with the legacy behavior from
 [`apollo-tooling`](https://github.dev/apollographql/apollo-tooling)
 for registering persisted operation to a safelist.

 - Note: Safelisting queries is a deprecated feature of Apollo Server that has reduced
 support for legacy use cases. This option may not work as intended in all situations.

## Methods
### `init(clientControlledNullability:legacySafelistingCompatibleOperations:)`

```swift
public init(
  clientControlledNullability: Bool = false,
  legacySafelistingCompatibleOperations: Bool = false
)
```
