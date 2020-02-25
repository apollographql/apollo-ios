**EXTENSION**

# `WebSocketTransport`
```swift
extension WebSocketTransport: NetworkTransport
```

## Methods
### `send(operation:completionHandler:)`

```swift
public func send<Operation>(operation: Operation, completionHandler: @escaping (_ result: Result<GraphQLResponse<Operation>,Error>) -> Void) -> Cancellable
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| operation | The operation to send. |
| completionHandler | A closure to call when a request completes. On `success` will contain the response received from the server. On `failure` will contain the error which occurred. |

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
