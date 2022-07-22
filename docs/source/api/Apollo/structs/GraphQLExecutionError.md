**STRUCT**

# `GraphQLExecutionError`

```swift
public struct GraphQLExecutionError: Error, LocalizedError
```

An error which has occurred during GraphQL execution.

## Properties
### `pathString`

```swift
public var pathString: String
```

### `underlying`

```swift
public let underlying: Error
```

The error that occurred during parsing.

### `errorDescription`

```swift
public var errorDescription: String?
```

A description of the error which includes the path where the error occurred.
