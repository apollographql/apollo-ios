**STRUCT**

# `GraphQLFile`

```swift
public struct GraphQLFile
```

> A file which can be uploaded to a GraphQL server

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

### `inputStream`

```swift
public let inputStream: InputStream
```

### `contentLength`

```swift
public let contentLength: UInt64
```

## Methods
### `init(fieldName:originalName:mimeType:data:)`

```swift
public init(fieldName: String,
            originalName: String,
            mimeType: String = GraphQLFile.octetStreamMimeType,
            data: Data)
```

> Convenience initializer for raw data
>
> - Parameters:
>   - fieldName: The name of the field this file is being sent for
>   - originalName: The original name of the file
>   - mimeType: The mime type of the file to send to the server. Defaults to `GraphQLFile.octetStreamMimeType`.
>   - data: The raw data to send for the file.

#### Parameters

| Name | Description |
| ---- | ----------- |
| fieldName | The name of the field this file is being sent for |
| originalName | The original name of the file |
| mimeType | The mime type of the file to send to the server. Defaults to `GraphQLFile.octetStreamMimeType`. |
| data | The raw data to send for the file. |

### `init(fieldName:originalName:mimeType:fileURL:)`

```swift
public init?(fieldName: String,
             originalName: String,
             mimeType: String = GraphQLFile.octetStreamMimeType,
             fileURL: URL)
```

> Failable convenience initializer for files in the filesystem
> Will return `nil` if the file URL cannot be used to create an `InputStream`, or if the file's size could not be determined.
>
> - Parameters:
>   - fieldName: The name of the field this file is being sent for
>   - originalName: The original name of the file
>   - mimeType: The mime type of the file to send to the server. Defaults to `GraphQLFile.octetStreamMimeType`.
>   - fileURL: The URL of the file to upload.

#### Parameters

| Name | Description |
| ---- | ----------- |
| fieldName | The name of the field this file is being sent for |
| originalName | The original name of the file |
| mimeType | The mime type of the file to send to the server. Defaults to `GraphQLFile.octetStreamMimeType`. |
| fileURL | The URL of the file to upload. |

### `init(fieldName:originalName:mimeType:inputStream:contentLength:)`

```swift
public init(fieldName: String,
            originalName: String,
            mimeType: String = GraphQLFile.octetStreamMimeType,
            inputStream: InputStream,
            contentLength: UInt64)
```

> Designated Initializer
>
> - Parameters:
>   - fieldName: The name of the field this file is being sent for
>   - originalName: The original name of the file
>   - mimeType: The mime type of the file to send to the server. Defaults to `GraphQLFile.octetStreamMimeType`.
>   - inputStream: An input stream to use to acccess data
>   - contentLength: The length of the data being sent

#### Parameters

| Name | Description |
| ---- | ----------- |
| fieldName | The name of the field this file is being sent for |
| originalName | The original name of the file |
| mimeType | The mime type of the file to send to the server. Defaults to `GraphQLFile.octetStreamMimeType`. |
| inputStream | An input stream to use to acccess data |
| contentLength | The length of the data being sent |