**EXTENSION**

# `SQLiteNormalizedCache`
```swift
extension SQLiteNormalizedCache: NormalizedCache
```

## Methods
### `merge(records:callbackQueue:completion:)`

```swift
public func merge(records: RecordSet,
                  callbackQueue: DispatchQueue?,
                  completion: @escaping (Swift.Result<Set<CacheKey>, Error>) -> Void)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| records | The set of records to merge. |
| callbackQueue | [optional] An alternate queue to fire the completion closure on. If nil, will fire on the current queue. |
| completion | A completion closure to fire when the merge has completed. If successful, will contain a set of keys corresponding to  that have changed (i.e. QUERY_ROOT.Foo.myField). These are the same type of keys as are returned by RecordSet.merge(records:). |

### `loadRecords(forKeys:callbackQueue:completion:)`

```swift
public func loadRecords(forKeys keys: [CacheKey],
                        callbackQueue: DispatchQueue?,
                        completion: @escaping (Swift.Result<[Record?], Error>) -> Void)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| keys | The cache keys to load data for |
| callbackQueue | [optional] An alternate queue to fire the completion closure on. If nil, will fire on the current queue. |
| completion | A completion closure to fire when the load has completed. If successful, will contain an array. Each index will contain either the record corresponding to the key at the same index in the passed-in array of cache keys, or nil if that record was not found. |

### `clear(callbackQueue:completion:)`

```swift
public func clear(callbackQueue: DispatchQueue?, completion: ((Swift.Result<Void, Error>) -> Void)?)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| callbackQueue | [optional] An alternate queue to fire the completion closure on. If nil, will fire on the current queue. |
| completion | [optional] A completion closure to fire when the clear function has completed. |

### `clearImmediately()`

```swift
public func clearImmediately() throws
```
