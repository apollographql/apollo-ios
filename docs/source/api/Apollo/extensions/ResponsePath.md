**EXTENSION**

# `ResponsePath`
```swift
extension ResponsePath: CustomStringConvertible
```

## Properties
### `description`

```swift
public var description: String
```

## Methods
### `hash(into:)`

```swift
public func hash(into hasher: inout Hasher)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| hasher | The hasher to use when combining the components of this instance. |

### `==(_:_:)`

```swift
static public func == (lhs: ResponsePath, rhs: ResponsePath) -> Bool
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| lhs | A value to compare. |
| rhs | Another value to compare. |