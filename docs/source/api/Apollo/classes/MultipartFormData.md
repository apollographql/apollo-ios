**CLASS**

# `MultipartFormData`

```swift
public final class MultipartFormData
```

A helper for building out multi-part form data for upload

## Properties
### `boundary`

```swift
public let boundary: String
```

## Methods
### `init(boundary:)`

```swift
public init(boundary: String)
```

Designated initializer

- Parameter boundary: The boundary to use between parts of the form.

#### Parameters

| Name | Description |
| ---- | ----------- |
| boundary | The boundary to use between parts of the form. |

### `init()`

```swift
public convenience init()
```

Convenience initializer which uses a pre-defined boundary

### `appendPart(string:name:)`

```swift
public func appendPart(string: String, name: String) throws
```

Appends the passed-in string as a part of the body.

- Parameters:
  - string: The string to append
  - name: The name of the part to pass along to the server

#### Parameters

| Name | Description |
| ---- | ----------- |
| string | The string to append |
| name | The name of the part to pass along to the server |

### `appendPart(data:name:contentType:filename:)`

```swift
public func appendPart(data: Data,
                       name: String,
                       contentType: String? = nil,
                       filename: String? = nil)
```

Appends the passed-in data as a part of the body.

- Parameters:
  - data: The data to append
  - name: The name of the part to pass along to the server
  - contentType: [optional] The content type of this part. Defaults to nil.
  - filename: [optional] The name of the file for this part. Defaults to nil.

#### Parameters

| Name | Description |
| ---- | ----------- |
| data | The data to append |
| name | The name of the part to pass along to the server |
| contentType | [optional] The content type of this part. Defaults to nil. |
| filename | [optional] The name of the file for this part. Defaults to nil. |

### `appendPart(inputStream:contentLength:name:contentType:filename:)`

```swift
public func appendPart(inputStream: InputStream,
                       contentLength: UInt64,
                       name: String,
                       contentType: String? = nil,
                       filename: String? = nil)
```

Appends the passed-in input stream as a part of the body.

- Parameters:
  - inputStream: The input stream to append.
  - contentLength: Length of the input stream data.
  - name: The name of the part to pass along to the server
  - contentType: [optional] The content type of this part. Defaults to nil.
  - filename: [optional] The name of the file for this part. Defaults to nil.

#### Parameters

| Name | Description |
| ---- | ----------- |
| inputStream | The input stream to append. |
| contentLength | Length of the input stream data. |
| name | The name of the part to pass along to the server |
| contentType | [optional] The content type of this part. Defaults to nil. |
| filename | [optional] The name of the file for this part. Defaults to nil. |

### `encode()`

```swift
public func encode() throws -> Data
```

Encodes everything into the final form data to send to a server.

- Returns: The final form data to send to a server.
