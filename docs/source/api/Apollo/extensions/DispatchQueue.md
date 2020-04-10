**EXTENSION**

# `DispatchQueue`
```swift
public extension DispatchQueue
```

## Methods
### `apollo_performAsyncIfNeeded(on:action:)`

```swift
static func apollo_performAsyncIfNeeded(on callbackQueue: DispatchQueue?, action: @escaping () -> Void)
```

### `apollo_returnResultAsyncIfNeeded(on:action:result:)`

```swift
static func apollo_returnResultAsyncIfNeeded<T>(on callbackQueue: DispatchQueue?,
                                                action: ((Result<T, Error>) -> Void)?,
                                                result: Result<T, Error>)
```
