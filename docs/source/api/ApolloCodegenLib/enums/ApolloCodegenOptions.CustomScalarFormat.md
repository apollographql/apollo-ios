**ENUM**

# `ApolloCodegenOptions.CustomScalarFormat`

```swift
public enum CustomScalarFormat: Equatable
```

> Enum to select how to handle properties using a custom scalar from the schema.

## Cases
### `none`

```swift
case none
```

> Uses a default type instead of a custom scalar.

### `passthrough`

```swift
case passthrough
```

> Use your own types for custom scalars.

### `passthroughWithPrefix(_:)`

```swift
case passthroughWithPrefix(String)
```

> Use your own types for custom scalars with a prefix.
