**ENUM**

# `RequestChain.ChainError`

```swift
public enum ChainError: Error, LocalizedError
```

## Cases
### `invalidIndex(chain:index:)`

```swift
case invalidIndex(chain: RequestChain, index: Int)
```

### `noInterceptors`

```swift
case noInterceptors
```

## Properties
### `errorDescription`

```swift
public var errorDescription: String?
```
