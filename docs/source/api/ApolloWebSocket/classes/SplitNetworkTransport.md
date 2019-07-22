**CLASS**

# `SplitNetworkTransport`

```swift
public class SplitNetworkTransport: NetworkTransport
```

## Methods
### `init(httpNetworkTransport:webSocketNetworkTransport:)`

```swift
public init(httpNetworkTransport: NetworkTransport, webSocketNetworkTransport: NetworkTransport)
```

### `send(operation:completionHandler:)`

```swift
public func send<Operation>(operation: Operation, completionHandler: @escaping (GraphQLResponse<Operation>?, Error?) -> Void) -> Cancellable
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| operation | The operation to send. |
| completionHandler | A closure to call when a request completes. |
| response | The response received from the server, or `nil` if an error occurred. |
| error | An error that indicates why a request failed, or `nil` if the request was succesful. |