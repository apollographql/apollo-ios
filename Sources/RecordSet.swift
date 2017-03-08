/// A set of cache records.
public struct RecordSet {
  fileprivate var storage: [CacheKey: Record] = [:]
  
  init<S: Sequence>(records: S) where S.Iterator.Element == Record {
    insert(contentsOf: records)
  }
  
  mutating func insert(_ record: Record) {
    storage[record.key] = record
  }
  
  mutating func insert<S: Sequence>(contentsOf records: S) where S.Iterator.Element == Record {
    for record in records {
      insert(record)
    }
  }
  
  subscript(key: CacheKey) -> Record? {
    return storage[key]
  }
  
  var isEmpty: Bool {
    return storage.isEmpty
  }
  
  @discardableResult mutating func merge(records: RecordSet) -> Set<CacheKey> {
    var changedKeys: Set<CacheKey> = Set()
    
    for (_, record) in records.storage {
      changedKeys.formUnion(merge(record: record))
    }
    
    return changedKeys
  }
  
  @discardableResult mutating func merge(record: Record) -> Set<CacheKey> {
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
  public init(dictionaryLiteral elements: (CacheKey, JSONObject)...) {
    self.init(records: elements.map { Record(key: $0.0, $0.1) })
  }
}

extension RecordSet: CustomStringConvertible {
  public var description: String {
    return String(describing: Array(storage.values))
  }
}

extension RecordSet: CustomPlaygroundQuickLookable {
  public var customPlaygroundQuickLook: PlaygroundQuickLook {
    return .text(description)
  }
}
