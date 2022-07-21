**ENUM**

# `GraphQLType`

```swift
public indirect enum GraphQLType: Hashable
```

A GraphQL type.

## Cases
### `entity(_:)`

```swift
case entity(GraphQLCompositeType)
```

### `scalar(_:)`

```swift
case scalar(GraphQLScalarType)
```

### `enum(_:)`

```swift
case `enum`(GraphQLEnumType)
```

### `inputObject(_:)`

```swift
case inputObject(GraphQLInputObjectType)
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

### `namedType`

```swift
public var namedType: GraphQLNamedType
```

### `innerType`

```swift
public var innerType: GraphQLType
```
