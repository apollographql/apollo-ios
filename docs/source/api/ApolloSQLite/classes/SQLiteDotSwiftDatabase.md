**CLASS**

# `SQLiteDotSwiftDatabase`

```swift
public final class SQLiteDotSwiftDatabase: SQLiteDatabase
```

## Methods
### `init(fileURL:)`

```swift
public init(fileURL: URL) throws
```

### `init(connection:)`

```swift
public init(connection: Connection)
```

### `createRecordsTableIfNeeded()`

```swift
public func createRecordsTableIfNeeded() throws
```

### `selectRawRows(forKeys:)`

```swift
public func selectRawRows(forKeys keys: Set<CacheKey>) throws -> [DatabaseRow]
```

### `addOrUpdateRecordString(_:for:)`

```swift
public func addOrUpdateRecordString(_ recordString: String, for cacheKey: CacheKey) throws
```

### `deleteRecord(for:)`

```swift
public func deleteRecord(for cacheKey: CacheKey) throws
```

### `deleteRecords(matching:)`

```swift
public func deleteRecords(matching pattern: CacheKey) throws
```

### `clearDatabase(shouldVacuumOnClear:)`

```swift
public func clearDatabase(shouldVacuumOnClear: Bool) throws
```
