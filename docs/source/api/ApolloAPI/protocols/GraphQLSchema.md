**PROTOCOL**

# `GraphQLSchema`

```swift
public protocol GraphQLSchema
```

A protocol that a generated GraphQL Schema should conform to.

A `GraphQLSchema` contains information on the types within a schema and their relationships
to other types. This information is used to verify that a `SelectionSet` can be converted to
a given type condition.
