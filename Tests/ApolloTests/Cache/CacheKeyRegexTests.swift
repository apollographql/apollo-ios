import XCTest
@testable import ApolloSQLite

final class CacheKeyRegexTests: XCTestCase {
  func testCacheKeySplitsPeriods() {
    let input = "my.chemical.romance"
    let expected = ["my", "chemical", "romance"]

    XCTAssertEqual(input.splitIntoCacheKeyComponents(), expected)
  }

  func testCacheKeySplitsPeriodsButIgnoresParentheses() {
    let input = "my.chemical.romance(xWv.CD-RIP.whole-album)"
    let expected = ["my", "chemical", "romance(xWv.CD-RIP.whole-album)"]

    XCTAssertEqual(input.splitIntoCacheKeyComponents(), expected)
  }

  func testCacheKeyIgnoresNestedParentheses() {
    let input = "my.chemical.romance(the.(very)hidden.albums)"
    let expected = ["my", "chemical", "romance(the.(very)hidden.albums)"]

    XCTAssertEqual(input.splitIntoCacheKeyComponents(), expected)
  }

  func testGarbageInput() {
    let input = "my.chemical.romance(name:((((..((.(.(((((.()"
    let expected = ["my", "chemical", "romance(name:((((..((.(.(((((.()"]

    XCTAssertEqual(input.splitIntoCacheKeyComponents(), expected)
  }
}
