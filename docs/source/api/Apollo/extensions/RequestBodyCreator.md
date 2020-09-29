**EXTENSION**

# `RequestBodyCreator`
```swift
extension RequestBodyCreator
```

## Methods
### `requestBody(for:sendOperationIdentifiers:sendQueryDocument:autoPersistQuery:)`

```swift
public func requestBody<Operation: GraphQLOperation>(for operation: Operation,
                                                     sendOperationIdentifiers: Bool = false,
                                                     sendQueryDocument: Bool = true,
                                                     autoPersistQuery: Bool = false) -> GraphQLMap
```

> Creates a `GraphQLMap` out of the passed-in operation
>
> - Parameters:
>   - operation: The operation to use
>   - sendOperationIdentifiers: Whether or not to send operation identifiers. Defaults to false.
>   - sendQueryDocument: Whether or not to send the full query document. Defaults to true.
>   - autoPersistQuery: Whether to use auto-persisted query information. Defaults to false.
> - Returns: The created `GraphQLMap`

#### Parameters

| Name | Description |
| ---- | ----------- |
| operation | The operation to use |
| sendOperationIdentifiers | Whether or not to send operation identifiers. Defaults to false. |
| sendQueryDocument | Whether or not to send the full query document. Defaults to true. |
| autoPersistQuery | Whether to use auto-persisted query information. Defaults to false. |