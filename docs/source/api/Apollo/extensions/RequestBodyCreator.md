**EXTENSION**

# `RequestBodyCreator`
```swift
extension RequestBodyCreator
```

## Methods
### `requestBody(for:sendQueryDocument:autoPersistQuery:)`

```swift
public func requestBody<Operation: GraphQLOperation>(
  for operation: Operation,
  sendQueryDocument: Bool,
  autoPersistQuery: Bool
) -> JSONEncodableDictionary
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| operation | The operation to use |
| sendQueryDocument | Whether or not to send the full query document. Should default to `true`. |
| autoPersistQuery | Whether to use auto-persisted query information. Should default to `false`. |