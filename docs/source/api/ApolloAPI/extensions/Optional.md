**EXTENSION**

# `Optional`
```swift
extension Optional: SelectionSetEntityValue where Wrapped: SelectionSetEntityValue
```

## Properties
### `_fieldData`

```swift
@inlinable public var _fieldData: AnyHashable
```

### `jsonEncodableValue`

```swift
@inlinable public var jsonEncodableValue: JSONEncodable?
```

### `jsonValue`

```swift
@inlinable public var jsonValue: JSONValue
```

### `asOutputType`

```swift
@inlinable public static var asOutputType: Selection.Field.OutputType
```

## Methods
### `init(fieldData:variables:)`

```swift
@inlinable public init(fieldData: AnyHashable?, variables: GraphQLOperation.Variables?)
```

### `init(jsonValue:)`

```swift
@inlinable public init(jsonValue value: JSONValue) throws
```
