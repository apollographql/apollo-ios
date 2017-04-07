import SQLite

enum SqliteNormalizedCacheError: Error {
  case invalidRecordEncoding(record: String)
  case invalidRecordShape(record: String)
}

final class SqliteNormalizedCache: NormalizedCache {

  init(fileURL: URL) throws {
    db = try Connection(.uri(fileURL.absoluteString), readonly: false)
    try createTableIfNeeded()
  }

  public func merge(records: RecordSet) -> Promise<Set<CacheKey>> {
    return Promise<Set<CacheKey>> { fulfill, reject in
      do {
        fulfill(try mergeRecords(records: records))
      }
      catch {
        reject(error)
      }
    }
  }

  public func loadRecords(forKeys keys: [CacheKey]) -> Promise<[Record?]> {
    return Promise<[Record?]> { fulfill, reject in
      do {
        fulfill(try selectRecords(forKeys: keys))
      }
      catch {
        reject(error)
      }
    }
  }

  private let db: Connection
  private let records = Table("records")
  private let id = Expression<Int64>("_id")
  private let key = Expression<CacheKey>("key")
  private let record = Expression<String>("record")

  private func recordCacheKey(forFieldCacheKey fieldCacheKey: CacheKey) -> CacheKey {
    var components = fieldCacheKey.components(separatedBy: ".")
    if components.count > 1 {
      components.removeLast()
    }
    return components.joined(separator: ".")
  }

  private func createTableIfNeeded() throws {
    try db.run(records.create(ifNotExists: true) { table in
      table.column(id, primaryKey: .autoincrement)
      table.column(key, unique: true)
      table.column(record)
    })
    try db.run(records.createIndex([key], unique: true, ifNotExists: true))
  }

  private func mergeRecords(records: RecordSet) throws -> Set<CacheKey> {
    var recordSet = RecordSet(records: try selectRecords(forKeys: records.keys))
    let changedFieldKeys = recordSet.merge(records: records)
    let changedRecordKeys = changedFieldKeys.map { recordCacheKey(forFieldCacheKey: $0) }
    for recordKey in Set(changedRecordKeys) {
      if let recordFields = recordSet[recordKey]?.fields {
        let recordData = try SqliteJSONSerializationFormat.serialize(value: recordFields)
        guard let recordString = String(data: recordData, encoding: .utf8) else {
          assertionFailure() // Serialization should yield UTF-8 data
          continue
        }
        try db.run(self.records.insert(or: .replace, self.key <- recordKey, self.record <- recordString))
      }
    }
    return Set(changedFieldKeys)
  }

  private func selectRecords(forKeys keys: [CacheKey]) throws -> [Record] {
    let query = records.filter(keys.contains(key))
    return try db.prepare(query).map { try parse(row: $0) }
  }

  private func parse(row: Row) throws -> Record {
    let record = row[self.record]

    guard let recordData = record.data(using: .utf8) else {
      throw SqliteNormalizedCacheError.invalidRecordEncoding(record: record)
    }

    guard let recordJSON = (try SqliteJSONSerializationFormat.deserialize(data: recordData)) as? JSONObject else {
      throw SqliteNormalizedCacheError.invalidRecordShape(record: record)
    }

    return Record(key: row[key], recordJSON)
  }
}

final class SqliteJSONSerializationFormat {
  class func serialize(value: JSONEncodable) throws -> Data {
    return try JSONSerializationFormat.serialize(value: value)
  }

  class func deserialize(data: Data) throws -> JSONValue {
    let json = try JSONSerializationFormat.deserialize(data: data)
    return deserializeReferences(json: json)
  }

  private class func deserializeReferences(json: JSONValue) -> JSONValue {
    switch json {
    case let dictionary as JSONObject:
      var newDictionary = JSONObject()
      for (key, value) in dictionary {
        newDictionary[key] = deserializeReferences(json: value)
      }
      return newDictionary
    case let array as [JSONValue]:
      return array.map { deserializeReferences(json: $0) }
    case let string as String:
      if let prefixRange = string.range(of: "Reference:") {
        return Reference(key: string.substring(from: prefixRange.upperBound))
      }
      return string
    default:
      return json
    }
  }
}

extension Reference: JSONEncodable {
  public var jsonValue: JSONValue {
    return "Reference:\(self.key)"
  }
}
