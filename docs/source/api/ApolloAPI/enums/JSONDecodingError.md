**ENUM**

# `JSONDecodingError`

```swift
public enum JSONDecodingError: Error, LocalizedError, Hashable
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
case couldNotConvert(value: AnyHashable, to: Any.Type)
```

## Properties
### `errorDescription`

```swift
public var errorDescription: String?
```

## Methods
### `==(_:_:)`

```swift
public static func == (lhs: JSONDecodingError, rhs: JSONDecodingError) -> Bool
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| lhs | A value to compare. |
| rhs | Another value to compare. |

### `hash(into:)`

```swift
public func hash(into hasher: inout Hasher)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| hasher | The hasher to use when combining the components of this instance. |