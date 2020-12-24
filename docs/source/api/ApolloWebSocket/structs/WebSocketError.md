**STRUCT**

# `WebSocketError`

```swift
public struct WebSocketError: Error, LocalizedError
```

A structure for capturing problems and any associated errors from a `WebSocketTransport`.

## Properties
### `payload`

```swift
public let payload: JSONObject?
```

The payload of the response.

### `error`

```swift
public let error: Error?
```

The underlying error, or nil if one was not returned

### `kind`

```swift
public let kind: ErrorKind
```

The kind of problem which occurred.

### `errorDescription`

```swift
public var errorDescription: String?
```
