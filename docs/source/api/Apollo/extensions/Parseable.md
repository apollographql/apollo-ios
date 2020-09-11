**EXTENSION**

# `Parseable`
```swift
public extension Parseable where Self: Decodable
```

## Methods
### `init(from:decoder:)`

```swift
init<T: FlexibleDecoder>(from data: Data, decoder: T) throws
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| data | The data to decode |
| decoder | The decoder to use to decode it |