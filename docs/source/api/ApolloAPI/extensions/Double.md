**EXTENSION**

# `Double`
```swift
extension Double: JSONDecodable, JSONEncodable
```

## Properties
### `jsonValue`

```swift
@inlinable public var jsonValue: JSONValue
```

### `asOutputType`

```swift
public static let asOutputType: Selection.Field.OutputType = .nonNull(.scalar(Double.self))
```

## Methods
### `init(jsonValue:)`

```swift
@inlinable public init(jsonValue value: JSONValue) throws
```
