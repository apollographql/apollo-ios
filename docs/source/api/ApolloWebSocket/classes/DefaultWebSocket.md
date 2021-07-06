**CLASS**

# `DefaultWebSocket`

```swift
public class DefaultWebSocket: WebSocketClient, Starscream.WebSocketDelegate
```

Included default implementation of a `WebSocketClient`, based on `Starscream`'s `WebSocket`.

## Properties
### `request`

```swift
public var request: URLRequest
```

### `delegate`

```swift
public weak var delegate: WebSocketClientDelegate?
```

### `callbackQueue`

```swift
public var callbackQueue: DispatchQueue
```

## Methods
### `init(request:)`

```swift
required public init(request: URLRequest)
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

### `connect()`

```swift
public func connect()
```

### `disconnect()`

```swift
public func disconnect()
```

### `write(ping:completion:)`

```swift
public func write(ping: Data, completion: (() -> Void)?)
```

### `write(string:)`

```swift
public func write(string: String)
```

### `websocketDidConnect(socket:)`

```swift
public func websocketDidConnect(socket: Starscream.WebSocketClient)
```

### `websocketDidDisconnect(socket:error:)`

```swift
public func websocketDidDisconnect(socket: Starscream.WebSocketClient, error: Error?)
```

### `websocketDidReceiveMessage(socket:text:)`

```swift
public func websocketDidReceiveMessage(socket: Starscream.WebSocketClient, text: String)
```

### `websocketDidReceiveData(socket:data:)`

```swift
public func websocketDidReceiveData(socket: Starscream.WebSocketClient, data: Data)
```
