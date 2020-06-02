**ENUM**

# `URLSessionClient.URLSessionClientError`

```swift
public enum URLSessionClientError: Error
```

## Cases
### `noHTTPResponse(request:)`

```swift
case noHTTPResponse(request: URLRequest?)
```

### `sessionBecameInvalidWithoutUnderlyingError`

```swift
case sessionBecameInvalidWithoutUnderlyingError
```

### `dataForRequestNotFound(request:)`

```swift
case dataForRequestNotFound(request: URLRequest?)
```

### `networkError(data:response:underlying:)`

```swift
case networkError(data: Data, response: HTTPURLResponse?, underlying: Error)
```
