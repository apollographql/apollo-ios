**CLASS**

# `HTTPNetworkTransport`

```swift
public class HTTPNetworkTransport
```

> A network transport that uses HTTP POST requests to send GraphQL operations to a server, and that uses `URLSession` as the networking implementation.

## Properties
### `delegate`

```swift
public weak var delegate: HTTPNetworkTransportDelegate?
```

> A delegate which can conform to any or all of `HTTPNetworkTransportPreflightDelegate`, `HTTPNetworkTransportTaskCompletedDelegate`, and `HTTPNetworkTransportRetryDelegate`.

### `clientName`

```swift
public lazy var clientName = HTTPNetworkTransport.defaultClientName
```

### `clientVersion`

```swift
public lazy var clientVersion = HTTPNetworkTransport.defaultClientVersion
```

## Methods
### `init(url:client:sendOperationIdentifiers:useGETForQueries:enableAutoPersistedQueries:useGETForPersistedQueryRetry:requestCreator:)`

```swift
public init(url: URL,
            client: URLSessionClient = URLSessionClient(),
            sendOperationIdentifiers: Bool = false,
            useGETForQueries: Bool = false,
            enableAutoPersistedQueries: Bool = false,
            useGETForPersistedQueryRetry: Bool = false,
            requestCreator: RequestCreator = ApolloRequestCreator())
```

> Creates a network transport with the specified server URL and session configuration.
>
> - Parameters:
>   - url: The URL of a GraphQL server to connect to.
>   - client: The client to handle URL Session calls.
>   - sendOperationIdentifiers: Whether to send operation identifiers rather than full operation text, for use with servers that support query persistence. Defaults to false.
>   - useGETForQueries: If query operation should be sent using GET instead of POST. Defaults to false.
>   - enableAutoPersistedQueries: Whether to send persistedQuery extension. QueryDocument will be absent at 1st request, retry with QueryDocument if server respond PersistedQueryNotFound or PersistedQueryNotSupport. Defaults to false.
>   - useGETForPersistedQueryRetry: Whether to retry persistedQuery request with HttpGetMethod. Defaults to false.

#### Parameters

| Name | Description |
| ---- | ----------- |
| url | The URL of a GraphQL server to connect to. |
| client | The client to handle URL Session calls. |
| sendOperationIdentifiers | Whether to send operation identifiers rather than full operation text, for use with servers that support query persistence. Defaults to false. |
| useGETForQueries | If query operation should be sent using GET instead of POST. Defaults to false. |
| enableAutoPersistedQueries | Whether to send persistedQuery extension. QueryDocument will be absent at 1st request, retry with QueryDocument if server respond PersistedQueryNotFound or PersistedQueryNotSupport. Defaults to false. |
| useGETForPersistedQueryRetry | Whether to retry persistedQuery request with HttpGetMethod. Defaults to false. |