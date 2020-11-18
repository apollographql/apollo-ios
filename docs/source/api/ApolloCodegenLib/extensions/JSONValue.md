**EXTENSION**

# `JSONValue`
```swift
extension JSONValue: ExpressibleByArrayLiteral
```

## Methods
### `init(arrayLiteral:)`

```swift
public init(arrayLiteral elements: JSONValue...)
```

### `init(dictionaryLiteral:)`

```swift
public init(dictionaryLiteral elements: (String, JSONValue)...)
```

### `init(integerLiteral:)`

```swift
public init(integerLiteral value: Int)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| value | The value to create. |

### `init(floatLiteral:)`

```swift
public init(floatLiteral value: Double)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| value | The value to create. |

### `init(booleanLiteral:)`

```swift
public init(booleanLiteral value: Bool)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| value | The value of the new instance. |

### `init(nilLiteral:)`

```swift
public init(nilLiteral: ())
```

### `init(stringLiteral:)`

```swift
public init(stringLiteral value: String)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| value | The value of the new instance. |