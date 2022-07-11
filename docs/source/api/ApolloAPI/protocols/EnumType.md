**PROTOCOL**

# `EnumType`

```swift
public protocol EnumType:
  RawRepresentable,
  CaseIterable,
  JSONEncodable,
  GraphQLOperationVariableValue
where RawValue == String
```

A protocol that a generated enum from a GraphQL schema conforms to.
This allows it to be wrapped in a `GraphQLEnum` and be used as an input value for operations.
