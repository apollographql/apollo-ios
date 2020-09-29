**PROTOCOL**

# `RequestBodyCreator`

```swift
public protocol RequestBodyCreator
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