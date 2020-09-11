**EXTENSION**

# `RequestChainNetworkTransport`
```swift
extension RequestChainNetworkTransport: UploadingNetworkTransport
```

## Methods
### `upload(operation:files:callbackQueue:completionHandler:)`

```swift
public func upload<Operation: GraphQLOperation>(
  operation: Operation,
  files: [GraphQLFile],
  callbackQueue: DispatchQueue = .main,
  completionHandler: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) -> Cancellable
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| operation | The operation to send |
| files | An array of `GraphQLFile` objects to send. |
| callbackQueue | The queue to call back on with the results. Should default to `.main`. |
| completionHandler | The completion handler to execute when the request completes or errors |