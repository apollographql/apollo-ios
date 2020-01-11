import Foundation

public struct RecordRow {
  public internal(set) var record: Record
  public internal(set) var lastModifiedAt: Date
}

/// A set of cache records.
public struct RecordSet {
  public private(set) var storage: [CacheKey: RecordRow] = [:]

  public init<S: Sequence>(records: S) where S.Iterator.Element == Record {
    insert(contentsOf: records)
  }

  public mutating func insert(_ record: Record) {
    storage[record.key] = .init(record: record, lastModifiedAt: Date())
  }

  public mutating func clear() {
    storage.removeAll()
  }

  public mutating func insert<S: Sequence>(contentsOf records: S) where S.Iterator.Element == Record {
    for record in records {
      insert(record)
    }
  }

  public subscript(key: CacheKey) -> Record? {
    return storage[key]?.record
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
        oldRow.lastModifiedAt = Date()
        changedKeys.insert([record.key, key].joined(separator: "."))
      }
      storage[record.key] = oldRow
      return changedKeys
    } else {
      storage[record.key] = .init(record: record, lastModifiedAt: Date())
      return Set(record.fields.keys.map { [record.key, $0].joined(separator: ".") })
    }
  }
}

extension RecordSet: ExpressibleByDictionaryLiteral {
  public init(dictionaryLiteral elements: (CacheKey, Record.Fields)...) {
    self.init(records: elements.map { Record(key: $0.0, $0.1) })
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
