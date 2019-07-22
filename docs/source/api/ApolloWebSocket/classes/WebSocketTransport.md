**CLASS**

# `WebSocketTransport`

```swift
public class WebSocketTransport: NetworkTransport, WebSocketDelegate
```

> A network transport that uses web sockets requests to send GraphQL subscription operations to a server, and that uses the Starscream implementation of web sockets.

## Properties
### `delegate`

```swift
public weak var delegate: WebSocketTransportDelegate?
```

## Methods
### `init(request:sendOperationIdentifiers:reconnectionInterval:connectingPayload:)`

```swift
public init(request: URLRequest, sendOperationIdentifiers: Bool = false, reconnectionInterval: TimeInterval = 0.5, connectingPayload: GraphQLMap? = [:])
```

### `send(operation:completionHandler:)`

```swift
public func send<Operation>(operation: Operation, completionHandler: @escaping (_ response: GraphQLResponse<Operation>?, _ error: Error?) -> Void) -> Cancellable
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| operation | The operation to send. |
| completionHandler | A closure to call when a request completes. |
| response | The response received from the server, or `nil` if an error occurred. |
| error | An error that indicates why a request failed, or `nil` if the request was succesful. |

### `isConnected()`

```swift
public func isConnected() -> Bool
```

### `ping(data:completionHandler:)`

```swift
public func ping(data: Data, completionHandler: (() -> Void)? = nil)
```

### `websocketDidConnect(socket:)`

```swift
public func websocketDidConnect(socket: WebSocketClient)
```

### `websocketDidDisconnect(socket:error:)`

```swift
public func websocketDidDisconnect(socket: WebSocketClient, error: Error?)
```

### `websocketDidReceiveMessage(socket:text:)`

```swift
public func websocketDidReceiveMessage(socket: WebSocketClient, text: String)
```

### `websocketDidReceiveData(socket:data:)`

```swift
public func websocketDidReceiveData(socket: WebSocketClient, data: Data)
```

### `initServer(reconnect:)`

```swift
public func initServer(reconnect: Bool = true)
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
