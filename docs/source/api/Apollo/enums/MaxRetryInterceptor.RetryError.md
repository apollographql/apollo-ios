**ENUM**

# `MaxRetryInterceptor.RetryError`

```swift
public enum RetryError: Error, LocalizedError
```

## Cases
### `hitMaxRetryCount(count:operationName:)`

```swift
case hitMaxRetryCount(count: Int, operationName: String)
```

## Properties
### `errorDescription`

```swift
public var errorDescription: String?
```
