**ENUM**

# `InputValue`

```swift
public indirect enum InputValue
```

Represents an input value to an argument on a `GraphQLField`'s `FieldArguments`.

- See: [GraphQLSpec - Input Values](http://spec.graphql.org/June2018/#sec-Input-Values)

## Cases
### `scalar(_:)`

```swift
case scalar(ScalarType)
```

A direct input value, valid types are `String`, `Int` `Float` and `Bool`.
For enum input values, the enum cases's `rawValue` as a `String` should be used.

### `variable(_:)`

```swift
case variable(String)
```

A variable input value to be evaluated using the operation's `variables` dictionary at runtime.

### `list(_:)`

```swift
case list([InputValue])
```

A GraphQL "List" input value.
- See: [GraphQLSpec - Input Values - List Value](http://spec.graphql.org/June2018/#sec-List-Value)

### `object(_:)`

```swift
case object([String: InputValue])
```

A GraphQL "InputObject" input value. Represented as a dictionary of input values.
- See: [GraphQLSpec - Input Values - Input Object Values](http://spec.graphql.org/June2018/#sec-Input-Object-Values)

### `none`

```swift
case none
```

A null input value.
- See: [GraphQLSpec - Input Values - Null Value](http://spec.graphql.org/June2018/#sec-Null-Value)
