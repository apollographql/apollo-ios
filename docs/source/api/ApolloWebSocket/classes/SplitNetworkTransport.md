**CLASS**

# `SplitNetworkTransport`

```swift
public class SplitNetworkTransport
```

> A network transport that sends subscriptions using one `NetworkTransport` and other requests using another `NetworkTransport`. Ideal for sending subscriptions via a web socket but everything else via HTTP.

## Methods
### `init(httpNetworkTransport:webSocketNetworkTransport:)`

```swift
public init(httpNetworkTransport: NetworkTransport, webSocketNetworkTransport: NetworkTransport)
```

> Designated initializer
>
> - Parameters:
>   - httpNetworkTransport: A `NetworkTransport` to use for non-subscription requests. Should generally be a `HTTPNetworkTransport` or something similar.
>   - webSocketNetworkTransport: A `NetworkTransport` to use for subscription requests. Should generally be a `WebSocketTransport` or something similar.

#### Parameters

| Name | Description |
| ---- | ----------- |
| httpNetworkTransport | A `NetworkTransport` to use for non-subscription requests. Should generally be a `HTTPNetworkTransport` or something similar. |
| webSocketNetworkTransport | A `NetworkTransport` to use for subscription requests. Should generally be a `WebSocketTransport` or something similar. |