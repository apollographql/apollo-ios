**PROTOCOL**

# `WebSocketClient`

```swift
public protocol WebSocketClient: AnyObject
```

Protocol allowing alternative implementations of websockets beyond `ApolloWebSocket`.

## Properties
### `request`

```swift
var request: URLRequest
```

The URLRequest used on connection.

### `delegate`

```swift
var delegate: WebSocketClientDelegate?
```

The delegate that will receive networking event updates for this websocket client.

- Note: The `WebSocketTransport` will set itself as the delgate for the client. Consumers
should set themselves as the delegate for the `WebSocketTransport` to observe events.

### `callbackQueue`

```swift
var callbackQueue: DispatchQueue
```

`DispatchQueue` where the websocket client should call all delegate callbacks.

## Methods
### `connect()`

```swift
func connect()
```

Connects to the websocket server.

- Note: This should be implemented to connect the websocket on a background thread.

### `disconnect()`

```swift
func disconnect()
```

Disconnects from the websocket server.

### `write(ping:completion:)`

```swift
func write(ping: Data, completion: (() -> Void)?)
```

Writes ping data to the websocket.

### `write(string:)`

```swift
func write(string: String)
```

Writes a string to the websocket.
