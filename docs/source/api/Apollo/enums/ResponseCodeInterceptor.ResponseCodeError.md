**ENUM**

# `ResponseCodeInterceptor.ResponseCodeError`

```swift
public enum ResponseCodeError: Error, LocalizedError
```

## Cases
### `invalidResponseCode(response:rawData:)`

```swift
case invalidResponseCode(response: HTTPURLResponse?, rawData: Data?)
```

## Properties
### `errorDescription`

```swift
public var errorDescription: String?
```
