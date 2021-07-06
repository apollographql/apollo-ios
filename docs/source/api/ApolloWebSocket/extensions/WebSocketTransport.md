**EXTENSION**

# `WebSocketTransport`
```swift
extension WebSocketTransport: NetworkTransport
```

## Methods
### `send(operation:cachePolicy:contextIdentifier:callbackQueue:completionHandler:)`

```swift
public func send<Operation: GraphQLOperation>(
  operation: Operation,
  cachePolicy: CachePolicy,
  contextIdentifier: UUID? = nil,
  callbackQueue: DispatchQueue = .main,
  completionHandler: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) -> Cancellable
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| operation | The operation to send. |
| cachePolicy | The `CachePolicy` to use making this request. |
| contextIdentifier | [optional] A unique identifier for this request, to help with deduping cache hits for watchers. Defaults to `nil`. |
| callbackQueue | The queue to call back on with the results. Should default to `.main`. |
| completionHandler | A closure to call when a request completes. On `success` will contain the response received from the server. On `failure` will contain the error which occurred. |

### `websocketDidConnect(socket:)`

```swift
public func websocketDidConnect(socket: WebSocketClient)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| socket | The `WebSocketClient` that sent the delegate event. |

### `handleConnection()`

```swift
public func handleConnection()
```

### `websocketDidDisconnect(socket:error:)`

```swift
public func websocketDidDisconnect(socket: WebSocketClient, error: Error?)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| socket | The `WebSocketClient` that sent the delegate event. |
| error | An optional error if an error occured. |

### `websocketDidReceiveMessage(socket:text:)`

```swift
public func websocketDidReceiveMessage(socket: WebSocketClient, text: String)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| socket | The `WebSocketClient` that sent the delegate event. |
| text | The text received from the server. |

### `websocketDidReceiveData(socket:data:)`

```swift
public func websocketDidReceiveData(socket: WebSocketClient, data: Data)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| socket | The `WebSocketClient` that sent the delegate event. |
| data | The data received from the server. |