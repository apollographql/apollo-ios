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
        var recordSet = RecordSet(records: try select(withKeys: records.keys))
        let changedFieldKeys = recordSet.merge(records: records)
        // Shouldn't changedKeys contain full cache key (rather than just one level deep from QUERY_ROOT)?
        // (e.g. it has "QUERY_ROOT.hero" but it wouldn't have anything nested any further than that)
        // Also, shouldn't it rely on the passed-in cache key function rather than response shape path with periods?
        // TODO: first map and unique first components, to avoid duplicate work
        for changedFieldKey in changedFieldKeys {
          if let recordKey = recordCacheKey(forFieldCacheKey: changedFieldKey),
            let recordFields = recordSet[recordKey]?.fields
          {
            let recordData = try SqliteJSONSerializationFormat.serialize(value: recordFields)
            let recordString = String(data: recordData, encoding: .utf8)! // TODO: remove !
            print("\tupdating record: \(recordKey): \(recordString)...")
            let rowid = try db.run(self.records.insert(or: .replace, self.key <- recordKey, self.record <- recordString))
            print("\t\trowid: \(rowid)")
          }
        }
        print("updated records: \(changedFieldKeys)")
        fulfill(Set(changedFieldKeys))
      }
      catch {
        print("failed updating records: \(error.localizedDescription)")
        reject(error)
      }
    }
  }

  public func loadRecords(forKeys keys: [CacheKey]) -> Promise<[Record?]> {
    return Promise<[Record?]> { fulfill, reject in
      print("\n\nloading records: \(keys)...") // TODO: remove
      do {
        // TODO: do on one line
        let records = try select(withKeys: keys)
        fulfill(records)
        print("finished loading records")
      }
      catch {
        print("failed loading records: \(error.localizedDescription)")
        reject(error)
      }
    }
  }

  private let db: Connection
  private let records = Table("records")
  private let id = Expression<Int64>("_id")
  private let key = Expression<CacheKey>("key")
  private let record = Expression<String>("record")

  private func recordCacheKey(forFieldCacheKey fieldCacheKey: CacheKey) -> CacheKey? {
    var components = fieldCacheKey.components(separatedBy: ".")
    components.removeLast()
    guard components.count > 0 else {
      return nil
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

  private func select(withKeys keys: [CacheKey]) throws -> [Record] {
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
      if let prefixRange = string.range(of: "ApolloCacheReference:") {
        return Reference(key: string.substring(from: prefixRange.upperBound))
      }
      return string
    default:
      return json
    }
  }
}

// TODO: ask about doing this
extension Reference: JSONEncodable {
  public var jsonValue: JSONValue {
    return "ApolloCacheReference:\(self.key)"
  }
}

//extension Reference: JSONDecodable {
//  public init(jsonValue value: JSONValue) throws {
//    guard let key = value as? CacheKey else {
//      throw JSONDecodingError.couldNotConvert(value: value, to: Reference.self)
//    }
//    self.init(key: key)
//  }
//}
