**EXTENSION**

# `InputValue`
```swift
extension InputValue: ExpressibleByNilLiteral
```

## Methods
### `init(nilLiteral:)`

```swift
@inlinable public init(nilLiteral: ())
```

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
public init(dictionaryLiteral elements: (String, InputValue)...)
```
