**STRUCT**

# `InputDict`

```swift
public struct InputDict: GraphQLOperationVariableValue, Hashable
```

A structure that wraps the underlying data dictionary used by `InputObject`s.

## Properties
### `jsonEncodableValue`

```swift
public var jsonEncodableValue: JSONEncodable?
```

## Methods
### `init(_:)`

```swift
public init(_ data: [String: GraphQLOperationVariableValue] = [:])
```

### `==(_:_:)`

```swift
public static func == (lhs: InputDict, rhs: InputDict) -> Bool
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