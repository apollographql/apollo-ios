import XCTest

@testable import Apollo
import ApolloInternalTestHelpers

class GraphQLFileTests: XCTestCase {
  
  func testCreatingFileWithKnownBadURLFails() {
    let url = URL(fileURLWithPath: "/known/bad/path")
    XCTAssertThrowsError(try GraphQLFile(fieldName: "test",
                                         originalName: "test",
                                         fileURL: url)) { error in
      switch error {
      case GraphQLFile.GraphQLFileError.couldNotGetFileSize(let fileURL):
        XCTAssertEqual(fileURL, url)
      default:
        XCTFail("Unexpected error creating file: \(error)")
      }
    }
  }
  
  func testCreatingFileWithKnownGoodURLSucceedsAndCreatesAndCanRecreateInputStream() throws {
    let knownFileURL = TestFileHelper.fileURLForFile(named: "a", extension: "txt")
    
    let file = try GraphQLFile(fieldName: "test",
                               originalName: "test",
                               fileURL: knownFileURL)
    
    let inputStream = try file.generateInputStream()

    inputStream.open()
    XCTAssertTrue(inputStream.hasBytesAvailable)
    inputStream.close()
   
    let inputStream2 = try file.generateInputStream()
    
    inputStream2.open()
    XCTAssertTrue(inputStream2.hasBytesAvailable)
    inputStream2.close()
  }
  
  func testCreatingFileWithEmptyDataSucceedsAndCreatesInputStream() throws {
    let data = Data()
    XCTAssertTrue(data.isEmpty)
    
    let file = GraphQLFile(fieldName: "test",
                           originalName: "test",
                           data: data)
    
    let inputStream = try file.generateInputStream()
    
    // Shouldn't have any bytes available if data is empty
    inputStream.open()
    XCTAssertFalse(inputStream.hasBytesAvailable)
    inputStream.close()
  }
  
  func testCreatingFileWithNonEmptyDataSucceedsAndCreatesAndCanRecreateInputStream() throws {
    let data = try XCTUnwrap("A test string".data(using: .utf8))
    XCTAssertFalse(data.isEmpty)
    
    let file = GraphQLFile(fieldName: "test",
                           originalName: "test",
                           data: data)
    
    let inputStream = try file.generateInputStream()
    inputStream.open()
    XCTAssertTrue(inputStream.hasBytesAvailable)
    inputStream.close()
    
    let inputStream2 = try file.generateInputStream()
    
    inputStream2.open()
    XCTAssertTrue(inputStream2.hasBytesAvailable)
    inputStream2.close()
  }
}
