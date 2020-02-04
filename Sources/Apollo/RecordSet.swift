/// A set of cache records.
public struct RecordSet {
  public private(set) var storage: [CacheKey: Record] = [:]

  public init<S: Sequence>(records: S) where S.Iterator.Element == Record {
    insert(contentsOf: records)
  }

  public mutating func insert(_ record: Record) {
    storage[record.key] = record
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

    for (_, record) in records.storage {
      changedKeys.formUnion(merge(record: record))
    }

    return changedKeys
  }

  @discardableResult public mutating func merge(record: Record) -> Set<CacheKey> {
    if var oldRecord = storage.removeValue(forKey: record.key) {
      var changedKeys: Set<CacheKey> = Set()

      for (key, value) in record.fields {
        if let oldValue = oldRecord.fields[key], equals(oldValue, value) {
          continue
        }
        oldRecord[key] = value
        changedKeys.insert([record.key, key].joined(separator: "."))
      }
      storage[record.key] = oldRecord
      return changedKeys
    } else {
      storage[record.key] = record
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
