**ENUM**

# `ApolloCodegenConfiguration.Error`

```swift
public enum Error: Swift.Error, LocalizedError, Equatable
```

Errors which can happen with code generation

## Cases
### `notAFile(_:)`

```swift
case notAFile(PathType)
```

### `notADirectory(_:)`

```swift
case notADirectory(PathType)
```

### `folderCreationFailed(_:underlyingError:)`

```swift
case folderCreationFailed(PathType, underlyingError: Swift.Error)
```

### `testMocksInvalidSwiftPackageConfiguration`

```swift
case testMocksInvalidSwiftPackageConfiguration
```

## Properties
### `errorDescription`

```swift
public var errorDescription: String
```

### `recoverySuggestion`

```swift
public var recoverySuggestion: String
```

## Methods
### `logging(withPath:)`

```swift
public func logging(withPath path: String) -> Error
```

### `==(_:_:)`

```swift
public static func == (lhs: Error, rhs: Error) -> Bool
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| lhs | A value to compare. |
| rhs | Another value to compare. |