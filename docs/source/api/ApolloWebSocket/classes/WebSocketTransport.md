**CLASS**

# `WebSocketTransport`

```swift
public class WebSocketTransport
```

A network transport that uses web sockets requests to send GraphQL subscription operations to a server.

## Properties
### `delegate`

```swift
public weak var delegate: WebSocketTransportDelegate?
```

### `clientName`

```swift
public var clientName: String
```

- NOTE: Setting this won't override immediately if the socket is still connected, only on reconnection.

### `clientVersion`

```swift
public var clientVersion: String
```

- NOTE: Setting this won't override immediately if the socket is still connected, only on reconnection.

## Methods
### `init(websocket:store:config:)`

```swift
public init(
  websocket: WebSocketClient,
  store: ApolloStore? = nil,
  config: Configuration = Configuration()
)
```

Designated initializer

- Parameters:
  - websocket: The websocket client to use for creating a websocket connection.
  - store: [optional] The `ApolloStore` used as a local cache.
  - config: A `WebSocketTransport.Configuration` object with options for configuring the
            web socket connection. Defaults to a configuration with default values.

#### Parameters

| Name | Description |
| ---- | ----------- |
| websocket | The websocket client to use for creating a websocket connection. |
| store | [optional] The `ApolloStore` used as a local cache. |
| config | A `WebSocketTransport.Configuration` object with options for configuring the web socket connection. Defaults to a configuration with default values. |

### `isConnected()`

```swift
public func isConnected() -> Bool
```

### `ping(data:completionHandler:)`

```swift
public func ping(data: Data, completionHandler: (() -> Void)? = nil)
```

### `initServer()`

```swift
public func initServer()
```

### `closeConnection()`

```swift
public func closeConnection()
```

### `deinit`

```swift
deinit
```

### `unsubscribe(_:)`

```swift
public func unsubscribe(_ subscriptionId: String)
```

### `updateHeaderValues(_:reconnectIfConnected:)`

```swift
public func updateHeaderValues(_ values: [String: String?], reconnectIfConnected: Bool = true)
```

### `updateConnectingPayload(_:reconnectIfConnected:)`

```swift
public func updateConnectingPayload(_ payload: JSONEncodableDictionary, reconnectIfConnected: Bool = true)
```

### `pauseWebSocketConnection()`

```swift
public func pauseWebSocketConnection()
```

Disconnects the websocket while setting the auto-reconnect value to false,
allowing purposeful disconnects that do not dump existing subscriptions.
NOTE: You will receive an error on the subscription (should be a `WebSocket.WSError` with code 1000) when the socket disconnects.
ALSO NOTE: To reconnect after calling this, you will need to call `resumeWebSocketConnection`.

### `resumeWebSocketConnection(autoReconnect:)`

```swift
public func resumeWebSocketConnection(autoReconnect: Bool = true)
```

Reconnects a paused web socket.

- Parameter autoReconnect: `true` if you want the websocket to automatically reconnect if the connection drops. Defaults to true.

#### Parameters

| Name | Description |
| ---- | ----------- |
| autoReconnect | `true` if you want the websocket to automatically reconnect if the connection drops. Defaults to true. |