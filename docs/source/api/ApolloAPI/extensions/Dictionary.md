**EXTENSION**

# `Dictionary`
```swift
extension Dictionary: _InitializableByDictionaryLiteralElements
```

## Properties
### `jsonEncodableValue`

```swift
@inlinable public var jsonEncodableValue: JSONEncodable?
```

### `jsonEncodableObject`

```swift
@inlinable public var jsonEncodableObject: JSONEncodableDictionary
```

## Methods
### `init(_:)`

```swift
@inlinable public init(_ elements: [(Key, Value)])
```

### `init(jsonValue:)`

```swift
@inlinable public init(jsonValue value: JSONValue) throws
```
