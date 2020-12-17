**EXTENSION**

# `SQLiteNormalizedCache`
```swift
extension SQLiteNormalizedCache: NormalizedCache
```

## Methods
### `loadRecords(forKeys:)`

```swift
public func loadRecords(forKeys keys: Set<CacheKey>) throws -> [CacheKey: Record]
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| key | The cache keys to load data for |

### `merge(records:)`

```swift
public func merge(records: RecordSet) throws -> Set<CacheKey>
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| records | The set of records to merge. |

### `clear()`

```swift
public func clear() throws
```
