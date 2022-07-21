**EXTENSION**

# `GraphQLResponse`
```swift
extension GraphQLResponse: Equatable where Data: Equatable
```

## Methods
### `==(_:_:)`

```swift
public static func == (lhs: GraphQLResponse<Data>, rhs: GraphQLResponse<Data>) -> Bool
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