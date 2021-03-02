**CLASS**

# `WebSocketTransport`

```swift
public class WebSocketTransport
```

A network transport that uses web sockets requests to send GraphQL subscription operations to a server, and that uses the Starscream implementation of web sockets.

## Properties
### `delegate`

```swift
public weak var delegate: WebSocketTransportDelegate?
```

### `clientName`

```swift
public var clientName: String
```

NOTE: Setting this won't override immediately if the socket is still connected, only on reconnection.

### `clientVersion`

```swift
public var clientVersion: String
```

NOTE: Setting this won't override immediately if the socket is still connected, only on reconnection.

## Methods
### `init(request:clientName:clientVersion:sendOperationIdentifiers:reconnect:reconnectionInterval:allowSendingDuplicates:connectOnInit:connectingPayload:requestBodyCreator:certPinner:compressionHandler:)`

```swift
public init(request: URLRequest,
            clientName: String = WebSocketTransport.defaultClientName,
            clientVersion: String = WebSocketTransport.defaultClientVersion,
            sendOperationIdentifiers: Bool = false,
            reconnect: Bool = true,
            reconnectionInterval: TimeInterval = 0.5,
            allowSendingDuplicates: Bool = true,
            connectOnInit: Bool = true,
            connectingPayload: GraphQLMap? = [:],
            requestBodyCreator: RequestBodyCreator = ApolloRequestBodyCreator(),
            certPinner: CertificatePinning? = FoundationSecurity(),
            compressionHandler: CompressionHandler? = nil)
```

Designated initializer

- Parameters:
  - request: The connection URLRequest
  - clientName: The client name to use for this client. Defaults to `Self.defaultClientName`
  - clientVersion: The client version to use for this client. Defaults to `Self.defaultClientVersion`.
  - sendOperationIdentifiers: Whether or not to send operation identifiers with operations. Defaults to false.
  - reconnect: Whether to auto reconnect when websocket looses connection. Defaults to true.
  - reconnectionInterval: How long to wait before attempting to reconnect. Defaults to half a second.
  - allowSendingDuplicates: Allow sending duplicate messages. Important when reconnected. Defaults to true.
 - connectOnInit: Whether the websocket connects immediately on creation. If false, remember to call `resumeWebSocketConnection()` to connect. Defaults to true.
  - connectingPayload: [optional] The payload to send on connection. Defaults to an empty `GraphQLMap`.
  - requestBodyCreator: The `RequestBodyCreator` to use when serializing requests. Defaults to an `ApolloRequestBodyCreator`.
  - certPinner: [optional] The object providing information about certificate pinning. Should default to Starscream's `FoundationSecurity`.
  - compressionHandler: [optional] The object helping with any compression handling. Should default to nil.

#### Parameters

| Name | Description |
| ---- | ----------- |
| request | The connection URLRequest |
| clientName | The client name to use for this client. Defaults to `Self.defaultClientName` |
| clientVersion | The client version to use for this client. Defaults to `Self.defaultClientVersion`. |
| sendOperationIdentifiers | Whether or not to send operation identifiers with operations. Defaults to false. |
| reconnect | Whether to auto reconnect when websocket looses connection. Defaults to true. |
| reconnectionInterval | How long to wait before attempting to reconnect. Defaults to half a second. |
| allowSendingDuplicates | Allow sending duplicate messages. Important when reconnected. Defaults to true. |

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

### `updateHeaderValues(_:)`

```swift
public func updateHeaderValues(_ values: [String: String?])
```

### `updateConnectingPayload(_:)`

```swift
public func updateConnectingPayload(_ payload: GraphQLMap)
```

### `pauseWebSocketConnection()`

```swift
public func pauseWebSocketConnection()
```

Disconnects the websocket while setting the auto-reconnect value to false,
allowing purposeful disconnects that do not dump existing subscriptions.
NOTE: You will receive an error on the subscription (should be a `Starscream.WSError` with code 1000) when the socket disconnects.
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