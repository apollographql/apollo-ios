**CLASS**

# `InMemoryNormalizedCache`

```swift
public final class InMemoryNormalizedCache: NormalizedCache
```

## Methods
### `init(records:)`

```swift
public init(records: RecordSet = RecordSet())
```

### `loadRecords(forKeys:)`

```swift
public func loadRecords(forKeys keys: [CacheKey]) -> Promise<[Record?]>
```

### `merge(records:)`

```swift
public func merge(records: RecordSet) -> Promise<Set<CacheKey>>
```

### `clear()`

```swift
public func clear() -> Promise<Void>
```
