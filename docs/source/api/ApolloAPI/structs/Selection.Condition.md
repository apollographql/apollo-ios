**STRUCT**

# `Selection.Condition`

```swift
struct Condition: ExpressibleByStringLiteral, Hashable
```

## Properties
### `variableName`

```swift
public let variableName: String
```

### `inverted`

```swift
public let inverted: Bool
```

## Methods
### `init(variableName:inverted:)`

```swift
public init(
  variableName: String,
  inverted: Bool
)
```

### `init(stringLiteral:)`

```swift
public init(stringLiteral value: StringLiteralType)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| value | The value of the new instance. |

### `!(_:)`

```swift
public static prefix func !(value: Condition) -> Condition
```

### `&&(_:_:)`

```swift
public static func &&(_ lhs: Condition, rhs: Condition) -> [Condition]
```

### `&&(_:_:)`

```swift
public static func &&(_ lhs: [Condition], rhs: Condition) -> [Condition]
```

### `||(_:_:)`

```swift
public static func ||(_ lhs: Condition, rhs: Condition) -> Conditions
```

### `||(_:_:)`

```swift
public static func ||(_ lhs: [Condition], rhs: Condition) -> Conditions
```
