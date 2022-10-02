**STRUCT**

# `WebSocketTransport.Configuration`

```swift
public struct Configuration
```

## Properties
### `clientName`

```swift
public fileprivate(set) var clientName: String
```

The client name to use for this client. Defaults to `Self.defaultClientName`

### `clientVersion`

```swift
public fileprivate(set) var clientVersion: String
```

The client version to use for this client. Defaults to `Self.defaultClientVersion`.

### `reconnect`

```swift
public let reconnect: Atomic<Bool>
```

Whether to auto reconnect when websocket looses connection. Defaults to true.

### `reconnectionInterval`

```swift
public let reconnectionInterval: TimeInterval
```

How long to wait before attempting to reconnect. Defaults to half a second.

### `allowSendingDuplicates`

```swift
public let allowSendingDuplicates: Bool
```

Allow sending duplicate messages. Important when reconnected. Defaults to true.

### `connectOnInit`

```swift
public let connectOnInit: Bool
```

Whether the websocket connects immediately on creation.
If false, remember to call `resumeWebSocketConnection()` to connect.
Defaults to true.

### `connectingPayload`

```swift
public fileprivate(set) var connectingPayload: JSONEncodableDictionary?
```

[optional]The payload to send on connection. Defaults to an empty `JSONEncodableDictionary`.

### `requestBodyCreator`

```swift
public let requestBodyCreator: RequestBodyCreator
```

The `RequestBodyCreator` to use when serializing requests. Defaults to an `ApolloRequestBodyCreator`.

### `operationMessageIdCreator`

```swift
public let operationMessageIdCreator: OperationMessageIdCreator
```

The `OperationMessageIdCreator` used to generate a unique message identifier per request.
Defaults to `ApolloSequencedOperationMessageIdCreator`.

## Methods
### `init(clientName:clientVersion:reconnect:reconnectionInterval:allowSendingDuplicates:connectOnInit:connectingPayload:requestBodyCreator:operationMessageIdCreator:)`

```swift
public init(
  clientName: String = WebSocketTransport.defaultClientName,
  clientVersion: String = WebSocketTransport.defaultClientVersion,
  reconnect: Bool = true,
  reconnectionInterval: TimeInterval = 0.5,
  allowSendingDuplicates: Bool = true,
  connectOnInit: Bool = true,
  connectingPayload: JSONEncodableDictionary? = [:],
  requestBodyCreator: RequestBodyCreator = ApolloRequestBodyCreator(),
  operationMessageIdCreator: OperationMessageIdCreator = ApolloSequencedOperationMessageIdCreator()
)
```

The designated initializer
