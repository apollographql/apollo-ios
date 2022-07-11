**STRUCT**

# `LinkedList`

```swift
public struct LinkedList<T>: ExpressibleByArrayLiteral
```

A doubly linked list implementation.

This implementation utilizes copy on write semantics and is optimized for forward and backwards
traversal and appending items (which requires accessing last).

It is not optimized for prepending or insertion of items.

## Properties
### `head`

```swift
public var head: Node
```

The head (first) node in the list

### `last`

```swift
public var last: Node
```

The last node in the list

## Methods
### `init(_:)`

```swift
public init(_ headValue: T)
```

### `init(array:)`

```swift
public init(array: [T])
```

### `init(arrayLiteral:)`

```swift
public init(arrayLiteral segments: T...)
```

### `append(_:)`

```swift
public mutating func append(_ value: T)
```

### `append(_:)`

```swift
public mutating func append<S: Sequence>(_ sequence: S) where S.Element == T
```

### `appending(_:)`

```swift
public func appending(_ value: T) -> LinkedList<T>
```

### `appending(_:)`

```swift
public func appending<S: Sequence>(
  _ sequence: S
) -> LinkedList<T> where S.Element == T
```

### `mutateLast(_:)`

```swift
public mutating func mutateLast(_ mutate: (T) -> T)
```

### `mutatingLast(_:)`

```swift
public func mutatingLast(_ mutate: (T) -> T) -> LinkedList<T>
```

### `+(_:_:)`

```swift
public static func +<S: Sequence>(
  lhs: LinkedList<T>,
  rhs: S
) -> LinkedList<T> where S.Element == T
```

### `+=(_:_:)`

```swift
public static func +=<S: Sequence>(
  lhs: inout LinkedList<T>,
  rhs: S
) where S.Element == T
```
