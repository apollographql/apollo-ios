**STRUCT**

# `Selection.Field`

```swift
public struct Field
```

## Properties
### `name`

```swift
public let name: String
```

### `alias`

```swift
public let alias: String?
```

### `arguments`

```swift
public let arguments: [String: InputValue]?
```

### `type`

```swift
public let type: OutputType
```

### `responseKey`

```swift
public var responseKey: String
```

## Methods
### `init(_:alias:type:arguments:)`

```swift
public init(
  _ name: String,
  alias: String? = nil,
  type: OutputType,
  arguments: [String: InputValue]? = nil
)
```
