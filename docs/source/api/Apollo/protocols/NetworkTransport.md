**PROTOCOL**

# `NetworkTransport`

```swift
public protocol NetworkTransport: class
```

> A network transport is responsible for sending GraphQL operations to a server.

## Properties
### `clientName`

```swift
var clientName: String
```

> The name of the client to send as a header value.

### `clientVersion`

```swift
var clientVersion: String
```

> The version of the client to send as a header value.

## Methods
### `send(operation:completionHandler:)`

```swift
func send<Operation: GraphQLOperation>(operation: Operation, completionHandler: @escaping (_ result: Result<GraphQLResponse<Operation.Data>, Error>) -> Void) -> Cancellable
```

> Send a GraphQL operation to a server and return a response.
>
> Note if you're implementing this yourself rather than using one of the batteries-included versions of `NetworkTransport` (which handle this for you): The `clientName` and `clientVersion` should be sent with any URL request which needs headers so your client can be identified by tools meant to see what client is using which request. The `addApolloClientHeaders` method is provided below to do this for you if you're using Apollo Graph Manager.
>
> - Parameters:
>   - operation: The operation to send.
>   - completionHandler: A closure to call when a request completes. On `success` will contain the response received from the server. On `failure` will contain the error which occurred.
> - Returns: An object that can be used to cancel an in progress request.

#### Parameters

| Name | Description |
| ---- | ----------- |
| operation | The operation to send. |
| completionHandler | A closure to call when a request completes. On `success` will contain the response received from the server. On `failure` will contain the error which occurred. |