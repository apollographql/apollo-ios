**STRUCT**

# `ResponsePath`

```swift
public struct ResponsePath: ExpressibleByArrayLiteral
```

Represents a list of string components joined into a path using a reverse linked list.

A response path is stored as a linked list because using an array turned out to be
a performance bottleneck during decoding/execution.

In order to optimize for calculation of a path string, `ResponsePath` does not allow insertion
of components in the middle or at the beginning of the path. Components may only be appended to
the end of an existing path.

## Properties
### `joined`

```swift
public var joined: String
```

### `isEmpty`

```swift
public var isEmpty: Bool
```

## Methods
### `toArray()`

```swift
public func toArray() -> [String]
```

### `init(arrayLiteral:)`

```swift
public init(arrayLiteral segments: Key...)
```

### `init(_:)`

```swift
public init(_ key: Key)
```

### `append(_:)`

```swift
public mutating func append(_ key: Key)
```

### `appending(_:)`

```swift
public func appending(_ key: Key) -> ResponsePath
```

### `+(_:_:)`

```swift
public static func + (lhs: ResponsePath, rhs: Key) -> ResponsePath
```

### `+(_:_:)`

```swift
public static func + (lhs: ResponsePath, rhs: ResponsePath) -> ResponsePath
```

### `+(_:_:)`

```swift
public static func + <T: Sequence>(
  lhs: ResponsePath, rhs: T
) -> ResponsePath where T.Element == Key
```
