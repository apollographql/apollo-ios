**EXTENSION**

# `FragmentContainer`
```swift
extension FragmentContainer
```

## Methods
### `_toFragment()`

```swift
@inlinable public func _toFragment<T: Fragment>() -> T
```

Converts a `SelectionSet` to a `Fragment` given a generic fragment type.

- Warning: This function is not supported for use outside of generated call sites.
Generated call sites are guaranteed by the GraphQL compiler to be safe.
Unsupported usage may result in unintended consequences including crashes.

### `_toFragment(if:)`

```swift
@inlinable public func _toFragment<T: Fragment>(
  if conditions: Selection.Conditions? = nil
) -> T?
```

### `_toFragment(if:)`

```swift
@inlinable public func _toFragment<T: Fragment>(
  if conditions: [Selection.Condition]
) -> T?
```

### `_toFragment(if:)`

```swift
@inlinable public func _toFragment<T: Fragment>(
  if condition: Selection.Condition
) -> T?
```
