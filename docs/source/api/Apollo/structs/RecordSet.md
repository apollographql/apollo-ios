**STRUCT**

# `RecordSet`

```swift
public struct RecordSet: Hashable
```

A set of cache records.

## Properties
### `storage`

```swift
public private(set) var storage: [CacheKey: Record] = [:]
```

### `isEmpty`

```swift
public var isEmpty: Bool
```

### `keys`

```swift
public var keys: Set<CacheKey>
```

## Methods
### `init(records:)`

```swift
public init<S: Sequence>(records: S) where S.Iterator.Element == Record
```

### `insert(_:)`

```swift
public mutating func insert(_ record: Record)
```

### `removeRecord(for:)`

```swift
public mutating func removeRecord(for key: CacheKey)
```

### `removeRecords(matching:)`

```swift
public mutating func removeRecords(matching pattern: CacheKey)
```

### `clear()`

```swift
public mutating func clear()
```

### `insert(contentsOf:)`

```swift
public mutating func insert<S: Sequence>(contentsOf records: S) where S.Iterator.Element == Record
```

### `merge(records:)`

```swift
@discardableResult public mutating func merge(records: RecordSet) -> Set<CacheKey>
```

### `merge(record:)`

```swift
@discardableResult public mutating func merge(record: Record) -> Set<CacheKey>
```
