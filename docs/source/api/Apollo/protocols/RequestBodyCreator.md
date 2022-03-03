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

Creates a `GraphQLMap` out of the passed-in operation

- Parameters:
  - operation: The operation to use
  - sendOperationIdentifiers: Whether or not to send operation identifiers. Should default to `false`.
  - sendQueryDocument: Whether or not to send the full query document. Should default to `true`.
  - autoPersistQuery: Whether to use auto-persisted query information. Should default to `false`.
- Returns: The created `GraphQLMap`

#### Parameters

| Name | Description |
| ---- | ----------- |
| operation | The operation to use |
| sendOperationIdentifiers | Whether or not to send operation identifiers. Should default to `false`. |
| sendQueryDocument | Whether or not to send the full query document. Should default to `true`. |
| autoPersistQuery | Whether to use auto-persisted query information. Should default to `false`. |