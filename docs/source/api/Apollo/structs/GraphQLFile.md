**STRUCT**

# `GraphQLFile`

```swift
public struct GraphQLFile
```

A file which can be uploaded to a GraphQL server

## Properties
### `fieldName`

```swift
public let fieldName: String
```

### `originalName`

```swift
public let originalName: String
```

### `mimeType`

```swift
public let mimeType: String
```

### `data`

```swift
public let data: Data?
```

### `fileURL`

```swift
public let fileURL: URL?
```

### `contentLength`

```swift
public let contentLength: UInt64
```

### `octetStreamMimeType`

```swift
public static let octetStreamMimeType = "application/octet-stream"
```

A convenience constant for declaring your mimetype is octet-stream.

## Methods
### `init(fieldName:originalName:mimeType:data:)`

```swift
public init(fieldName: String,
            originalName: String,
            mimeType: String = GraphQLFile.octetStreamMimeType,
            data: Data)
```

Convenience initializer for raw data

- Parameters:
  - fieldName: The name of the field this file is being sent for
  - originalName: The original name of the file
  - mimeType: The mime type of the file to send to the server. Defaults to `GraphQLFile.octetStreamMimeType`.
  - data: The raw data to send for the file.

#### Parameters

| Name | Description |
| ---- | ----------- |
| fieldName | The name of the field this file is being sent for |
| originalName | The original name of the file |
| mimeType | The mime type of the file to send to the server. Defaults to `GraphQLFile.octetStreamMimeType`. |
| data | The raw data to send for the file. |

### `init(fieldName:originalName:mimeType:fileURL:)`

```swift
public init(fieldName: String,
             originalName: String,
             mimeType: String = GraphQLFile.octetStreamMimeType,
             fileURL: URL) throws
```

Throwing convenience initializer for files in the filesystem

- Parameters:
  - fieldName: The name of the field this file is being sent for
  - originalName: The original name of the file
  - mimeType: The mime type of the file to send to the server. Defaults to `GraphQLFile.octetStreamMimeType`.
  - fileURL: The URL of the file to upload.
- Throws: If the file's size could not be determined

#### Parameters

| Name | Description |
| ---- | ----------- |
| fieldName | The name of the field this file is being sent for |
| originalName | The original name of the file |
| mimeType | The mime type of the file to send to the server. Defaults to `GraphQLFile.octetStreamMimeType`. |
| fileURL | The URL of the file to upload. |

### `generateInputStream()`

```swift
public func generateInputStream() throws -> InputStream
```

Uses either the data or the file URL to create an
`InputStream` that can be used to stream data into
a multipart-form.

- Returns: The created `InputStream`.
- Throws: If an input stream could not be created from either data or a file URL.
