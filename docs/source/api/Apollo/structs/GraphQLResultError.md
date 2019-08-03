**STRUCT**

# `GraphQLResultError`

```swift
public struct GraphQLResultError: Error, LocalizedError
```

> An error which has occurred in processing a GraphQLResult

## Properties
### `underlying`

```swift
public let underlying: Error
```

> The error that occurred during parsing.

### `errorDescription`

```swift
public var errorDescription: String?
```

> A description of the error which includes the path where the error occurred.
