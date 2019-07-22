**ENUM**

# `JSONDecodingError`

```swift
public enum JSONDecodingError: Error, LocalizedError
```

## Cases
### `missingValue`

```swift
case missingValue
```

### `nullValue`

```swift
case nullValue
```

### `wrongType`

```swift
case wrongType
```

### `couldNotConvert(value:to:)`

```swift
case couldNotConvert(value: Any, to: Any.Type)
```

## Properties
### `errorDescription`

```swift
public var errorDescription: String?
```
