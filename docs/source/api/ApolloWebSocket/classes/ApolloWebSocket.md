**CLASS**

# `ApolloWebSocket`

```swift
public class ApolloWebSocket: WebSocket, ApolloWebSocketClient
```

Included implementation of an `ApolloWebSocketClient`, based on `Starscream`'s `WebSocket`.

## Methods
### `init(request:certPinner:compressionHandler:)`

```swift
required public init(request: URLRequest,
                     certPinner: CertificatePinning? = FoundationSecurity(),
                     compressionHandler: CompressionHandler? = nil)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| request | The URLRequest to use on connection. |
| certPinner | [optional] The object providing information about certificate pinning. Should default to Starscream’s `FoundationSecurity`. |
| compressionHandler | [optional] The object helping with any compression handling. Should default to nil. |