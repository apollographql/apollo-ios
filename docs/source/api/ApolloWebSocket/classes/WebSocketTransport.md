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

### `clientName`

```swift
public var clientName: String
```

> NOTE: Setting this won't override immediately if the socket is still connected, only on reconnection.

### `clientVersion`

```swift
public var clientVersion: String
```

> NOTE: Setting this won't override immediately if the socket is still connected, only on reconnection.

## Methods
### `init(request:clientName:clientVersion:sendOperationIdentifiers:reconnectionInterval:connectingPayload:requestCreator:)`

```swift
public init(request: URLRequest,
            clientName: String = WebSocketTransport.defaultClientName,
            clientVersion: String = WebSocketTransport.defaultClientVersion,
            sendOperationIdentifiers: Bool = false,
            reconnectionInterval: TimeInterval = 0.5,
            connectingPayload: GraphQLMap? = [:],
            requestCreator: RequestCreator = ApolloRequestCreator())
```

> Designated initializer
>
> - Parameter request: The connection URLRequest
> - Parameter clientName: The client name to use for this client. Defaults to `Self.defaultClientName`
> - Parameter clientVersion: The client version to use for this client. Defaults to `Self.defaultClientVersion`.
> - Parameter sendOperationIdentifiers: Whether or not to send operation identifiers with operations. Defaults to false.
> - Parameter reconnectionInterval: How long to wait before attempting to reconnect. Defaults to half a second.
> - Parameter connectingPayload: [optional] The payload to send on connection. Defaults to an empty `GraphQLMap`.
> - Parameter requestCreator: The request creator to use when serializing requests. Defaults to an `ApolloRequestCreator`.

#### Parameters

| Name | Description |
| ---- | ----------- |
| request | The connection URLRequest |
| clientName | The client name to use for this client. Defaults to `Self.defaultClientName` |
| clientVersion | The client version to use for this client. Defaults to `Self.defaultClientVersion`. |
| sendOperationIdentifiers | Whether or not to send operation identifiers with operations. Defaults to false. |
| reconnectionInterval | How long to wait before attempting to reconnect. Defaults to half a second. |
| connectingPayload | [optional] The payload to send on connection. Defaults to an empty `GraphQLMap`. |
| requestCreator | The request creator to use when serializing requests. Defaults to an `ApolloRequestCreator`. |

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
