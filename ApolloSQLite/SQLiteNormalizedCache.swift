import Apollo
import SQLite

public enum SQLiteNormalizedCacheError: Error {
  case invalidRecordEncoding(record: String)
  case invalidRecordShape(object: Any)
  case invalidRecordValue(value: Any)
}

public final class SQLiteNormalizedCache: NormalizedCache {

  public init(fileURL: URL) throws {
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
        let records = try selectRecords(forKeys: keys)
        let recordsOrNil: [Record?] = keys.map { key in
          if let recordIndex = records.index(where: { $0.key == key }) {
            return records[recordIndex]
          }
          return nil
        }
        fulfill(recordsOrNil)
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
        let recordData = try SQLiteSerialization.serialize(fields: recordFields)
        guard let recordString = String(data: recordData, encoding: .utf8) else {
          assertionFailure("Serialization should yield UTF-8 data")
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
      throw SQLiteNormalizedCacheError.invalidRecordEncoding(record: record)
    }

    let recordJSON = try SQLiteSerialization.deserialize(data: recordData)
    return Record(key: row[key], recordJSON)
  }
}

private let serializedReferenceKey = "reference"

final class SQLiteSerialization {
  static func serialize(fields: JSONObject) throws -> Data {
    var objectToSerialize = JSONObject()
    for (key, value) in fields {
      objectToSerialize[key] = try serialize(value: value)
    }
    return try JSONSerializationFormat.serialize(value: objectToSerialize)
  }

  static func deserialize(data: Data) throws -> JSONObject {
    let object = try JSONSerializationFormat.deserialize(data: data)
    guard let jsonObject = object as? JSONObject else {
      throw SQLiteNormalizedCacheError.invalidRecordShape(object: object)
    }
    var deserializedObject = JSONObject()
    for (key, value) in jsonObject {
      deserializedObject[key] = try deserialize(valueJSON: value)
    }
    return deserializedObject
  }

  private static func deserialize(valueJSON: Any) throws -> Any {
    switch valueJSON {
    case let dictionary as JSONObject:
      guard let reference = dictionary[serializedReferenceKey] as? String else {
        throw SQLiteNormalizedCacheError.invalidRecordValue(value: valueJSON)
      }
      return Reference(key: reference)
    case let array as NSArray:
      return try array.map { try deserialize(valueJSON: $0) }
    default:
      return valueJSON
    }
  }

  private static func serialize(value: Any) throws -> Any {
    switch value {
    case let reference as Reference:
      return [serializedReferenceKey: reference.key]
    case let array as NSArray:
      return try array.map { try serialize(value: $0) }
    case let string as NSString:
      return string as String
    case let number as NSNumber:
      return number.doubleValue
    default:
      return value
    }
  }
}
