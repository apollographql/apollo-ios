**PROTOCOL**

# `Fragment`

```swift
public protocol Fragment: AnySelectionSet
```

A protocol representing a fragment that a `SelectionSet` object may be converted to.

A `SelectionSet` can be converted to any `Fragment` included in it's `Fragments` object via
its `fragments` property.

## Properties
### `fragmentDefinition`

```swift
static var fragmentDefinition: StaticString
```
