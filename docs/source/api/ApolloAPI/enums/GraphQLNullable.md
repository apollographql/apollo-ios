**ENUM**

# `GraphQLNullable`

```swift
public enum GraphQLNullable<Wrapped>: ExpressibleByNilLiteral
```

Indicates the presence of a value, supporting both `nil` and `null` values.

In GraphQL, explicitly providing a `null` value for an input value to a field argument is
semantically different from not providing a value at all (`nil`). This enum allows you to
distinguish your input values between `null` and `nil`.

- See: [GraphQLSpec - Input Values - Null Value](http://spec.graphql.org/June2018/#sec-Null-Value)

## Cases
### `none`

```swift
case none
```

The absence of a value.
Functionally equivalent to `nil`.

### `null`

```swift
case null
```

The presence of an explicity null value.
Functionally equivalent to `NSNull`

### `some(_:)`

```swift
case some(Wrapped)
```

The presence of a value, stored as `Wrapped`

## Properties
### `unwrapped`

```swift
@inlinable public var unwrapped: Wrapped?
```

## Methods
### `init(nilLiteral:)`

```swift
@inlinable public init(nilLiteral: ())
```
