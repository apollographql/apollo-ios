**STRUCT**

# `DataDict`

```swift
public struct DataDict: Hashable
```

A structure that wraps the underlying data dictionary used by `SelectionSet`s.

## Properties
### `_data`

```swift
public var _data: JSONObject
```

### `_variables`

```swift
public let _variables: GraphQLOperation.Variables?
```

## Methods
### `init(_:variables:)`

```swift
@inlinable public init(
  _ data: JSONObject,
  variables: GraphQLOperation.Variables?
)
```

### `hash(into:)`

```swift
@inlinable public func hash(into hasher: inout Hasher)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| hasher | The hasher to use when combining the components of this instance. |

### `==(_:_:)`

```swift
@inlinable public static func ==(lhs: DataDict, rhs: DataDict) -> Bool
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| lhs | A value to compare. |
| rhs | Another value to compare. |