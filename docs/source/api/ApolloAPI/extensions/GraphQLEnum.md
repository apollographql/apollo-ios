**EXTENSION**

# `GraphQLEnum`
```swift
extension GraphQLEnum: CustomScalarType
```

## Properties
### `jsonValue`

```swift
@inlinable public var jsonValue: AnyHashable
```

## Methods
### `init(jsonValue:)`

```swift
@inlinable public init(jsonValue: JSONValue) throws
```

### `==(_:_:)`

```swift
@inlinable public static func ==(lhs: GraphQLEnum<T>, rhs: GraphQLEnum<T>) -> Bool
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| lhs | A value to compare. |
| rhs | Another value to compare. |

### `==(_:_:)`

```swift
@inlinable public static func ==(lhs: GraphQLEnum<T>, rhs: T) -> Bool
```

### `!=(_:_:)`

```swift
@inlinable public static func !=(lhs: GraphQLEnum<T>, rhs: T) -> Bool
```

### `~=(_:_:)`

```swift
@inlinable public static func ~=(lhs: T, rhs: GraphQLEnum<T>) -> Bool
```
