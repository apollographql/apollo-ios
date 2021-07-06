**PROTOCOL**

# `WebSocketClientDelegate`

```swift
public protocol WebSocketClientDelegate: AnyObject
```

The delegate for a `WebSocketClient` to recieve notification of socket events.

## Methods
### `websocketDidConnect(socket:)`

```swift
func websocketDidConnect(socket: WebSocketClient)
```

The websocket client has started a connection to the server.
- Parameter socket: The `WebSocketClient` that sent the delegate event.

#### Parameters

| Name | Description |
| ---- | ----------- |
| socket | The `WebSocketClient` that sent the delegate event. |

### `websocketDidDisconnect(socket:error:)`

```swift
func websocketDidDisconnect(socket: WebSocketClient, error: Error?)
```

The websocket client has disconnected from the server.
- Parameters:
  - socket: The `WebSocketClient` that sent the delegate event.
  - error: An optional error if an error occured.

#### Parameters

| Name | Description |
| ---- | ----------- |
| socket | The `WebSocketClient` that sent the delegate event. |
| error | An optional error if an error occured. |

### `websocketDidReceiveMessage(socket:text:)`

```swift
func websocketDidReceiveMessage(socket: WebSocketClient, text: String)
```

The websocket client received message text from the server
- Parameters:
  - socket: The `WebSocketClient` that sent the delegate event.
  - text: The text received from the server.

#### Parameters

| Name | Description |
| ---- | ----------- |
| socket | The `WebSocketClient` that sent the delegate event. |
| text | The text received from the server. |

### `websocketDidReceiveData(socket:data:)`

```swift
func websocketDidReceiveData(socket: WebSocketClient, data: Data)
```

The websocket client received data from the server
- Parameters:
  - socket: The `WebSocketClient` that sent the delegate event.
  - data: The data received from the server.

#### Parameters

| Name | Description |
| ---- | ----------- |
| socket | The `WebSocketClient` that sent the delegate event. |
| data | The data received from the server. |