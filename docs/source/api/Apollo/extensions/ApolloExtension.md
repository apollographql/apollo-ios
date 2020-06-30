**EXTENSION**

# `ApolloExtension`
```swift
public extension ApolloExtension where Base == DispatchQueue
```

## Methods
### `performAsyncIfNeeded(on:action:)`

```swift
static func performAsyncIfNeeded(on callbackQueue: DispatchQueue?, action: @escaping () -> Void)
```

### `returnResultAsyncIfNeeded(on:action:result:)`

```swift
static func returnResultAsyncIfNeeded<T>(on callbackQueue: DispatchQueue?,
                                         action: ((Result<T, Error>) -> Void)?,
                                         result: Result<T, Error>)
```
