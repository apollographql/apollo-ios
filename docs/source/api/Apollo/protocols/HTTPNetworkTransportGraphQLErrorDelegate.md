**PROTOCOL**

# `HTTPNetworkTransportGraphQLErrorDelegate`

```swift
public protocol HTTPNetworkTransportGraphQLErrorDelegate: HTTPNetworkTransportDelegate
```

> Methods which will be called after some kind of response has been received and it contains GraphQLErrors.

## Methods
### `networkTransport(_:receivedGraphQLErrors:retryHandler:)`

```swift
func networkTransport(_ networkTransport: HTTPNetworkTransport,
                      receivedGraphQLErrors errors: [GraphQLError],
                      retryHandler: @escaping (_ shouldRetry: Bool) -> Void)
```

> Called when response contains one or more GraphQL errors.
>
> NOTE: The mere presence of a GraphQL error does not necessarily mean a request failed!
>       GraphQL is design to allow partial success/failures to return, so make sure
>       you're validating the *type* of error you're getting in this before deciding whether to retry or not.
>
> ALSO NOTE: Don't just call the `retryHandler` with `true` all the time, or you can
>            potentially wind up in an infinite loop of errors
>
> - Parameters:
>   - networkTransport: The network transport which received the error
>   - errors: The received GraphQL errors
>   - retryHandler: A closure indicating whether the operation should be retried. Asyncrhonous to allow for re-authentication or other async operations to complete.

#### Parameters

| Name | Description |
| ---- | ----------- |
| networkTransport | The network transport which received the error |
| errors | The received GraphQL errors |
| retryHandler | A closure indicating whether the operation should be retried. Asyncrhonous to allow for re-authentication or other async operations to complete. |