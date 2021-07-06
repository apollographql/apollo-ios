**PROTOCOL**

# `SQLiteDatabase`

```swift
public protocol SQLiteDatabase
```

## Methods
### `init(fileURL:)`

```swift
init(fileURL: URL) throws
```

### `createRecordsTableIfNeeded()`

```swift
func createRecordsTableIfNeeded() throws
```

### `selectRawRows(forKeys:)`

```swift
func selectRawRows(forKeys keys: Set<CacheKey>) throws -> [DatabaseRow]
```

### `addOrUpdateRecordString(_:for:)`

```swift
func addOrUpdateRecordString(_ recordString: String, for cacheKey: CacheKey) throws
```

### `deleteRecord(for:)`

```swift
func deleteRecord(for cacheKey: CacheKey) throws
```

### `deleteRecords(matching:)`

```swift
func deleteRecords(matching pattern: CacheKey) throws
```

### `clearDatabase(shouldVacuumOnClear:)`

```swift
func clearDatabase(shouldVacuumOnClear: Bool) throws
```
