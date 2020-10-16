**STRUCT**

# `FileFinder`

```swift
public struct FileFinder
```

## Methods
### `findParentFolder(from:)`

```swift
public static func findParentFolder(from filePath: StaticString = #filePath) -> URL
```

> Version that works if you're using the 5.3 compiler or above
> - Parameter filePath: The full file path of the file to find. Defaults to the `#filePath` of the caller.
> - Returns: The file URL for the parent foilder.

#### Parameters

| Name | Description |
| ---- | ----------- |
| filePath | The full file path of the file to find. Defaults to the `#filePath` of the caller. |

### `findParentFolder(from:)`

> Version that works if you're using the 5.2 compiler or below
> - Parameter file: The full file path of the file to find. Defaults to the `#file` of the caller.
> - Returns: The file URL for the parent foilder.

### `findParentFolder(from:)`

```swift
public static func findParentFolder(from filePath: String) -> URL
```

> Finds the parent folder from a given file path.
> - Parameter filePath: The full file path, as a string
> - Returns: The file URL for the parent folder.

#### Parameters

| Name | Description |
| ---- | ----------- |
| filePath | The full file path, as a string |