**CLASS**

# `Atomic`

```swift
public class Atomic<T>
```

> Wrapper for a value protected by an NSLock

## Properties
### `value`

```swift
public var value: T
```

> The current value.

## Methods
### `init(_:)`

```swift
public init(_ value: T)
```

> Designated initializer
>
> - Parameter value: The value to begin with.

#### Parameters

| Name | Description |
| ---- | ----------- |
| value | The value to begin with. |

### `mutate(block:)`

```swift
public func mutate(block: (inout T) -> Void)
```

> Mutates the underlying value within a lock. Mostly useful for mutating the contents of `Atomic` wrappers around collections.
> - Parameter block: The block to execute to mutate the value.

#### Parameters

| Name | Description |
| ---- | ----------- |
| block | The block to execute to mutate the value. |