@testable import Apollo
import ApolloAPI
import ApolloInternalTestHelpers
import XCTest
import Nimble

final class ApolloClientOperationTests: XCTestCase {

  var store: MockStore!
  var server: MockGraphQLServer!
  var client: ApolloClient!

  override func setUpWithError() throws {
    try super.setUpWithError()

    self.store = MockStore()
    self.server = MockGraphQLServer()
    self.client = ApolloClient(
      networkTransport: MockNetworkTransport(server: self.server, store: self.store),
      store: self.store
    )
  }

  override func tearDownWithError() throws {    
    self.store = nil
    self.server = nil
    self.client = nil

    try super.tearDownWithError()
  }

  class MockStore: ApolloStore {
    var publishedRecordSets: [RecordSet] = []

    init() {
      super.init(cache: NoCache())
    }

    override func publish(records: RecordSet, identifier: UUID? = nil, callbackQueue: DispatchQueue = .main, completion: ((Result<Void, Swift.Error>) -> Void)? = nil) {
      publishedRecordSets.append(records)
    }
  }

  // given
  class GivenSelectionSet: MockSelectionSet {
    override class var __selections: [Selection] { [
      .field("createReview", CreateReview.self)
    ] }

    class CreateReview: MockSelectionSet {
      override class var __selections: [Selection] { [
        .field("__typename", String.self),
        .field("stars", Int.self),
        .field("commentary", String?.self)
      ] }
    }
  }

  let jsonObject: JSONObject = [
    "data": [
      "createReview": [
        "__typename": "Review",
        "stars": 3,
        "commentary": ""
      ]
    ]
  ]

  func test__performMutation_givenPublishResultToStore_true_publishResultsToStore() throws {
    let mutation = MockMutation<GivenSelectionSet>()
    let resultObserver = self.makeResultObserver(for: mutation)

    let serverRequestExpectation = server.expect(MockMutation<GivenSelectionSet>.self) { _ in
      self.jsonObject
    }

    let performResultFromServerExpectation =
      resultObserver.expectation(description: "Mutation was successful") { result in
        switch (result) {
        case .success:
          break
        case let .failure(error):
          fail("Unexpected failure! \(error)")
        }
      }

    // when
    self.client.perform(mutation: mutation,
                        publishResultToStore: true,
                        resultHandler: resultObserver.handler)

    self.wait(for: [serverRequestExpectation, performResultFromServerExpectation], timeout: 0.2)

    // then
    expect(self.store.publishedRecordSets.count).to(equal(1))
    
    let actual = self.store.publishedRecordSets[0]
    expect(actual["MUTATION_ROOT"]).to(equal(
      Record(key: "MUTATION_ROOT", [
        "createReview": CacheReference("MUTATION_ROOT.createReview")
      ])
    ))
    expect(actual["MUTATION_ROOT.createReview"]).to(equal(
      Record(key: "MUTATION_ROOT.createReview", [
        "__typename": "Review",
        "stars": 3,
        "commentary": ""
      ])
    ))
  }

  func test__performMutation_givenPublishResultToStore_false_doesNotPublishResultsToStore() throws {
    let mutation = MockMutation<GivenSelectionSet>()
    let resultObserver = self.makeResultObserver(for: mutation)

    let serverRequestExpectation = server.expect(MockMutation<GivenSelectionSet>.self) { _ in
      self.jsonObject
    }

    let performResultFromServerExpectation =
      resultObserver.expectation(description: "Mutation was successful") { result in
        switch (result) {
        case .success:
          break
        case let .failure(error):
          fail("Unexpected failure! \(error)")
        }
      }

    // when
    self.client.perform(mutation: mutation,
                        publishResultToStore: false,
                        resultHandler: resultObserver.handler)

    self.wait(for: [serverRequestExpectation, performResultFromServerExpectation], timeout: 0.2)

    // then
    expect(self.store.publishedRecordSets).to(beEmpty())
  }
}
