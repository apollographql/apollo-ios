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
public func loadRecords(forKeys keys: Set<CacheKey>) throws -> [CacheKey: Record]
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| key | The cache keys to load data for |

### `removeRecord(for:)`

```swift
public func removeRecord(for key: CacheKey) throws
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| key | The cache key to remove the record for |

### `merge(records:)`

```swift
public func merge(records newRecords: RecordSet) throws -> Set<CacheKey>
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| records | The set of records to merge. |

### `clear()`

```swift
public func clear()
```
