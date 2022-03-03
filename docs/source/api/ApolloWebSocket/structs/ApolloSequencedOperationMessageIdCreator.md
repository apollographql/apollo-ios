**STRUCT**

# `ApolloSequencedOperationMessageIdCreator`

```swift
public struct ApolloSequencedOperationMessageIdCreator: OperationMessageIdCreator
```

The default implementation of `OperationMessageIdCreator` that uses a sequential numbering scheme.

## Methods
### `init(startAt:)`

```swift
public init(startAt sequenceNumber: Int = 1)
```

Designated initializer.

- Parameter startAt: The number from which the sequenced numbering scheme should start.

#### Parameters

| Name | Description |
| ---- | ----------- |
| startAt | The number from which the sequenced numbering scheme should start. |

### `requestId()`

```swift
public func requestId() -> String
```

Returns the number in the current sequence. Will be incremented when calling this method.
