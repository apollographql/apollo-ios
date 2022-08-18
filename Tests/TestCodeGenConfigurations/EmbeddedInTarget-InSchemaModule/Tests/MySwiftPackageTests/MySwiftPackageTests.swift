import XCTest
import Apollo
import ApolloTestSupport
@testable import MySwiftPackage

final class MySwiftPackageTests: XCTestCase {
    func testCacheKeyResolution() throws {
      let client = ApolloClient(url: URL(string: "www.test.com")!)

      let response = GraphQLResponse(
        operation: MyGraphQLSchema.DogQuery(),
        body: ["data": [
          "allAnimals": [
            [
              "__typename": "Dog",
              "id": "1",
              "species": "Canine",
            ]
          ]
        ]])

      let (_, records) = try response.parseResult()

      let expectation = expectation(description: "Publish Record then Fetch")

      client.store.publish(records: records!) { _ in
        client.fetch(query: MyGraphQLSchema.DogQuery(),
                     cachePolicy: .returnCacheDataDontFetch) { data in
          let dog = try! data.get().data?.allAnimals[0]

          XCTAssertEqual(dog?.id, "1")
          expectation.fulfill()
        }
      }

      waitForExpectations(timeout: 1.0)
    }
}

class MockNetworkTransport: NetworkTransport {
  func send<Operation>(
    operation: Operation,
    cachePolicy: CachePolicy,
    contextIdentifier: UUID?,
    callbackQueue: DispatchQueue,
    completionHandler: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
  ) -> Cancellable where Operation : GraphQLOperation {
    return EmptyCancellable()
  }
  var clientName: String { "Mock" }
  var clientVersion: String { "Mock" }
}
