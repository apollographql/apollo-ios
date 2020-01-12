import Foundation

public struct RecordRow {
  public internal(set) var record: Record
  public internal(set) var lastModifiedAt: Timestamp

  public init(record: Record, lastModifiedAt: Timestamp) {
    self.record = record
    self.lastModifiedAt = lastModifiedAt
  }
}

/// A set of cache records.
public struct RecordSet {
  public private(set) var storage: [CacheKey: RecordRow] = [:]

  public init<S: Sequence>(rows: S) where S.Iterator.Element == RecordRow {
    insert(contentsOf: rows)
  }

  init(_ dictionary: Dictionary<CacheKey, (Record.Fields, Date)>) {
    self.init(rows: dictionary.map { RecordRow(record: Record(key: $0.0, $0.1.0), lastModifiedAt: $0.1.1.milisecondsSince1970) })
  }

  public mutating func insert(_ row: RecordRow) {
    storage[row.record.key] = row
  }

  public mutating func clear() {
    storage.removeAll()
  }

  public mutating func insert<S: Sequence>(contentsOf rows: S) where S.Iterator.Element == RecordRow {
    for row in rows {
      insert(row)
    }
  }

  public subscript(key: CacheKey) -> RecordRow? {
    return storage[key]
  }

  public var isEmpty: Bool {
    return storage.isEmpty
  }

  public var keys: [CacheKey] {
    return Array(storage.keys)
  }

  @discardableResult public mutating func merge(records: RecordSet) -> Set<CacheKey> {
    var changedKeys: Set<CacheKey> = Set()

    for (_, row) in records.storage {
      changedKeys.formUnion(merge(record: row.record))
    }

    return changedKeys
  }

  @discardableResult public mutating func merge(record: Record) -> Set<CacheKey> {
    if var oldRow = storage.removeValue(forKey: record.key) {
      var changedKeys: Set<CacheKey> = Set()

      for (key, value) in record.fields {
        if let oldValue = oldRow.record.fields[key], equals(oldValue, value) {
          continue
        }
        oldRow.record[key] = value
        oldRow.lastModifiedAt = Date().milisecondsSince1970
        changedKeys.insert([record.key, key].joined(separator: "."))
      }
      storage[record.key] = oldRow
      return changedKeys
    } else {
      storage[record.key] = .init(record: record, lastModifiedAt: Date().milisecondsSince1970)
      return Set(record.fields.keys.map { [record.key, $0].joined(separator: ".") })
    }
  }
}

extension RecordSet: ExpressibleByDictionaryLiteral {
  public init(dictionaryLiteral elements: (CacheKey, Record.Fields)...) {
    self.init(rows: elements.map { RecordRow(record: Record(key: $0.0, $0.1), lastModifiedAt: Date().milisecondsSince1970) })
  }
}

extension RecordSet: CustomStringConvertible {
  public var description: String {
    return String(describing: Array(storage.values))
  }
}

extension RecordSet: CustomPlaygroundDisplayConvertible {
  public var playgroundDescription: Any {
     return description
  }
}
