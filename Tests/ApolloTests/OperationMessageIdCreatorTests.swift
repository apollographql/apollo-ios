import XCTest
@testable import Apollo
import UploadAPI

class OperationMessageIdCreatorTests: XCTestCase {
  private let customOperationMessageIdCreator = TestCustomOperationMessageIdCreator()
  private let apolloOperationMessageIdCreator = ApolloOperationMessageIdCreator()
  
  // MARK: - Tests
  
  func testOperationMessageIdCreatorWithApolloOperationMessageIdCreator() {
    let firstId = apolloOperationMessageIdCreator.requestId()
    let secondId = apolloOperationMessageIdCreator.requestId()

    XCTAssertEqual(firstId, "1")
    XCTAssertEqual(secondId, "2")
  }

  func testOperationMessageIdCreatorWithCustomOperationMessageIdCreator() {
    let id = customOperationMessageIdCreator.requestId()

    XCTAssertEqual(id, "12345678")
  }
}
