**ENUM**

# `Glob.MatchError`

```swift
public enum MatchError: Error, LocalizedError, Equatable
```

An error object that indicates why pattern matching failed.

## Cases
### `noSpace`

```swift
case noSpace
```

### `aborted`

```swift
case aborted
```

### `cannotEnumerate(path:)`

```swift
case cannotEnumerate(path: String)
```

### `invalidExclude(path:)`

```swift
case invalidExclude(path: String)
```

### `unknown(code:)`

```swift
case unknown(code: Int)
```

## Properties
### `errorDescription`

```swift
public var errorDescription: String?
```
