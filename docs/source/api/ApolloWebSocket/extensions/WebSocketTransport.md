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

### `didReceive(event:client:)`

```swift
public func didReceive(event: WebSocketEvent, client: WebSocket)
```

### `handleConnection()`

```swift
public func handleConnection()
```
