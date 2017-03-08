import XCTest
@testable import Apollo

class RecordSetTests: XCTestCase {
  func testMergingWhenFieldIsRemoved() {
    let original = Record(key: "hero", ["name": "Luke Skywalker"])
    var set = RecordSet(records: [original])
    let new = Record(key: "hero")
    let changed = set.merge(record: new)
    
    XCTAssertTrue(changed.contains("hero.name"))
    
    guard let merged = set["hero"] else {
      XCTFail("missing record")
      return
    }
    
    XCTAssertNil(merged.fields["name"])
  }
}
