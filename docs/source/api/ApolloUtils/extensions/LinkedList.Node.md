**EXTENSION**

# `LinkedList.Node`
```swift
extension LinkedList.Node: Equatable where T: Equatable
```

## Properties
### `debugDescription`

```swift
public var debugDescription: String
```

## Methods
### `==(_:_:)`

```swift
public static func == (lhs: LinkedList<T>.Node, rhs: LinkedList<T>.Node) -> Bool
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| lhs | A value to compare. |
| rhs | Another value to compare. |

### `hash(into:)`

```swift
public func hash(into hasher: inout Hasher)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| hasher | The hasher to use when combining the components of this instance. |

### `makeIterator()`

```swift
public func makeIterator() -> Iterator
```
