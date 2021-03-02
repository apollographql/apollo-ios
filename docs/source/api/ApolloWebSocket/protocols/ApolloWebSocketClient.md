**PROTOCOL**

# `ApolloWebSocketClient`

```swift
public protocol ApolloWebSocketClient: WebSocketClient
```

Protocol allowing alternative implementations of web sockets beyond `ApolloWebSocket`. Extends `Starscream`'s `WebSocketClient` protocol.

## Properties
### `request`

```swift
var request: URLRequest
```

The URLRequest used on connection.

### `callbackQueue`

```swift
var callbackQueue: DispatchQueue
```

Queue where the callbacks are executed

### `delegate`

```swift
var delegate: WebSocketDelegate?
```

## Methods
### `init(request:certPinner:compressionHandler:)`

```swift
init(request: URLRequest,
     certPinner: CertificatePinning?,
     compressionHandler: CompressionHandler?)
```

Required initializer

- Parameters:
  - request: The URLRequest to use on connection.
  - certPinner: [optional] The object providing information about certificate pinning. Should default to Starscream's `FoundationSecurity`.
  - compressionHandler: [optional] The object helping with any compression handling. Should default to nil.

#### Parameters

| Name | Description |
| ---- | ----------- |
| request | The URLRequest to use on connection. |
| certPinner | [optional] The object providing information about certificate pinning. Should default to Starscream’s `FoundationSecurity`. |
| compressionHandler | [optional] The object helping with any compression handling. Should default to nil. |