**ENUM**

# `ApolloCodegen.CodegenError`

```swift
public enum CodegenError: Error, LocalizedError
```

Errors which can happen with code generation

## Cases
### `folderDoesNotExist(_:)`

```swift
case folderDoesNotExist(_ url: URL)
```

### `multipleFilesButNotDirectoryURL(_:)`

```swift
case multipleFilesButNotDirectoryURL(_ url: URL)
```

### `singleFileButNotSwiftFileURL(_:)`

```swift
case singleFileButNotSwiftFileURL(_ url: URL)
```

## Properties
### `errorDescription`

```swift
public var errorDescription: String?
```
