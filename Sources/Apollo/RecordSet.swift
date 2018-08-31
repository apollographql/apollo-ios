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
  
  @discardableResult public mutating func removeValue(forKey key: CacheKey) -> Set<CacheKey> {
    // remove the value for our key
    guard storage.removeValue(forKey: key) != nil else { return [] }
    
    // traverse the cache and find references to this key, and remove them
    var findAndRemove: ((inout Record) -> Set<CacheKey>)!
    findAndRemove = { record in
      var accumulator: Set<CacheKey> = []
      for (k, v) in record.fields {
        if var r = v as? Record {
          accumulator.formUnion( findAndRemove(&r) )
        } else if var array = v as? [Any] {
          var removed = false
          for (index, element) in array.enumerated() {
            if var r = element as? Record {
              accumulator.formUnion(findAndRemove(&r))
            } else if let ref = element as? Reference, ref.key == key {
              array.remove(at: index)
              removed = true
            }
            if removed {
              record[k] = array
              return [k]
            }
          }
        } else if let ref = v as? Reference, ref.key == key {
          record.fields[k] = nil
          return [k]
        }
      }
      return accumulator
    }
    var _storage = storage
    var changedKeys: Set<CacheKey> = []
    for (key, var value) in storage {
      let changed = findAndRemove(&value)
      if !changed.isEmpty {
        _storage[key] = value
        changedKeys.formUnion(changed)
      }
    }
    storage = _storage
    return changedKeys
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
