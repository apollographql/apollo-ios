**STRUCT**

# `GraphQLError`

```swift
public struct GraphQLError: Error, Hashable
```

Represents an error encountered during the execution of a GraphQL operation.

 - SeeAlso: [The Response Format section in the GraphQL specification](https://facebook.github.io/graphql/#sec-Response-Format)

## Properties
### `message`

```swift
public var message: String?
```

A description of the error.

### `locations`

```swift
public var locations: [Location]?
```

A list of locations in the requested GraphQL document associated with the error.

### `extensions`

```swift
public var extensions: [String : Any]?
```

A dictionary which services can use however they see fit to provide additional information in errors to clients.

## Methods
### `init(_:)`

```swift
public init(_ object: JSONObject)
```
