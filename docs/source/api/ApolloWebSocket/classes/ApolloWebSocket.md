**CLASS**

# `ApolloWebSocket`

```swift
public class ApolloWebSocket: WebSocket, ApolloWebSocketClient, SOCKSProxyable
```

> Included implementation of an `ApolloWebSocketClient`, based on `Starscream`'s `WebSocket`.

## Properties
### `enableSOCKSProxy`

```swift
public var enableSOCKSProxy: Bool
```

## Methods
### `init(request:protocols:)`

```swift
required public convenience init(request: URLRequest, protocols: [String]? = nil)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| request | The URLRequest to use on connection. |
| protocols | The supported protocols |