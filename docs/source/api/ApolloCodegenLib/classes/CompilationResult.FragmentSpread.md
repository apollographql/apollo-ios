**CLASS**

# `CompilationResult.FragmentSpread`

```swift
public class FragmentSpread: JavaScriptObject, Hashable
```

Represents an individual selection that includes a named fragment in a selection set.
(ie. `...FragmentName`)

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
public static func ==(lhs: FragmentSpread, rhs: FragmentSpread) -> Bool
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| lhs | A value to compare. |
| rhs | Another value to compare. |