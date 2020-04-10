**PROTOCOL**

# `RequestCreator`

```swift
public protocol RequestCreator
```

## Methods
### `requestBody(for:sendOperationIdentifiers:sendQueryDocument:autoPersistQuery:)`

```swift
func requestBody<Operation: GraphQLOperation>(for operation: Operation,
                                              sendOperationIdentifiers: Bool,
                                              sendQueryDocument: Bool,
                                              autoPersistQuery: Bool) -> GraphQLMap
```

> Creates a `GraphQLMap` out of the passed-in operation
>
> - Parameters:
>   - operation: The operation to use
>   - sendOperationIdentifiers: Whether or not to send operation identifiers. Defaults to false.
> - Returns: The created `GraphQLMap`

#### Parameters

| Name | Description |
| ---- | ----------- |
| operation | The operation to use |
| sendOperationIdentifiers | Whether or not to send operation identifiers. Defaults to false. |

### `requestMultipartFormData(for:files:sendOperationIdentifiers:serializationFormat:manualBoundary:)`

```swift
func requestMultipartFormData<Operation: GraphQLOperation>(for operation: Operation,
                                                           files: [GraphQLFile],
                                                           sendOperationIdentifiers: Bool,
                                                           serializationFormat: JSONSerializationFormat.Type,
                                                           manualBoundary: String?) throws -> MultipartFormData
```

> Creates multi-part form data to send with a request
>
> - Parameters:
>   - operation: The operation to create the data for.
>   - files: An array of files to use.
>   - sendOperationIdentifiers: True if operation identifiers should be sent, false if not.
>   - serializationFormat: The format to use to serialize data.
>   - manualBoundary: [optional] A manual boundary to pass in. A default boundary will be used otherwise.
> - Returns: The created form data
> - Throws: Errors creating or loading the form  data

#### Parameters

| Name | Description |
| ---- | ----------- |
| operation | The operation to create the data for. |
| files | An array of files to use. |
| sendOperationIdentifiers | True if operation identifiers should be sent, false if not. |
| serializationFormat | The format to use to serialize data. |
| manualBoundary | [optional] A manual boundary to pass in. A default boundary will be used otherwise. |