**CLASS**

# `CompilationResult.Directive`

```swift
public class Directive: JavaScriptObject, Hashable
```

## Properties
### `debugDescription`

```swift
public override var debugDescription: String
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
public static func == (lhs: Directive, rhs: Directive) -> Bool
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| lhs | A value to compare. |
| rhs | Another value to compare. |