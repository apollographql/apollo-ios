**EXTENSION**

# `Array`
```swift
extension Array: GraphQLInputValue
```

## Properties
### `jsonValue`

```swift
public var jsonValue: JSONValue
```

## Methods
### `evaluate(with:)`

```swift
public func evaluate(with variables: [String: JSONEncodable]?) throws -> JSONValue
```

### `evaluate(with:)`

```swift
public func evaluate(with variables: [String: JSONEncodable]?) throws -> [JSONValue]
```
