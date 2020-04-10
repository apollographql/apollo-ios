**STRUCT**

# `GraphQLHTTPResponseError`

```swift
public struct GraphQLHTTPResponseError: Error, LocalizedError
```

> A transport-level, HTTP-specific error.

## Properties
### `body`

```swift
public let body: Data?
```

> The body of the response.

### `response`

```swift
public let response: HTTPURLResponse
```

> Information about the response as provided by the server.

### `kind`

```swift
public let kind: ErrorKind
```

### `graphQLErrors`

```swift
public var graphQLErrors: [GraphQLError]?
```

> Any graphQL errors that could be parsed from the response, or nil if none could be parsed.

### `bodyDescription`

```swift
public var bodyDescription: String
```

### `errorDescription`

```swift
public var errorDescription: String?
```

## Methods
### `init(body:response:kind:)`

```swift
public init(body: Data? = nil,
            response: HTTPURLResponse,
            kind: ErrorKind)
```
