**PROTOCOL**

# `WebSocketTransportDelegate`

```swift
public protocol WebSocketTransportDelegate: AnyObject
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
