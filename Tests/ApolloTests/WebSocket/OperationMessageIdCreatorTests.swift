import XCTest
@testable import ApolloWebSocket
import UploadAPI

class OperationMessageIdCreatorTests: XCTestCase {
  struct CustomOperationMessageIdCreator: OperationMessageIdCreator {
    func requestId() -> String {
      return "12345678"
    }
  }

  // MARK: - Tests
  
  func testOperationMessageIdCreatorWithApolloOperationMessageIdCreator() {
    let apolloOperationMessageIdCreator = ApolloSequencedOperationMessageIdCreator(startAt: 5)

    let firstId = apolloOperationMessageIdCreator.requestId()
    let secondId = apolloOperationMessageIdCreator.requestId()

    XCTAssertEqual(firstId, "5")
    XCTAssertEqual(secondId, "6")
  }

  func testOperationMessageIdCreatorWithCustomOperationMessageIdCreator() {
    let customOperationMessageIdCreator = CustomOperationMessageIdCreator()

    let id = customOperationMessageIdCreator.requestId()

    XCTAssertEqual(id, "12345678")
  }
}
