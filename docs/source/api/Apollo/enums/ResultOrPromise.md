**ENUM**

# `ResultOrPromise`

```swift
public enum ResultOrPromise<Value>
```

## Cases
### `result(_:)`

```swift
case result(Result<Value, Error>)
```

### `promise(_:)`

```swift
case promise(Promise<Value>)
```

## Properties
### `result`

```swift
public var result: Result<Value, Error>?
```

## Methods
### `init(_:)`

```swift
public init(_ body: () throws -> Value)
```

### `await()`

```swift
public func await() throws -> Value
```

### `andThen(_:)`

```swift
@discardableResult public func andThen(_ whenFulfilled: @escaping (Value) throws -> Void) -> ResultOrPromise<Value>
```

### `catch(_:)`

```swift
@discardableResult public func `catch`(_ whenRejected: @escaping (Error) throws -> Void) -> ResultOrPromise<Value>
```

### `map(_:)`

```swift
public func map<T>(_ transform: @escaping (Value) throws -> T) -> ResultOrPromise<T>
```

### `flatMap(_:)`

```swift
public func flatMap<T>(_ transform: @escaping (Value) throws -> ResultOrPromise<T>) -> ResultOrPromise<T>
```

### `on(queue:)`

```swift
public func on(queue: DispatchQueue) -> ResultOrPromise<Value>
```
