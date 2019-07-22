**CLASS**

# `Promise`

```swift
public final class Promise<Value>
```

## Properties
### `isPending`

```swift
public var isPending: Bool
```

### `result`

```swift
public var result: Result<Value, Error>?
```

## Methods
### `init(resolved:)`

```swift
public init(resolved result: Result<Value, Error>)
```

### `init(fulfilled:)`

```swift
public init(fulfilled value: Value)
```

### `init(rejected:)`

```swift
public init(rejected error: Error)
```

### `init(_:)`

```swift
public init(_ body: () throws -> Value)
```

### `init(_:)`

```swift
public init(_ body: (_ fulfill: @escaping (Value) -> Void, _ reject: @escaping (Error) -> Void) throws -> Void)
```

### `wait()`

```swift
public func wait()
```

### `await()`

```swift
public func await() throws -> Value
```

### `andThen(_:)`

```swift
@discardableResult public func andThen(_ whenFulfilled: @escaping (Value) throws -> Void) -> Promise<Value>
```

### `catch(_:)`

```swift
@discardableResult public func `catch`(_ whenRejected: @escaping (Error) throws -> Void) -> Promise<Value>
```

### `finally(_:)`

```swift
@discardableResult public func finally(_ whenResolved: @escaping () -> Void) -> Promise<Value>
```

### `map(_:)`

```swift
public func map<T>(_ transform: @escaping (Value) throws -> T) -> Promise<T>
```

### `flatMap(_:)`

```swift
public func flatMap<T>(_ transform: @escaping (Value) throws -> Promise<T>) -> Promise<T>
```

### `on(queue:)`

```swift
public func on(queue: DispatchQueue) -> Promise<Value>
```
