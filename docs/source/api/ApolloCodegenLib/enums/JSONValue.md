**ENUM**

# `JSONValue`

```swift
public enum JSONValue: Codable, Equatable
```

## Cases
### `bool(_:)`

```swift
case bool(Bool)
```

### `int(_:)`

```swift
case int(Int)
```

### `double(_:)`

```swift
case double(Double)
```

### `string(_:)`

```swift
case string(String)
```

### `array(_:)`

```swift
case array([JSONValue])
```

### `dictionary(_:)`

```swift
case dictionary([String: JSONValue])
```

### `null`

```swift
case null
```

## Methods
### `==(_:_:)`

```swift
public static func ==(lhs: JSONValue, rhs: JSONValue) -> Bool
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| lhs | A value to compare. |
| rhs | Another value to compare. |

### `valueForKeyPath(_:)`

```swift
public func valueForKeyPath(_ keyPath: [String]) throws -> JSONValue
```

### `encode(to:)`

```swift
public func encode(to encoder: Encoder) throws
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| encoder | The encoder to write data to. |

### `init(from:)`

```swift
public init(from decoder: Decoder) throws
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| decoder | The decoder to read data from. |