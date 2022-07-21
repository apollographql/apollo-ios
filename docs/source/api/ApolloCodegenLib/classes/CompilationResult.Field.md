**CLASS**

# `CompilationResult.Field`

```swift
public class Field: JavaScriptWrapper, Hashable, CustomDebugStringConvertible
```

## Properties
### `debugDescription`

```swift
public var debugDescription: String
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
public static func ==(lhs: Field, rhs: Field) -> Bool
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| lhs | A value to compare. |
| rhs | Another value to compare. |