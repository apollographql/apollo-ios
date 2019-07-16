**CLASS**

# `HTTPNetworkTransport`

```swift
public class HTTPNetworkTransport: NetworkTransport
```

> A network transport that uses HTTP POST requests to send GraphQL operations to a server, and that uses `URLSession` as the networking implementation.

## Methods
### `init(url:configuration:sendOperationIdentifiers:useGETForQueries:delegate:)`

```swift
public init(url: URL,
            configuration: URLSessionConfiguration = .default,
            sendOperationIdentifiers: Bool = false,
            useGETForQueries: Bool = false,
            delegate: HTTPNetworkTransportDelegate? = nil)
```

> Creates a network transport with the specified server URL and session configuration.
>
> - Parameters:
>   - url: The URL of a GraphQL server to connect to.
>   - configuration: A session configuration used to configure the session. Defaults to `URLSessionConfiguration.default`.
>   - sendOperationIdentifiers: Whether to send operation identifiers rather than full operation text, for use with servers that support query persistence. Defaults to false.
>   - useGETForQueries: If query operation should be sent using GET instead of POST. Defaults to false.
>   - delegate: [Optional] A delegate which can conform to any or all of `HTTPNetworkTransportPreflightDelegate`, `HTTPNetworkTransportTaskCompletedDelegate`, and `HTTPNetworkTransportRetryDelegate`. Defaults to nil.

#### Parameters

| Name | Description |
| ---- | ----------- |
| url | The URL of a GraphQL server to connect to. |
| configuration | A session configuration used to configure the session. Defaults to `URLSessionConfiguration.default`. |
| sendOperationIdentifiers | Whether to send operation identifiers rather than full operation text, for use with servers that support query persistence. Defaults to false. |
| useGETForQueries | If query operation should be sent using GET instead of POST. Defaults to false. |
| delegate | [Optional] A delegate which can conform to any or all of `HTTPNetworkTransportPreflightDelegate`, `HTTPNetworkTransportTaskCompletedDelegate`, and `HTTPNetworkTransportRetryDelegate`. Defaults to nil. |

### `send(operation:completionHandler:)`

```swift
public func send<Operation>(operation: Operation, completionHandler: @escaping (_ response: GraphQLResponse<Operation>?, _ error: Error?) -> Void) -> Cancellable
```

> Send a GraphQL operation to a server and return a response.
>
> - Parameters:
>   - operation: The operation to send.
>   - completionHandler: A closure to call when a request completes.
>   - response: The response received from the server, or `nil` if an error occurred.
>   - error: An error that indicates why a request failed, or `nil` if the request was succesful.
> - Returns: An object that can be used to cancel an in progress request.

#### Parameters

| Name | Description |
| ---- | ----------- |
| operation | The operation to send. |
| completionHandler | A closure to call when a request completes. |
| response | The response received from the server, or `nil` if an error occurred. |
| error | An error that indicates why a request failed, or `nil` if the request was succesful. |