**EXTENSION**

# `Decodable`
```swift
public extension Decodable
```

## Methods
### `load(from:decoder:)`

```swift
static func load<T: FlexibleDecoder>(from fileURL: URL, decoder: T) throws -> Self
```

> Loads data from a given file URL and parses it with the given decoder.
>
> - Parameters:
>   - fileURL: The file URL to load from
>   - decoder: A decoder to use.
> - Returns: The parsed object of the calling type

#### Parameters

| Name | Description |
| ---- | ----------- |
| fileURL | The file URL to load from |
| decoder | A decoder to use. |