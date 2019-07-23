**CLASS**

# `SQLiteNormalizedCache`

```swift
public final class SQLiteNormalizedCache
```

> A `NormalizedCache` implementation which uses a SQLite database to store data.

## Methods
### `init(fileURL:shouldVacuumOnClear:)`

```swift
public init(fileURL: URL, shouldVacuumOnClear: Bool = false) throws
```

> Designated initializer
>
> - Parameters:
>   - fileURL: The file URL to use for your database.
>   - shouldVacuumOnClear: If the database should also be `VACCUM`ed on clear to remove all traces of info. Defaults to `false` since this involves a performance hit, but this should be used if you are storing any Personally Identifiable Information in the cache.
> - Throws: Any errors attempting to open or create the database.

#### Parameters

| Name | Description |
| ---- | ----------- |
| fileURL | The file URL to use for your database. |
| shouldVacuumOnClear | If the database should also be `VACCUM`ed on clear to remove all traces of info. Defaults to `false` since this involves a performance hit, but this should be used if you are storing any Personally Identifiable Information in the cache. |