### `whenAll(_:notifyOn:)`

```swift
public func whenAll<Value>(_ resultsOrPromises: [ResultOrPromise<Value>], notifyOn queue: DispatchQueue = .global()) -> ResultOrPromise<[Value]>
```
