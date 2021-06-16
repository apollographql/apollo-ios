**PROTOCOL**

# `Fragment`

```swift
public protocol Fragment: SelectionSet
```

A protocol representing a fragment that a `ResponseObject` object may be converted to.

A `ResponseObject` that conforms to `HasFragments` can be converted to
any `Fragment` included in it's `Fragments` object via its `fragments` property.

- SeeAlso: `HasFragments`, `ToFragments`
