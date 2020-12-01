**PROTOCOL**

# `NormalizedCache`

```swift
public protocol NormalizedCache
```

## Methods
### `loadRecords(forKeys:)`

```swift
func loadRecords(forKeys keys: Set<CacheKey>) throws -> [CacheKey: Record]
```

> Loads records corresponding to the given keys.
>
> - Parameters:
>   - key: The cache keys to load data for
> - Returns: A dictionary of cache keys to records containing the records that have been found.

#### Parameters

| Name | Description |
| ---- | ----------- |
| key | The cache keys to load data for |

### `merge(records:)`

```swift
func merge(records: RecordSet) throws -> Set<CacheKey>
```

> Merges a set of records into the cache.
>
> - Parameters:
>   - records: The set of records to merge.
> - Returns: A set of keys corresponding to *fields* that have changed (i.e. QUERY_ROOT.Foo.myField). These are the same type of keys as are returned by RecordSet.merge(records:).

#### Parameters

| Name | Description |
| ---- | ----------- |
| records | The set of records to merge. |

### `clear()`

```swift
func clear() throws
```

> Clears all records.
