public struct RecordSet {
  fileprivate var storage: [Key: Record] = [:]
  
  init(records: [Record]) {
    for record in records {
      storage[record.key] = record
    }
  }
  
  var isEmpty: Bool {
    return storage.isEmpty
  }
  
  subscript(key: Key) -> Record? {
    get {
      return storage[key]
    }
    set {
      storage[key] = newValue
    }
  }
  
  subscript(key: Key, fieldKey: Key) -> JSONValue? {
    get {
      return storage[key]?[fieldKey]
    }
    set {
      if var oldRecord = storage.removeValue(forKey: key) {
        oldRecord[fieldKey] = newValue
        storage[key] = oldRecord
      } else {
        storage[key] = Record(key: key, [fieldKey: newValue as Any])
      }
    }
  }
  
  mutating func merge(record: Record) {
    if var oldRecord = storage.removeValue(forKey: record.key) {
      for (key, value) in record.fields {
        oldRecord[key] = value
      }
      storage[record.key] = oldRecord
    } else {
      storage[record.key] = record
    }
  }
  
  mutating func merge(recordSet: RecordSet) {
    for (_, record) in recordSet.storage {
      merge(record: record)
    }
  }
}

extension RecordSet: ExpressibleByDictionaryLiteral {
  public init(dictionaryLiteral elements: (Key, JSONObject)...) {
    self.init(records: elements.map { Record(key: $0.0, $0.1) })
  }
}

extension RecordSet: CustomDebugStringConvertible {
  public var debugDescription: String {
    return storage.debugDescription
  }
}
