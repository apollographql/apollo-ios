import XCTest
@testable import ApolloSQLite

final class CacheKeyConstructionTests: XCTestCase {
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

  func testDoubleNestedInput() {
    let input = "my.chemical.romance(name:imnotokay.rip(xWv(the.original).HIGH-QUALITY)).mp3"
    let expected = ["my", "chemical", "romance(name:imnotokay.rip(xWv(the.original).HIGH-QUALITY))", "mp3"]

    XCTAssertEqual(input.splitIntoCacheKeyComponents(), expected)
  }

  func testUnbalancedInput() {
    let input = "my.chemical.romance(name: )(.thebest.)()"
    let expected = ["my", "chemical", "romance(name: )(.thebest.)()"]

    XCTAssertEqual(input.splitIntoCacheKeyComponents(), expected)
  }

  func testUnbalancedInputContinued() {
    let input = "my.chemical.romance(name: )(.thebest.)().count"
    let expected = ["my", "chemical", "romance(name: )(.thebest.)()", "count"]

    XCTAssertEqual(input.splitIntoCacheKeyComponents(), expected)
  }

  func testNoSplits() {
    let input = "mychemicalromance"
    let expected = ["mychemicalromance"]

    XCTAssertEqual(input.splitIntoCacheKeyComponents(), expected)
  }
}
