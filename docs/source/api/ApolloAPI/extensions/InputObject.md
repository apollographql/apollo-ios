**EXTENSION**

# `InputObject`
```swift
extension InputObject
```

## Properties
### `jsonValue`

```swift
public var jsonValue: JSONValue
```

### `jsonEncodableValue`

```swift
public var jsonEncodableValue: JSONEncodable?
```

## Methods
### `==(_:_:)`

```swift
public static func == (lhs: Self, rhs: Self) -> Bool
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