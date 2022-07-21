**ENUM**

# `Selection`

```swift
public enum Selection
```

## Cases
### `field(_:)`

```swift
case field(Field)
```

A single field selection.

### `fragment(_:)`

```swift
case fragment(Fragment.Type)
```

A fragment spread of a named fragment definition.

### `inlineFragment(_:)`

```swift
case inlineFragment(ApolloAPI.InlineFragment.Type)
```

An inline fragment with a child selection set nested in a parent selection set.

### `conditional(_:_:)`

```swift
case conditional(Conditions, [Selection])
```

A group of selections that have `@include/@skip` directives.

## Methods
### `field(_:alias:_:arguments:)`

```swift
static public func field(
  _ name: String,
  alias: String? = nil,
  _ type: OutputTypeConvertible.Type,
  arguments: [String: InputValue]? = nil
) -> Selection
```

### `include(if:_:)`

```swift
static public func include(
  if condition: String,
  _ selection: Selection
) -> Selection
```

### `include(if:_:)`

```swift
static public func include(
  if condition: String,
  _ selections: [Selection]
) -> Selection
```

### `include(if:_:)`

```swift
static public func include(
  if conditions: Conditions,
  _ selection: Selection
) -> Selection
```

### `include(if:_:)`

```swift
static public func include(
  if conditions: Conditions,
  _ selections: [Selection]
) -> Selection
```

### `include(if:_:)`

```swift
static public func include(
  if condition: Condition,
  _ selection: Selection
) -> Selection
```

### `include(if:_:)`

```swift
static public func include(
  if condition: Condition,
  _ selections: [Selection]
) -> Selection
```

### `include(if:_:)`

```swift
static public func include(
  if conditions: [Condition],
  _ selection: Selection
) -> Selection
```

### `include(if:_:)`

```swift
static public func include(
  if conditions: [Condition],
  _ selections: [Selection]
) -> Selection
```
