**STRUCT**

# `Selection.Conditions`

```swift
struct Conditions: ExpressibleByArrayLiteral, ExpressibleByStringLiteral, Hashable
```

The conditions representing a group of `@include/@skip` directives.

The conditions are a two-dimensional array of `Selection.Condition`s.
The outer array represents groups of conditions joined together with a logical "or".
Conditions in the same inner array are joined together with a logical "and".

## Properties
### `value`

```swift
public let value: [[Condition]]
```

## Methods
### `init(_:)`

```swift
public init(_ value: [[Condition]])
```

### `init(arrayLiteral:)`

```swift
public init(arrayLiteral elements: [Condition]...)
```

### `init(_:)`

```swift
public init(_ conditions: [Condition]...)
```

### `init(stringLiteral:)`

```swift
public init(stringLiteral string: String)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| value | The value of the new instance. |

### `init(_:)`

```swift
public init(_ condition: Condition)
```

### `||(_:_:)`

```swift
public static func ||(_ lhs: Conditions, rhs: [Condition]) -> Conditions
```

### `||(_:_:)`

```swift
public static func ||(_ lhs: Conditions, rhs: Condition) -> Conditions
```
