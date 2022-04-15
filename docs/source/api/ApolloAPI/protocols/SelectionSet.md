**PROTOCOL**

# `SelectionSet`

```swift
public protocol SelectionSet: ResponseObject, Equatable
```

## Properties
### `__parentType`

```swift
static var __parentType: SelectionSetType<Schema>
```

The GraphQL type for the `SelectionSet`.

This may be a concrete type (`ConcreteType`) or an abstract type (`Interface`).
