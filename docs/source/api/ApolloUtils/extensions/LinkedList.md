**EXTENSION**

# `LinkedList`
```swift
extension LinkedList: Equatable where T: Equatable
```

## Properties
### `startIndex`

```swift
public var startIndex: Int
```

### `endIndex`

```swift
public var endIndex: Int
```

### `count`

```swift
public var count: Int
```

### `isEmpty`

```swift
public var isEmpty: Bool
```

### `debugDescription`

```swift
public var debugDescription: String
```

## Methods
### `==(_:_:)`

```swift
public static func == (lhs: LinkedList<T>, rhs: LinkedList<T>) -> Bool
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

### `node(at:)`

```swift
public func node(at position: Int) -> Node
```

### `index(after:)`

```swift
public func index(after i: Int) -> Int
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| i | A valid index of the collection. `i` must be less than `endIndex`. |

### `makeIterator()`

```swift
public func makeIterator() -> Iterator
```
