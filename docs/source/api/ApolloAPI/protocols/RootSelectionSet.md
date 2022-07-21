**PROTOCOL**

# `RootSelectionSet`

```swift
public protocol RootSelectionSet: AnySelectionSet, OutputTypeConvertible
```

A selection set that represents the root selections on its `__parentType`. Nested selection
sets for type cases are not `RootSelectionSet`s.

While a `TypeCase` only provides the additional selections that should be selected for its
specific type, a `RootSelectionSet` guarantees that all fields for itself and its nested type
cases are selected.

When considering a specific `TypeCase`, all fields will be selected either by the root selection
set, a fragment spread, the type case itself, or another compatible `TypeCase` on the root
selection set.

This is why only a `RootSelectionSet` can be executed by a `GraphQLExecutor`. Executing a
non-root selection set would result in fields from the root selection set not being collected
into the `ResponseDict` for the `SelectionSet`'s data.
