**ENUM**

# `GraphQLType`

```swift
public indirect enum GraphQLType: Equatable
```

A GraphQL type.

## Cases
### `named(_:)`

```swift
case named(GraphQLNamedType)
```

### `nonNull(_:)`

```swift
case nonNull(GraphQLType)
```

### `list(_:)`

```swift
case list(GraphQLType)
```

## Properties
### `typeReference`

```swift
public var typeReference: String
```
