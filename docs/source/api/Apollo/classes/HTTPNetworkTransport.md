**CLASS**

# `HTTPNetworkTransport`

```swift
public class HTTPNetworkTransport
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

### `upload(operation:files:completionHandler:)`

```swift
public func upload<Operation>(operation: Operation, files: [GraphQLFile], completionHandler: @escaping (_ result: Result<GraphQLResponse<Operation>, Error>) -> Void) -> Cancellable
```

> Uploads the given files with the given operation.
>
> - Parameters:
>   - operation: The operation to send
>   - files: An array of `GraphQLFile` objects to send.
>   - completionHandler: The completion handler to execute when the request completes or errors
> - Returns: An object that can be used to cancel an in progress request.

#### Parameters

| Name | Description |
| ---- | ----------- |
| operation | The operation to send |
| files | An array of `GraphQLFile` objects to send. |
| completionHandler | The completion handler to execute when the request completes or errors |