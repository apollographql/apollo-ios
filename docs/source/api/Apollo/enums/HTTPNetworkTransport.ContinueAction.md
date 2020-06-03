**ENUM**

# `HTTPNetworkTransport.ContinueAction`

```swift
public enum ContinueAction
```

> The action to take when retrying

## Cases
### `retry`

```swift
case retry
```

> Directly retry the action

### `fail(_:)`

```swift
case fail(_ error: Error)
```

> Fail with the specified error.
