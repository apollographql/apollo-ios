**EXTENSION**

# `Optional`
```swift
extension Optional: GraphQLInputValue
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

### `init(jsonValue:)`

```swift
public init(jsonValue value: JSONValue) throws
```
