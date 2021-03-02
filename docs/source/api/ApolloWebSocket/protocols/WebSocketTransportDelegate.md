**PROTOCOL**

# `WebSocketTransportDelegate`

```swift
public protocol WebSocketTransportDelegate: class
```

## Methods
### `webSocketTransportDidConnect(_:)`

```swift
func webSocketTransportDidConnect(_ webSocketTransport: WebSocketTransport)
```

### `webSocketTransportDidReconnect(_:)`

```swift
func webSocketTransportDidReconnect(_ webSocketTransport: WebSocketTransport)
```

### `webSocketTransport(_:didDisconnectWithError:)`

```swift
func webSocketTransport(_ webSocketTransport: WebSocketTransport, didDisconnectWithError error:Error?)
```

### `webSocketTransport(_:didReceivePingData:)`

```swift
func webSocketTransport(_ webSocketTransport: WebSocketTransport, didReceivePingData: Data?)
```

### `webSocketTransport(_:didReceivePongData:)`

```swift
func webSocketTransport(_ webSocketTransport: WebSocketTransport, didReceivePongData: Data?)
```
