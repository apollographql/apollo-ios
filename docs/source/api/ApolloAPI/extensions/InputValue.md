**EXTENSION**

# `InputValue`
```swift
extension InputValue: ExpressibleByStringLiteral
```

## Methods
### `init(stringLiteral:)`

```swift
@inlinable public init(stringLiteral value: StringLiteralType)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| value | The value of the new instance. |

### `init(integerLiteral:)`

```swift
@inlinable public init(integerLiteral value: IntegerLiteralType)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| value | The value to create. |

### `init(floatLiteral:)`

```swift
@inlinable public init(floatLiteral value: FloatLiteralType)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| value | The value to create. |

### `init(booleanLiteral:)`

```swift
@inlinable public init(booleanLiteral value: BooleanLiteralType)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| value | The value of the new instance. |

### `init(arrayLiteral:)`

```swift
@inlinable public init(arrayLiteral elements: InputValue...)
```

### `init(dictionaryLiteral:)`

```swift
@inlinable public init(dictionaryLiteral elements: (String, InputValue)...)
```

### `==(_:_:)`

```swift
public static func == (lhs: InputValue, rhs: InputValue) -> Bool
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| lhs | A value to compare. |
| rhs | Another value to compare. |

### `hash(into:)`

```swift
public func hash(into hasher: inout Hasher)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| hasher | The hasher to use when combining the components of this instance. |