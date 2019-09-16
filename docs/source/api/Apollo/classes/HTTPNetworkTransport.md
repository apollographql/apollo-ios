**CLASS**

# `HTTPNetworkTransport`

```swift
public class HTTPNetworkTransport
```

> A network transport that uses HTTP POST requests to send GraphQL operations to a server, and that uses `URLSession` as the networking implementation.

## Methods
### `init(url:session:sendOperationIdentifiers:useGETForQueries:delegate:)`

```swift
public init(url: URL,
            session: URLSession = .shared,
            sendOperationIdentifiers: Bool = false,
            useGETForQueries: Bool = false,
            delegate: HTTPNetworkTransportDelegate? = nil)
```

> Creates a network transport with the specified server URL and session configuration.
>
> - Parameters:
>   - url: The URL of a GraphQL server to connect to.
>   - session: The URLSession to use. Defaults to `URLSession.shared`,
>   - sendOperationIdentifiers: Whether to send operation identifiers rather than full operation text, for use with servers that support query persistence. Defaults to false.
>   - useGETForQueries: If query operation should be sent using GET instead of POST. Defaults to false.
>   - delegate: [Optional] A delegate which can conform to any or all of `HTTPNetworkTransportPreflightDelegate`, `HTTPNetworkTransportTaskCompletedDelegate`, and `HTTPNetworkTransportRetryDelegate`. Defaults to nil.

#### Parameters

| Name | Description |
| ---- | ----------- |
| url | The URL of a GraphQL server to connect to. |
| session | The URLSession to use. Defaults to `URLSession.shared`, |
| sendOperationIdentifiers | Whether to send operation identifiers rather than full operation text, for use with servers that support query persistence. Defaults to false. |
| useGETForQueries | If query operation should be sent using GET instead of POST. Defaults to false. |
| delegate | [Optional] A delegate which can conform to any or all of `HTTPNetworkTransportPreflightDelegate`, `HTTPNetworkTransportTaskCompletedDelegate`, and `HTTPNetworkTransportRetryDelegate`. Defaults to nil. |