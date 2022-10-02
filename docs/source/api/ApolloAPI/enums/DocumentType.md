**ENUM**

# `DocumentType`

```swift
public enum DocumentType
```

The means of providing the operation document that includes the definition of the operation
over network transport.

This data represents the `Document` as defined in the GraphQL Spec.
- See: [GraphQLSpec - Document](https://spec.graphql.org/draft/#Document)

The Apollo Code Generation Engine will generate the `DocumentType` on each generated
`GraphQLOperation`. You can change the type of `DocumentType` generated in your
[code generation configuration](// TODO: ADD URL TO DOCUMENTATION HERE).

## Cases
### `notPersisted(definition:)`

```swift
case notPersisted(definition: OperationDefinition)
```

The traditional way of providing the operation `Document`.
The `Document` is sent with every operation request.

### `automaticallyPersisted(operationIdentifier:definition:)`

```swift
case automaticallyPersisted(operationIdentifier: String, definition: OperationDefinition)
```

Automatically persists your operations using Apollo Server's
[APQs](https://www.apollographql.com/docs/apollo-server/performance/apq).

This allow the operation definition to be persisted using an `operationIdentifier` instead of
being sent with every operation request. If the server does not recognize the
`operationIdentifier`, the network transport can send the provided definition to
"automatically persist" the operation definition.

### `persistedOperationsOnly(operationIdentifier:)`

```swift
case persistedOperationsOnly(operationIdentifier: String)
```

Provides only the `operationIdentifier` for operations that have been previously persisted
to an Apollo Server using
[APQs](https://www.apollographql.com/docs/apollo-server/performance/apq).

If the server does not recognize the `operationIdentifier`, the operation will fail. This
method should only be used if you are manually persisting your queries to an Apollo Server.
