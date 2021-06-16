**CLASS**

# `Atomic`

```swift
public class Atomic<T>
```

Wrapper for a value protected by an NSLock

## Properties
### `value`

```swift
public var value: T
```

The current value. Read-only. To update the underlying value, use `mutate`.

## Methods
### `init(_:)`

```swift
public init(_ value: T)
```

Designated initializer

- Parameter value: The value to begin with.

#### Parameters

| Name | Description |
| ---- | ----------- |
| value | The value to begin with. |

### `mutate(block:)`

```swift
public func mutate<U>(block: (inout T) -> U) -> U
```

Mutates the underlying value within a lock.
- Parameter block: The block to execute to mutate the value.
- Returns: The value returned by the block.

#### Parameters

| Name | Description |
| ---- | ----------- |
| block | The block to execute to mutate the value. |