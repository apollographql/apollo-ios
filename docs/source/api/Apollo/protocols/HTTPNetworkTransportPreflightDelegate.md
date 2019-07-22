**PROTOCOL**

# `HTTPNetworkTransportPreflightDelegate`

```swift
public protocol HTTPNetworkTransportPreflightDelegate: HTTPNetworkTransportDelegate
```

> Methods which will be called prior to a request being sent to the server.

## Methods
### `networkTransport(_:shouldSend:)`

```swift
func networkTransport(_ networkTransport: HTTPNetworkTransport, shouldSend request: URLRequest) -> Bool
```

> Called when a request is about to send, to validate that it should be sent.
> Good for early-exiting if your user is not logged in, for example.
>
> - Parameters:
>   - networkTransport: The network transport which wants to send a request
>   - request: The request, BEFORE it has been modified by `willSend`
> - Returns: True if the request should proceed, false if not.

#### Parameters

| Name | Description |
| ---- | ----------- |
| networkTransport | The network transport which wants to send a request |
| request | The request, BEFORE it has been modified by `willSend` |

### `networkTransport(_:willSend:)`

```swift
func networkTransport(_ networkTransport: HTTPNetworkTransport, willSend request: inout URLRequest)
```

> Called when a request is about to send. Allows last minute modification of any properties on the request,
>
>
> - Parameters:
>   - networkTransport: The network transport which is about to send a request
>   - request: The request, as an `inout` variable for modification

#### Parameters

| Name | Description |
| ---- | ----------- |
| networkTransport | The network transport which is about to send a request |
| request | The request, as an `inout` variable for modification |