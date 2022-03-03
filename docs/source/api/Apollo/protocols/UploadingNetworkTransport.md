**PROTOCOL**

# `UploadingNetworkTransport`

```swift
public protocol UploadingNetworkTransport: NetworkTransport
```

A network transport which can also handle uploads of files.

## Methods
### `upload(operation:files:callbackQueue:completionHandler:)`

```swift
func upload<Operation: GraphQLOperation>(
  operation: Operation,
  files: [GraphQLFile],
  callbackQueue: DispatchQueue,
  completionHandler: @escaping (Result<GraphQLResult<Operation.Data>,Error>) -> Void) -> Cancellable
```

Uploads the given files with the given operation.

- Parameters:
  - operation: The operation to send
  - files: An array of `GraphQLFile` objects to send.
  - callbackQueue: The queue to call back on with the results. Should default to `.main`.
  - completionHandler: The completion handler to execute when the request completes or errors
- Returns: An object that can be used to cancel an in progress request.

#### Parameters

| Name | Description |
| ---- | ----------- |
| operation | The operation to send |
| files | An array of `GraphQLFile` objects to send. |
| callbackQueue | The queue to call back on with the results. Should default to `.main`. |
| completionHandler | The completion handler to execute when the request completes or errors |