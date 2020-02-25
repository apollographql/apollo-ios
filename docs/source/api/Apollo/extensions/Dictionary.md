**EXTENSION**

# `Dictionary`
```swift
public extension Dictionary
```

## Properties
### `withNilValuesRemoved`

```swift
public var withNilValuesRemoved: Dictionary<String, JSONEncodable>
```

### `jsonValue`

```swift
public var jsonValue: JSONValue
```

### `jsonObject`

```swift
public var jsonObject: JSONObject
```

## Methods
### `+=(_:_:)`

```swift
static func += (lhs: inout Dictionary, rhs: Dictionary)
```

### `evaluate(with:)`

```swift
public func evaluate(with variables: [String: JSONEncodable]?) throws -> JSONValue
```

### `evaluate(with:)`

```swift
public func evaluate(with variables: [String: JSONEncodable]?) throws -> JSONObject
```
