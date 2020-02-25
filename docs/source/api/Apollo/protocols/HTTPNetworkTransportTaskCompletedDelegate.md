**PROTOCOL**

# `HTTPNetworkTransportTaskCompletedDelegate`

```swift
public protocol HTTPNetworkTransportTaskCompletedDelegate: HTTPNetworkTransportDelegate
```

> Methods which will be called after some kind of response has been received to a `URLSessionTask`.

## Methods
### `networkTransport(_:didCompleteRawTaskForRequest:withData:response:error:)`

```swift
func networkTransport(_ networkTransport: HTTPNetworkTransport,
                      didCompleteRawTaskForRequest request: URLRequest,
                      withData data: Data?,
                      response: URLResponse?,
                      error: Error?)
```

> A callback to allow hooking in URL session responses for things like logging and examining headers.
> NOTE: This will call back on whatever thread the URL session calls back on, which is never the main thread. Call `DispatchQueue.main.async` before touching your UI!
>
> - Parameters:
>   - networkTransport: The network transport that completed a task
>   - request: The request which was completed by the task
>   - data: [optional] Any data received. Passed through from `URLSession`.
>   - response: [optional] Any response received. Passed through from `URLSession`.
>   - error: [optional] Any error received. Passed through from `URLSession`.

#### Parameters

| Name | Description |
| ---- | ----------- |
| networkTransport | The network transport that completed a task |
| request | The request which was completed by the task |
| data | [optional] Any data received. Passed through from `URLSession`. |
| response | [optional] Any response received. Passed through from `URLSession`. |
| error | [optional] Any error received. Passed through from `URLSession`. |