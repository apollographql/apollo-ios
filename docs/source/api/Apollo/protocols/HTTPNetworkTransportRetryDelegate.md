**PROTOCOL**

# `HTTPNetworkTransportRetryDelegate`

```swift
public protocol HTTPNetworkTransportRetryDelegate: HTTPNetworkTransportDelegate
```

> Methods which will be called if an error is receieved at the network level.

## Methods
### `networkTransport(_:receivedError:for:response:retryHandler:)`

```swift
func networkTransport(_ networkTransport: HTTPNetworkTransport,
                      receivedError error: Error,
                      for request: URLRequest,
                      response: URLResponse?,
                      retryHandler: @escaping (_ shouldRetry: Bool) -> Void)
```

> Called when an error has been received after a request has been sent to the server to see if an operation should be retried or not.
> NOTE: Don't just call the `retryHandler` with `true` all the time, or you can potentially wind up in an infinite loop of errors
>
> - Parameters:
>   - networkTransport: The network transport which received the error
>   - error: The received error
>   - request: The URLRequest which generated the error
>   - response: [Optional] Any response received when the error was generated
>   - retryHandler: A closure indicating whether the operation should be retried. Asyncrhonous to allow for re-authentication or other async operations to complete.

#### Parameters

| Name | Description |
| ---- | ----------- |
| networkTransport | The network transport which received the error |
| error | The received error |
| request | The URLRequest which generated the error |
| response | [Optional] Any response received when the error was generated |
| retryHandler | A closure indicating whether the operation should be retried. Asyncrhonous to allow for re-authentication or other async operations to complete. |