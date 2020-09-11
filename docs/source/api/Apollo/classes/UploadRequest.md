**CLASS**

# `UploadRequest`

```swift
public class UploadRequest<Operation: GraphQLOperation>: HTTPRequest<Operation>
```

> A request class allowing for a multipart-upload request.

## Properties
### `requestCreator`

```swift
public let requestCreator: RequestCreator
```

### `files`

```swift
public let files: [GraphQLFile]
```

### `manualBoundary`

```swift
public let manualBoundary: String?
```

### `serializationFormat`

```swift
public let serializationFormat = JSONSerializationFormat.self
```

## Methods
### `init(graphQLEndpoint:operation:clientName:clientVersion:additionalHeaders:files:manualBoundary:requestCreator:)`

```swift
public init(graphQLEndpoint: URL,
            operation: Operation,
            clientName: String,
            clientVersion: String,
            additionalHeaders: [String: String] = [:],
            files: [GraphQLFile],
            manualBoundary: String? = nil,
            requestCreator: RequestCreator = ApolloRequestCreator())
```

> Designated Initializer
>
> - Parameters:
>   - graphQLEndpoint: The endpoint to make a GraphQL request to
>   - operation: The GraphQL Operation to execute
>   - clientName: The name of the client to send with the `"apollographql-client-name"` header
>   - clientVersion:  The version of the client to send with the `"apollographql-client-version"` header
>   - additionalHeaders: Any additional headers you wish to add by default to this request. Defaults to an empty dictionary.
>   - files: The array of files to upload for all `Upload` parameters in the mutation.
>   - manualBoundary: [optional] A manual boundary to pass in. A default boundary will be used otherwise. Defaults to nil.
>   - requestCreator: An object conforming to the `RequestCreator` protocol to assist with creating the request body. Defaults to the provided `ApolloRequestCreator` implementation.

#### Parameters

| Name | Description |
| ---- | ----------- |
| graphQLEndpoint | The endpoint to make a GraphQL request to |
| operation | The GraphQL Operation to execute |
| clientName | The name of the client to send with the `"apollographql-client-name"` header |
| clientVersion | The version of the client to send with the `"apollographql-client-version"` header |
| additionalHeaders | Any additional headers you wish to add by default to this request. Defaults to an empty dictionary. |
| files | The array of files to upload for all `Upload` parameters in the mutation. |
| manualBoundary | [optional] A manual boundary to pass in. A default boundary will be used otherwise. Defaults to nil. |
| requestCreator | An object conforming to the `RequestCreator` protocol to assist with creating the request body. Defaults to the provided `ApolloRequestCreator` implementation. |

### `toURLRequest()`

```swift
public override func toURLRequest() throws -> URLRequest
```
