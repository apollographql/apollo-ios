import Foundation
#if !COCOAPODS
import Apollo
#endif

public enum SQLiteNormalizedCacheError: Error {
  case invalidRecordEncoding(record: String)
  case invalidRecordShape(object: Any)
}

/// A `NormalizedCache` implementation which uses a SQLite database to store data.
public final class SQLiteNormalizedCache {

  private let shouldVacuumOnClear: Bool
  
  let database: SQLiteDatabase

  /// Designated initializer
  ///
  /// - Parameters:
  ///   - fileURL: The file URL to use for your database.
  ///   - shouldVacuumOnClear: If the database should also be `VACCUM`ed on clear to remove all traces of info. Defaults to `false` since this involves a performance hit, but this should be used if you are storing any Personally Identifiable Information in the cache.
  /// - Throws: Any errors attempting to open or create the database.
  public init(fileURL: URL,
              databaseType: SQLiteDatabase.Type = SQLiteDotSwiftDatabase.self,
              shouldVacuumOnClear: Bool = false) throws {
    self.database = try databaseType.init(fileURL: fileURL)
    self.shouldVacuumOnClear = shouldVacuumOnClear
    try self.database.createRecordsTableIfNeeded()
  }

  public init(database: SQLiteDatabase,
              shouldVacuumOnClear: Bool = false) throws {
    self.database = database
    self.shouldVacuumOnClear = shouldVacuumOnClear
    try self.database.createRecordsTableIfNeeded()
  }
  
  private func recordCacheKey(forFieldCacheKey fieldCacheKey: CacheKey) -> CacheKey {
    let components = fieldCacheKey.splitIntoCacheKeyComponents()
    var updatedComponents = [String]()
    if components.first?.contains("_ROOT") == true {
      for component in components {
        if updatedComponents.last?.last?.isNumber ?? false && component.first?.isNumber ?? false {
          updatedComponents[updatedComponents.count - 1].append(".\(component)")
        } else {
          updatedComponents.append(component)
        }
      }
    } else {
      updatedComponents = components
    }

    if updatedComponents.count > 1 {
      updatedComponents.removeLast()
    }
    return updatedComponents.joined(separator: ".")
  }

  private func mergeRecords(records: RecordSet) throws -> Set<CacheKey> {
    var recordSet = RecordSet(records: try self.selectRecords(for: records.keys))
    let changedFieldKeys = recordSet.merge(records: records)
    let changedRecordKeys = changedFieldKeys.map { self.recordCacheKey(forFieldCacheKey: $0) }
    for recordKey in Set(changedRecordKeys) {
      if let recordFields = recordSet[recordKey]?.fields {
        let recordData = try SQLiteSerialization.serialize(fields: recordFields)
        guard let recordString = String(data: recordData, encoding: .utf8) else {
          assertionFailure("Serialization should yield UTF-8 data")
          continue
        }
        
        try self.database.addOrUpdateRecordString(recordString, for: recordKey)
      }
    }
    return Set(changedFieldKeys)
  }
  
  fileprivate func selectRecords(for keys: Set<CacheKey>) throws -> [Record] {
    try self.database.selectRawRows(forKeys: keys)
      .map { try self.parse(row: $0) }
  }

  private func parse(row: DatabaseRow) throws -> Record {
    guard let recordData = row.storedInfo.data(using: .utf8) else {
      throw SQLiteNormalizedCacheError.invalidRecordEncoding(record: row.storedInfo)
    }

    let fields = try SQLiteSerialization.deserialize(data: recordData)
    return Record(key: row.cacheKey, fields)
  }
}

// MARK: - NormalizedCache conformance

extension SQLiteNormalizedCache: NormalizedCache {
  public func loadRecords(forKeys keys: Set<CacheKey>) throws -> [CacheKey: Record] {
    return [CacheKey: Record](uniqueKeysWithValues:
                                try selectRecords(for: keys)
                                .map { record in
                                  (record.key, record)
                                })
  }
  
  public func merge(records: RecordSet) throws -> Set<CacheKey> {
    return try mergeRecords(records: records)
  }
  
  public func removeRecord(for key: CacheKey) throws {
    try self.database.deleteRecord(for: key)
  }

  public func removeRecords(matching pattern: CacheKey) throws {
    try self.database.deleteRecords(matching: pattern)
  }
  
  public func clear() throws {
    try self.database.clearDatabase(shouldVacuumOnClear: self.shouldVacuumOnClear)
  }
}

extension String {
  private var isBalanced: Bool {
    guard contains("(") || contains(")") else { return true }

    var stack = [Character]()
    for character in self where ["(", ")"].contains(character) {
      if character == "(" {
        stack.append(character)
      } else if !stack.isEmpty && character == ")" {
        _ = stack.popLast()
      }
    }

    return stack.isEmpty
  }

  func splitIntoCacheKeyComponents() -> [String] {
    var result = [String]()
    var unbalancedString = ""
    let tmp = split(separator: ".", omittingEmptySubsequences: false)
    tmp
      .enumerated()
      .forEach { index, item in
        let value = String(item)
        if value.isBalanced && unbalancedString == "" {
          result.append(value)
        } else {
          unbalancedString += unbalancedString == "" ? value : ".\(value)"
          if unbalancedString.isBalanced {
            result.append(unbalancedString)
            unbalancedString = ""
          }
        }
        if unbalancedString != "" && index == tmp.count - 1 {
          result.append(unbalancedString)
        }
      }
    return result
  }
}
