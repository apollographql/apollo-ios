import XCTest
@testable import ApolloSQLite
import ApolloInternalTestHelpers
import SQLite

class SQLiteDotSwiftDatabaseBehaviorTests: XCTestCase {

  func testSelection_withForcedError_shouldThrow() throws {
    let sqliteFileURL = SQLiteTestCacheProvider.temporarySQLiteFileURL()
    let db = try! SQLiteDotSwiftDatabase(fileURL: sqliteFileURL)

    try! db.createRecordsTableIfNeeded()
    try! db.addOrUpdateRecordString("record", for: "key")

    var rows = [DatabaseRow]()
    XCTAssertNoThrow(rows = try db.selectRawRows(forKeys: ["key"]))
    XCTAssertEqual(rows.count, 1)

    // Use SQLite directly to manipulate the database (cannot be done with SQLiteDotSwiftDatabase)
    let connection = try Connection(.uri(sqliteFileURL.absoluteString), readonly: false)
    let table = Table(SQLiteDotSwiftDatabase.tableName)
    try! connection.run(table.drop(ifExists: false))

    XCTAssertThrowsError(try db.selectRawRows(forKeys: ["key"]))
  }
}
