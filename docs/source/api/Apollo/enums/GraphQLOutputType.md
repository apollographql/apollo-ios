**ENUM**

# `GraphQLOutputType`

```swift
public indirect enum GraphQLOutputType
```

## Cases
### `scalar(_:)`

```swift
case scalar(JSONDecodable.Type)
```

### `object(_:)`

```swift
case object([GraphQLSelection])
```

### `nonNull(_:)`

```swift
case nonNull(GraphQLOutputType)
```

### `list(_:)`

```swift
case list(GraphQLOutputType)
```
