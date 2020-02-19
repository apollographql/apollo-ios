**ENUM**

# `OutputFormat`

```swift
public enum OutputFormat
```

> Enum to select how you want to export your API files.

## Cases
### `singleFile(atFileURL:)`

```swift
case singleFile(atFileURL: URL)
```

> Outputs everything into a single file at the given URL.
> NOTE: URL must be a file URL

### `multipleFiles(inFolderAtURL:)`

```swift
case multipleFiles(inFolderAtURL: URL)
```

> Outputs everything into individual files in a folder a the given URL
> NOTE: URL must be a folder URL
