**EXTENSION**

# `HTTPResponse`
```swift
extension HTTPResponse: Equatable where Operation.Data: Equatable
```

## Methods
### `==(_:_:)`

```swift
public static func == (lhs: HTTPResponse<Operation>, rhs: HTTPResponse<Operation>) -> Bool
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| lhs | A value to compare. |
| rhs | Another value to compare. |

### `hash(into:)`

```swift
public func hash(into hasher: inout Hasher)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| hasher | The hasher to use when combining the components of this instance. |