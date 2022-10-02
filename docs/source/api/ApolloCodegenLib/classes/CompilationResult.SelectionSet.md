**CLASS**

# `CompilationResult.SelectionSet`

```swift
public class SelectionSet: JavaScriptWrapper, Hashable, CustomDebugStringConvertible
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
public static func ==(lhs: SelectionSet, rhs: SelectionSet) -> Bool
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| lhs | A value to compare. |
| rhs | Another value to compare. |