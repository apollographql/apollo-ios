**ENUM**

# `BashError`

```swift
public enum BashError: Error, LocalizedError
```

## Cases
### `errorDuringTask(errorString:code:)`

```swift
case errorDuringTask(errorString: String, code: Int32)
```

### `noOutput(code:)`

```swift
case noOutput(code: Int32)
```

## Properties
### `errorDescription`

```swift
public var errorDescription: String?
```
