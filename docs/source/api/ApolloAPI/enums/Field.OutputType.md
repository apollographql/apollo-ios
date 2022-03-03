**ENUM**

# `Field.OutputType`

```swift
public indirect enum OutputType
```

## Cases
### `scalar(_:)`

```swift
case scalar(Any.Type)
```

### `object(_:)`

```swift
case object([Selection])
```

### `nonNull(_:)`

```swift
case nonNull(OutputType)
```

### `list(_:)`

```swift
case list(OutputType)
```
