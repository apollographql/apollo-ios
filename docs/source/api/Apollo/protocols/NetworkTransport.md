**PROTOCOL**

# `NetworkTransport`

```swift
public protocol NetworkTransport: AnyObject
```

A network transport is responsible for sending GraphQL operations to a server.

## Properties
### `clientName`

```swift
var clientName: String
```

The name of the client to send as a header value.

### `clientVersion`

```swift
var clientVersion: String
```

The version of the client to send as a header value.

## Methods
### `send(operation:cachePolicy:contextIdentifier:callbackQueue:completionHandler:)`

```swift
func send<Operation: GraphQLOperation>(operation: Operation,
                                       cachePolicy: CachePolicy,
                                       contextIdentifier: UUID?,
                                       callbackQueue: DispatchQueue,
                                       completionHandler: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) -> Cancellable
```

Send a GraphQL operation to a server and return a response.

Note if you're implementing this yourself rather than using one of the batteries-included versions of `NetworkTransport` (which handle this for you): The `clientName` and `clientVersion` should be sent with any URL request which needs headers so your client can be identified by tools meant to see what client is using which request. The `addApolloClientHeaders` method is provided below to do this for you if you're using Apollo Studio.

- Parameters:
  - operation: The operation to send.
  - cachePolicy: The `CachePolicy` to use making this request.
  - contextIdentifier:  [optional] A unique identifier for this request, to help with deduping cache hits for watchers. Defaults to `nil`.
  - callbackQueue: The queue to call back on with the results. Should default to `.main`.
  - completionHandler: A closure to call when a request completes. On `success` will contain the response received from the server. On `failure` will contain the error which occurred.
- Returns: An object that can be used to cancel an in progress request.

#### Parameters

| Name | Description |
| ---- | ----------- |
| operation | The operation to send. |
| cachePolicy | The `CachePolicy` to use making this request. |
| contextIdentifier | [optional] A unique identifier for this request, to help with deduping cache hits for watchers. Defaults to `nil`. |
| callbackQueue | The queue to call back on with the results. Should default to `.main`. |
| completionHandler | A closure to call when a request completes. On `success` will contain the response received from the server. On `failure` will contain the error which occurred. |