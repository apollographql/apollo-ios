**PROTOCOL**

# `UploadingNetworkTransport`

```swift
public protocol UploadingNetworkTransport: NetworkTransport
```

> A network transport which can also handle uploads of files.

## Methods
### `upload(operation:files:completionHandler:)`

```swift
func upload<Operation>(operation: Operation, files: [GraphQLFile], completionHandler: @escaping (_ result: Result<GraphQLResponse<Operation>, Error>) -> Void) -> Cancellable
```

> Uploads the given files with the given operation.
>
> - Parameters:
>   - operation: The operation to send
>   - files: An array of `GraphQLFile` objects to send.
>   - completionHandler: The completion handler to execute when the request completes or errors
> - Returns: An object that can be used to cancel an in progress request.

#### Parameters

| Name | Description |
| ---- | ----------- |
| operation | The operation to send |
| files | An array of `GraphQLFile` objects to send. |
| completionHandler | The completion handler to execute when the request completes or errors |