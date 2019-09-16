**STRUCT**

# `WebSocketError`

```swift
public struct WebSocketError: Error, LocalizedError
```

## Properties
### `payload`

```swift
public let payload: JSONObject?
```

> The payload of the response.

### `error`

```swift
public let error: Error?
```

### `kind`

```swift
public let kind: ErrorKind
```

### `errorDescription`

```swift
public var errorDescription: String?
```
