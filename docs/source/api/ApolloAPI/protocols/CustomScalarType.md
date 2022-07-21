**PROTOCOL**

# `CustomScalarType`

```swift
public protocol CustomScalarType:
  AnyScalarType,
  JSONDecodable,
  OutputTypeConvertible,
  GraphQLOperationVariableValue
```

## Properties
### `jsonValue`

```swift
var jsonValue: JSONValue
```
