**EXTENSION**

# `GraphQLOperation`
```swift
public extension GraphQLOperation
```

## Properties
### `variables`

```swift
var variables: Variables?
```

### `definition`

```swift
static var definition: OperationDefinition?
```

### `operationIdentifier`

```swift
static var operationIdentifier: String?
```

## Methods
### `==(_:_:)`

```swift
static func ==(lhs: Self, rhs: Self) -> Bool
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| lhs | A value to compare. |
| rhs | Another value to compare. |

### `hash(into:)`

```swift
func hash(into hasher: inout Hasher)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| hasher | The hasher to use when combining the components of this instance. |