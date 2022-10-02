**EXTENSION**

# `ApolloExtension`
```swift
extension ApolloExtension where Base: FileManager
```

## Methods
### `doesFileExist(atPath:)`

```swift
public func doesFileExist(atPath path: String) -> Bool
```

Checks if the path exists and is a file, not a directory.

- Parameter path: The path to check.
- Returns: `true` if there is something at the path and it is a file, not a directory.

#### Parameters

| Name | Description |
| ---- | ----------- |
| path | The path to check. |

### `doesDirectoryExist(atPath:)`

```swift
public func doesDirectoryExist(atPath path: String) -> Bool
```

Checks if the path exists and is a directory, not a file.

- Parameter path: The path to check.
- Returns: `true` if there is something at the path and it is a directory, not a file.

#### Parameters

| Name | Description |
| ---- | ----------- |
| path | The path to check. |

### `deleteFile(atPath:)`

```swift
public func deleteFile(atPath path: String) throws
```

Verifies that a file exists at the path and then attempts to delete it. An error is thrown if the path is for a directory.

- Parameter path: The path of the file to delete.

#### Parameters

| Name | Description |
| ---- | ----------- |
| path | The path of the file to delete. |

### `deleteDirectory(atPath:)`

```swift
public func deleteDirectory(atPath path: String) throws
```

Verifies that a directory exists at the path and then attempts to delete it. An error is thrown if the path is for a file.

- Parameter path: The path of the directory to delete.

#### Parameters

| Name | Description |
| ---- | ----------- |
| path | The path of the directory to delete. |

### `createFile(atPath:data:overwrite:)`

```swift
public func createFile(atPath path: String, data: Data? = nil, overwrite: Bool = true) throws
```

Creates a file at the specified path and writes any given data to it. If a file already exists at `path`, this method overwrites the
contents of that file if the current process has the appropriate privileges to do so.

- Parameters:
  - path: Path to the file.
  - data: [optional] Data to write to the file path.
  - overwrite: Indicates if the contents of an existing file should be overwritten.
      If `false` the function will exit without writing the file if it already exists.
      This will not throw an error.
      Defaults to `false.

#### Parameters

| Name | Description |
| ---- | ----------- |
| path | Path to the file. |
| data | [optional] Data to write to the file path. |
| overwrite | Indicates if the contents of an existing file should be overwritten. If `false` the function will exit without writing the file if it already exists. This will not throw an error. Defaults to `false. |

### `createContainingDirectoryIfNeeded(forPath:)`

```swift
public func createContainingDirectoryIfNeeded(forPath path: String) throws
```

Creates the containing directory (including all intermediate directories) for the given file URL if necessary. This method will not
overwrite any existing directory.

- Parameter fileURL: The URL of the file to create a containing directory for if necessary.

#### Parameters

| Name | Description |
| ---- | ----------- |
| fileURL | The URL of the file to create a containing directory for if necessary. |

### `createDirectoryIfNeeded(atPath:)`

```swift
public func createDirectoryIfNeeded(atPath path: String) throws
```

Creates the directory (including all intermediate directories) for the given URL if necessary. This method will not overwrite any
existing directory.

- Parameter path: The path of the directory to create if necessary.

#### Parameters

| Name | Description |
| ---- | ----------- |
| path | The path of the directory to create if necessary. |

### `parentFolderURL()`

```swift
public func parentFolderURL() -> URL
```

- Returns: the URL to the parent folder of the current URL.

### `childFolderURL(folderName:)`

```swift
public func childFolderURL(folderName: String) -> URL
```

- Parameter folderName: The name of the child folder to append to the current URL
- Returns: The full URL including the appended child folder.

#### Parameters

| Name | Description |
| ---- | ----------- |
| folderName | The name of the child folder to append to the current URL |

### `childFileURL(fileName:)`

```swift
public func childFileURL(fileName: String) throws -> URL
```

Adds the filename to the caller to get the full URL of a file

- Parameters:
  - fileName: The name of the child file, with an extension, for example `"API.swift"`. Note: For hidden files just pass `".filename"`.
- Returns: The full URL including the full file.

#### Parameters

| Name | Description |
| ---- | ----------- |
| fileName | The name of the child file, with an extension, for example `"API.swift"`. Note: For hidden files just pass `".filename"`. |