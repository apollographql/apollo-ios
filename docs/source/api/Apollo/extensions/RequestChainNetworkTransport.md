**EXTENSION**

# `RequestChainNetworkTransport`
```swift
extension RequestChainNetworkTransport: UploadingNetworkTransport
```

## Methods
### `constructUploadRequest(for:with:manualBoundary:)`

```swift
open func constructUploadRequest<Operation: GraphQLOperation>(
  for operation: Operation,
  with files: [GraphQLFile],
  manualBoundary: String? = nil) -> HTTPRequest<Operation>
```

Constructs an uploading (ie, multipart) GraphQL request

Override this method if you need to use a custom subclass of `HTTPRequest`.

- Parameters:
  - operation: The operation to create a request for
  - files: The files you wish to upload
  - manualBoundary: [optional] A manually set boundary for your upload request. Defaults to nil. 
- Returns: The created request.

#### Parameters

| Name | Description |
| ---- | ----------- |
| operation | The operation to create a request for |
| files | The files you wish to upload |
| manualBoundary | [optional] A manually set boundary for your upload request. Defaults to nil. |

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