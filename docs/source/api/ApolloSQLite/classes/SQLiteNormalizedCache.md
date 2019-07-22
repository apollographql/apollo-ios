**CLASS**

# `SQLiteNormalizedCache`

```swift
public final class SQLiteNormalizedCache: NormalizedCache
```

## Methods
### `init(fileURL:)`

```swift
public init(fileURL: URL) throws
```

### `merge(records:)`

```swift
public func merge(records: RecordSet) -> Promise<Set<CacheKey>>
```

### `loadRecords(forKeys:)`

```swift
public func loadRecords(forKeys keys: [CacheKey]) -> Promise<[Record?]>
```

### `clear()`

```swift
public func clear() -> Promise<Void>
```
