**ENUM**

# `FileManagerPathError`

```swift
public enum FileManagerPathError: Swift.Error, LocalizedError, Equatable
```

## Cases
### `notAFile(path:)`

```swift
case notAFile(path: String)
```

### `notADirectory(path:)`

```swift
case notADirectory(path: String)
```

### `cannotCreateFile(at:)`

```swift
case cannotCreateFile(at: String)
```

## Properties
### `errorDescription`

```swift
public var errorDescription: String
```
