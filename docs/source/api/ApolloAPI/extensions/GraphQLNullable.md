**EXTENSION**

# `GraphQLNullable`
```swift
extension GraphQLNullable: ExpressibleByUnicodeScalarLiteral
where Wrapped: ExpressibleByUnicodeScalarLiteral
```

## Properties
### `jsonEncodableValue`

```swift
@inlinable public var jsonEncodableValue: JSONEncodable?
```

## Methods
### `init(unicodeScalarLiteral:)`

```swift
@inlinable public init(unicodeScalarLiteral value: Wrapped.UnicodeScalarLiteralType)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| value | The value of the new instance. |

### `init(extendedGraphemeClusterLiteral:)`

```swift
@inlinable public init(extendedGraphemeClusterLiteral value: Wrapped.ExtendedGraphemeClusterLiteralType)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| value | The value of the new instance. |

### `init(stringLiteral:)`

```swift
@inlinable public init(stringLiteral value: Wrapped.StringLiteralType)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| value | The value of the new instance. |

### `init(integerLiteral:)`

```swift
@inlinable public init(integerLiteral value: Wrapped.IntegerLiteralType)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| value | The value to create. |

### `init(floatLiteral:)`

```swift
@inlinable public init(floatLiteral value: Wrapped.FloatLiteralType)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| value | The value to create. |

### `init(booleanLiteral:)`

```swift
@inlinable public init(booleanLiteral value: Wrapped.BooleanLiteralType)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| value | The value of the new instance. |

### `init(arrayLiteral:)`

```swift
@inlinable public init(arrayLiteral elements: Wrapped.ArrayLiteralElement...)
```

### `init(dictionaryLiteral:)`

```swift
@inlinable public init(dictionaryLiteral elements: (Wrapped.Key, Wrapped.Value)...)
```

### `init(_:)`

```swift
@inlinable init<T: EnumType>(_ caseValue: T) where Wrapped == GraphQLEnum<T>
```

### `init(_:)`

```swift
@inlinable init(_ object: Wrapped) where Wrapped: InputObject
```
