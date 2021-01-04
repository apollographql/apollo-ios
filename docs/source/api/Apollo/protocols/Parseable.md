**PROTOCOL**

# `Parseable`

```swift
public protocol Parseable
```

A protocol to represent anything that can be decoded by a `FlexibleDecoder`

## Methods
### `init(from:decoder:)`

```swift
init<T: FlexibleDecoder>(from data: Data, decoder: T) throws
```

Required initializer

- Parameters:
  - data: The data to decode
  - decoder: The decoder to use to decode it

#### Parameters

| Name | Description |
| ---- | ----------- |
| data | The data to decode |
| decoder | The decoder to use to decode it |