**EXTENSION**

# `SelectionSet`
```swift
extension SelectionSet
```

## Properties
### `schema`

```swift
@inlinable public static var schema: SchemaConfiguration.Type
```

### `__typename`

```swift
@inlinable public var __typename: String
```

### `fragments`

```swift
public var fragments: Fragments
```

Contains accessors for all of the fragments the `SelectionSet` can be converted to.

## Methods
### `_asInlineFragment(if:)`

```swift
@inlinable public func _asInlineFragment<T: SelectionSet>(
  if conditions: Selection.Conditions? = nil
) -> T? where T.Schema == Schema
```

Verifies if a `SelectionSet` may be converted to an `InlineFragment` and performs
the conversion.

- Warning: This function is not supported for use outside of generated call sites.
Generated call sites are guaranteed by the GraphQL compiler to be safe.
Unsupported usage may result in unintended consequences including crashes.

### `_asInlineFragment(if:)`

```swift
@inlinable public func _asInlineFragment<T: SelectionSet>(
  if conditions: [Selection.Condition]
) -> T? where T.Schema == Schema
```

### `_asInlineFragment(if:)`

```swift
@inlinable public func _asInlineFragment<T: SelectionSet>(
  if condition: Selection.Condition
) -> T? where T.Schema == Schema
```

### `hash(into:)`

```swift
@inlinable public func hash(into hasher: inout Hasher)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| hasher | The hasher to use when combining the components of this instance. |

### `==(_:_:)`

```swift
@inlinable public static func ==(lhs: Self, rhs: Self) -> Bool
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| lhs | A value to compare. |
| rhs | Another value to compare. |