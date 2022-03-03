**STRUCT**

# `FieldArguments`

```swift
public struct FieldArguments: ExpressibleByDictionaryLiteral
```

## Methods
### `init(dictionaryLiteral:)`

```swift
public init(dictionaryLiteral elements: (String, InputValue)...)
```

### `evaluate(with:)`

```swift
public func evaluate(with variables: [String: JSONEncodable]?) throws -> JSONValue
```

### `evaluate(with:)`

```swift
public func evaluate(with variables: [String: JSONEncodable]?) throws -> JSONObject
```
