**CLASS**

# `UploadRequest`

```swift
open class UploadRequest<Operation: GraphQLOperation>: HTTPRequest<Operation>
```

A request class allowing for a multipart-upload request.

## Properties
### `requestBodyCreator`

```swift
public let requestBodyCreator: RequestBodyCreator
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
### `init(graphQLEndpoint:operation:clientName:clientVersion:additionalHeaders:files:manualBoundary:requestBodyCreator:)`

```swift
public init(graphQLEndpoint: URL,
            operation: Operation,
            clientName: String,
            clientVersion: String,
            additionalHeaders: [String: String] = [:],
            files: [GraphQLFile],
            manualBoundary: String? = nil,
            requestBodyCreator: RequestBodyCreator = ApolloRequestBodyCreator())
```

Designated Initializer

- Parameters:
  - graphQLEndpoint: The endpoint to make a GraphQL request to
  - operation: The GraphQL Operation to execute
  - clientName: The name of the client to send with the `"apollographql-client-name"` header
  - clientVersion:  The version of the client to send with the `"apollographql-client-version"` header
  - additionalHeaders: Any additional headers you wish to add by default to this request. Defaults to an empty dictionary.
  - files: The array of files to upload for all `Upload` parameters in the mutation.
  - manualBoundary: [optional] A manual boundary to pass in. A default boundary will be used otherwise. Defaults to nil.
  - requestBodyCreator: An object conforming to the `RequestBodyCreator` protocol to assist with creating the request body. Defaults to the provided `ApolloRequestBodyCreator` implementation.

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
| requestBodyCreator | An object conforming to the `RequestBodyCreator` protocol to assist with creating the request body. Defaults to the provided `ApolloRequestBodyCreator` implementation. |

### `toURLRequest()`

```swift
public override func toURLRequest() throws -> URLRequest
```

### `requestMultipartFormData()`

```swift
open func requestMultipartFormData() throws -> MultipartFormData
```

Creates the `MultipartFormData` object to use when creating the URL Request.

This method follows the [GraphQL Multipart Request Spec](https://github.com/jaydenseric/graphql-multipart-request-spec) Override this method to use a different upload spec.

- Throws: Any error arising from creating the form data
- Returns: The created form data
