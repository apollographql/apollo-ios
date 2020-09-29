**EXTENSION**

# `SplitNetworkTransport`
```swift
extension SplitNetworkTransport: NetworkTransport
```

## Methods
### `send(operation:cachePolicy:contextIdentifier:callbackQueue:completionHandler:)`

```swift
public func send<Operation: GraphQLOperation>(operation: Operation,
                                              cachePolicy: CachePolicy,
                                              contextIdentifier: UUID? = nil,
                                              callbackQueue: DispatchQueue = .main,
                                              completionHandler: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void) -> Cancellable
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| operation | The operation to send. |
| cachePolicy | The `CachePolicy` to use making this request. |
| contextIdentifier | [optional] A unique identifier for this request, to help with deduping cache hits for watchers. Defaults to `nil`. |
| callbackQueue | The queue to call back on with the results. Should default to `.main`. |
| completionHandler | A closure to call when a request completes. On `success` will contain the response received from the server. On `failure` will contain the error which occurred. |

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