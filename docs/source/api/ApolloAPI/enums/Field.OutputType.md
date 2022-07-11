**ENUM**

# `Field.OutputType`

```swift
public indirect enum OutputType
```

## Cases
### `scalar(_:)`

```swift
case scalar(ScalarType.Type)
```

### `customScalar(_:)`

```swift
case customScalar(CustomScalarType.Type)
```

### `object(_:)`

```swift
case object(RootSelectionSet.Type)
```

### `nonNull(_:)`

```swift
case nonNull(OutputType)
```

### `list(_:)`

```swift
case list(OutputType)
```

## Properties
### `namedType`

```swift
public var namedType: OutputType
```

### `isNullable`

```swift
public var isNullable: Bool
```
