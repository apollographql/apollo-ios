**PROTOCOL**

# `ApolloWebSocketClient`

```swift
public protocol ApolloWebSocketClient: WebSocketClient
```

> Protocol allowing alternative implementations of web sockets beyond `ApolloWebSocket`. Extends `Starscream`'s `WebSocketClient` protocol.

## Properties
### `request`

```swift
var request: URLRequest
```

> The URLRequest used on connection.

### `callbackQueue`

```swift
var callbackQueue: DispatchQueue
```

> Queue where the callbacks are executed

## Methods
### `init(request:protocols:)`

```swift
init(request: URLRequest, protocols: [String]?)
```

> Required initializer
>
> - Parameter request: The URLRequest to use on connection.
> - Parameter protocols: The supported protocols

#### Parameters

| Name | Description |
| ---- | ----------- |
| request | The URLRequest to use on connection. |
| protocols | The supported protocols |