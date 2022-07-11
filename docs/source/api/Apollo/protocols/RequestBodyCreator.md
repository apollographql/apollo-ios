**PROTOCOL**

# `RequestBodyCreator`

```swift
public protocol RequestBodyCreator
```

## Methods
### `requestBody(for:sendQueryDocument:autoPersistQuery:)`

```swift
func requestBody<Operation: GraphQLOperation>(
  for operation: Operation,
  sendQueryDocument: Bool,
  autoPersistQuery: Bool
) -> JSONEncodableDictionary
```

Creates a `JSONEncodableDictionary` out of the passed-in operation

- Parameters:
  - operation: The operation to use
  - sendQueryDocument: Whether or not to send the full query document. Should default to `true`.
  - autoPersistQuery: Whether to use auto-persisted query information. Should default to `false`.
- Returns: The created `JSONEncodableDictionary`

#### Parameters

| Name | Description |
| ---- | ----------- |
| operation | The operation to use |
| sendQueryDocument | Whether or not to send the full query document. Should default to `true`. |
| autoPersistQuery | Whether to use auto-persisted query information. Should default to `false`. |