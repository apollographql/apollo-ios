**EXTENSION**

# `SplitNetworkTransport`
```swift
extension SplitNetworkTransport: NetworkTransport
```

## Methods
### `send(operation:completionHandler:)`

```swift
public func send<Operation>(operation: Operation, completionHandler: @escaping (Result<GraphQLResponse<Operation>, Error>) -> Void) -> Cancellable
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| operation | The operation to send. |
| completionHandler | A closure to call when a request completes. On `success` will contain the response received from the server. On `failure` will contain the error which occurred. |

### `upload(operation:files:completionHandler:)`

```swift
public func upload<Operation>(operation: Operation,
                              files: [GraphQLFile],
                              completionHandler: @escaping (_ result: Result<GraphQLResponse<Operation>, Error>) -> Void) -> Cancellable
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| operation | The operation to send |
| files | An array of `GraphQLFile` objects to send. |
| completionHandler | The completion handler to execute when the request completes or errors |