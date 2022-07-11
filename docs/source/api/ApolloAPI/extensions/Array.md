**EXTENSION**

# `Array`
```swift
extension Array: SelectionSetEntityValue where Element: SelectionSetEntityValue
```

## Properties
### `_fieldData`

```swift
@inlinable public var _fieldData: AnyHashable
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
