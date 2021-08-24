**ENUM**

# `JSONResponseParsingInterceptor.JSONResponseParsingError`

```swift
public enum JSONResponseParsingError: Error, LocalizedError
```

## Cases
### `noResponseToParse`

```swift
case noResponseToParse
```

### `couldNotParseToJSON(data:)`

```swift
case couldNotParseToJSON(data: Data)
```

## Properties
### `errorDescription`

```swift
public var errorDescription: String?
```
