**STRUCT**

# `RequestCreator`

```swift
public struct RequestCreator
```

## Methods
### `requestBody(for:sendOperationIdentifiers:)`

```swift
public static func requestBody<Operation: GraphQLOperation>(for operation: Operation, sendOperationIdentifiers: Bool = false) -> GraphQLMap
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