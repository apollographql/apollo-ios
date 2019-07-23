**CLASS**

# `WebSocketTransport`

```swift
public class WebSocketTransport
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

### `isConnected()`

```swift
public func isConnected() -> Bool
```

### `ping(data:completionHandler:)`

```swift
public func ping(data: Data, completionHandler: (() -> Void)? = nil)
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
