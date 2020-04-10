**EXTENSION**

# `FileManager`
```swift
public extension FileManager
```

## Methods
### `apollo_fileExists(at:)`

```swift
func apollo_fileExists(at path: String) -> Bool
```

> Checks if a file exists (and is not a folder) at the given path
>
> - Parameter path: The path to check
> - Returns: `true` if there is something at the path and it is a file, not a folder.

#### Parameters

| Name | Description |
| ---- | ----------- |
| path | The path to check |

### `apollo_fileExists(at:)`

```swift
func apollo_fileExists(at url: URL) -> Bool
```

> Checks if a file exists (and is not a folder) at the given URL
>
> - Parameter url: The URL to check
> - Returns: `true` if there is something at the URL and it is a file, not a folder.

#### Parameters

| Name | Description |
| ---- | ----------- |
| url | The URL to check |

### `apollo_folderExists(at:)`

```swift
func apollo_folderExists(at path: String) -> Bool
```

> Checks if a folder exists (and is not a file) at the given path.
>
> - Parameter path: The path to check
> - Returns: `true` if there is something at the path and it is a folder, not a file.

#### Parameters

| Name | Description |
| ---- | ----------- |
| path | The path to check |

### `apollo_folderExists(at:)`

```swift
func apollo_folderExists(at url: URL) -> Bool
```

> Checks if a folder exists (and is not a file) at the given URL.
>
> - Parameter url: The URL to check
> - Returns: `true` if there is something at the URL and it is a folder, not a file.

#### Parameters

| Name | Description |
| ---- | ----------- |
| url | The URL to check |

### `apollo_deleteFolder(at:)`

```swift
func apollo_deleteFolder(at url: URL) throws
```

> Checks if a folder exists then attempts to delete it if it's there.
>
> - Parameter url: The URL to delete the folder for

#### Parameters

| Name | Description |
| ---- | ----------- |
| url | The URL to delete the folder for |

### `apollo_deleteFile(at:)`

```swift
func apollo_deleteFile(at url: URL) throws
```

> Checks if a file exists then attempts to delete it if it's there.
>
> - Parameter url: The URL to delete the file for

#### Parameters

| Name | Description |
| ---- | ----------- |
| url | The URL to delete the file for |

### `apollo_createContainingFolderIfNeeded(for:)`

```swift
func apollo_createContainingFolderIfNeeded(for fileURL: URL) throws
```

> Creates the containing folder (including all intermediate directories) for the given file URL if necessary.
>
> - Parameter fileURL: The URL of the file to create a containing folder for if necessary.

#### Parameters

| Name | Description |
| ---- | ----------- |
| fileURL | The URL of the file to create a containing folder for if necessary. |

### `apollo_createFolderIfNeeded(at:)`

```swift
func apollo_createFolderIfNeeded(at url: URL) throws
```

> Creates the folder (including all intermediate directories) for the given URL if necessary.
>
> - Parameter url: The URL of the folder to create if necessary.

#### Parameters

| Name | Description |
| ---- | ----------- |
| url | The URL of the folder to create if necessary. |

### `apollo_shasum(at:)`

```swift
func apollo_shasum(at fileURL: URL) throws -> String
```

> Calculates the SHASUM (ie, SHA256 hash) of the given file
>
> - Parameter fileURL: The file to calculate the SHASUM for.

#### Parameters

| Name | Description |
| ---- | ----------- |
| fileURL | The file to calculate the SHASUM for. |