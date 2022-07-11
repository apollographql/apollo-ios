**PROTOCOL**

# `InlineFragment`

```swift
public protocol InlineFragment: AnySelectionSet
```

A selection set that represents an inline fragment nested inside a `RootSelectionSet`.

An `InlineFragment` can only ever exist as a nested selection set within a `RootSelectionSet`.
Each `InlineFragment` represents additional fields to be selected if the underlying
type.inclusion condition of the object data returned for the selection set is met.

An `InlineFragment` will only include the specific `selections` that should be selected for that
`InlineFragment`. But the code generation engine will create accessor fields for any fields
from the fragment's parent `RootSelectionSet` that will be selected. This includes fields from
the parent selection set, as well as any other child selections sets that are compatible with
the `InlineFragment`'s `__parentType` and the operation's inclusion condition.
