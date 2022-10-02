**EXTENSION**

# `Bool`
```swift
extension Bool: JSONDecodable, JSONEncodable
```

## Properties
### `jsonValue`

```swift
@inlinable public var jsonValue: JSONValue
```

### `asOutputType`

```swift
public static let asOutputType: Selection.Field.OutputType = .nonNull(.scalar(Bool.self))
```

## Methods
### `init(jsonValue:)`

```swift
@inlinable public init(jsonValue value: JSONValue) throws
```
