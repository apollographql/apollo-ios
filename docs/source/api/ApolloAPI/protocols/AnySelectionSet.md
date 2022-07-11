**PROTOCOL**

# `AnySelectionSet`

```swift
public protocol AnySelectionSet: SelectionSetEntityValue
```

## Properties
### `schema`

```swift
static var schema: SchemaConfiguration.Type
```

### `selections`

```swift
static var selections: [Selection]
```

### `__parentType`

```swift
static var __parentType: ParentType
```

The GraphQL type for the `SelectionSet`.

This may be a concrete type (`Object`) or an abstract type (`Interface`, or `Union`).

### `__data`

```swift
var __data: DataDict
```

## Methods
### `init(data:)`

```swift
init(data: DataDict)
```
