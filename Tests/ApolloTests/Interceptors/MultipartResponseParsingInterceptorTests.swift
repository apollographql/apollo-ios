import XCTest
import Nimble
@testable import Apollo
import ApolloAPI
import ApolloInternalTestHelpers

final class MultipartResponseParsingInterceptorTests: XCTestCase {

  let defaultTimeout = 0.5

  private class ErrorRequestChain: RequestChain {
    var isCancelled: Bool = false
    var error: Error? = nil

    init() {}

    func kickoff<Operation>(
      request: Apollo.HTTPRequest<Operation>,
      completion: @escaping (Result<Apollo.GraphQLResult<Operation.Data>, Error>) -> Void
    ) {}

    func proceedAsync<Operation>(
      request: Apollo.HTTPRequest<Operation>,
      response: Apollo.HTTPResponse<Operation>?,
      completion: @escaping (Result<Apollo.GraphQLResult<Operation.Data>, Error>) -> Void
    ) {}

    func cancel() {}

    func retry<Operation>(
      request: Apollo.HTTPRequest<Operation>,
      completion: @escaping (Result<Apollo.GraphQLResult<Operation.Data>, Error>) -> Void
    ) {}

    func handleErrorAsync<Operation>(
      _ error: Error,
      request: Apollo.HTTPRequest<Operation>,
      response: Apollo.HTTPResponse<Operation>?,
      completion: @escaping (Result<Apollo.GraphQLResult<Operation.Data>, Error>) -> Void
    ) {
      self.error = error
    }

    func returnValueAsync<Operation>(
      for request: Apollo.HTTPRequest<Operation>,
      value: Apollo.GraphQLResult<Operation.Data>,
      completion: @escaping (Result<Apollo.GraphQLResult<Operation.Data>, Error>) -> Void
    ) {}
  }

  // MARK: - Error tests

  func test__error__givenNoResponse_shouldReturnError() throws {
    let requestChain = ErrorRequestChain()

    MultipartResponseParsingInterceptor().interceptAsync(
      chain: requestChain,
      request: .mock(operation: MockSubscription.mock()),
      response: nil
    ) { result in }

    expect(requestChain.error as? MultipartResponseParsingInterceptor.MultipartResponseParsingError)
      .to(equal(.noResponseToParse))
  }

  func test__error__givenResponse_withMissingMultipartBoundaryHeader_shouldReturnError() throws {
    let requestChain = ErrorRequestChain()

    MultipartResponseParsingInterceptor().interceptAsync(
      chain: requestChain,
      request: .mock(operation: MockSubscription.mock()),
      response: .mock(headerFields: ["Content-Type": "multipart/mixed"])
    ) { result in }

    expect(requestChain.error as? MultipartResponseParsingInterceptor.MultipartResponseParsingError)
      .to(equal(.cannotParseResponseData))
  }

  func test__error__givenChunk_withIncorrectContentType_shouldReturnError() throws {
    let requestChain = ErrorRequestChain()

    MultipartResponseParsingInterceptor().interceptAsync(
      chain: requestChain,
      request: .mock(operation: MockSubscription.mock()),
      response: .mock(
        headerFields: ["Content-Type": "multipart/mixed;boundary=graphql"],
        data: """
          --graphql
          content-type: test/custom

          {
            "data" : {
              "key" : "value"
            }
          }
          --graphql
          """.crlfFormattedData()
      )
    ) { result in }

    expect(requestChain.error as? MultipartResponseParsingInterceptor.MultipartResponseParsingError)
      .to(equal(.unsupportedContentType(type: "test/custom")))
  }

  func test__error__givenChunk_withTransportError_shouldReturnError() throws {
    let requestChain = ErrorRequestChain()

    MultipartResponseParsingInterceptor().interceptAsync(
      chain: requestChain,
      request: .mock(operation: MockSubscription.mock()),
      response: .mock(
        headerFields: ["Content-Type": "multipart/mixed;boundary=graphql"],
        data: """
          --graphql
          content-type: application/json

          {
            "errors" : [
              {
                "message" : "forced test failure!"
              }
            ]
          }
          --graphql
          """.crlfFormattedData()
      )
    ) { result in }

    expect(requestChain.error as? MultipartResponseParsingInterceptor.MultipartResponseParsingError)
      .to(equal(.irrecoverableError(message: "forced test failure!")))
  }

  func test__error__givenChunk_withMissingPayload_shouldReturnError() throws {
    let requestChain = ErrorRequestChain()

    MultipartResponseParsingInterceptor().interceptAsync(
      chain: requestChain,
      request: .mock(operation: MockSubscription.mock()),
      response: .mock(
        headerFields: ["Content-Type": "multipart/mixed;boundary=graphql"],
        data: """
          --graphql
          content-type: application/json

          {
            "key": "value"
          }
          --graphql
          """.crlfFormattedData()
      )
    ) { result in }

    expect(requestChain.error as? MultipartResponseParsingInterceptor.MultipartResponseParsingError)
      .to(equal(.cannotParsePayloadData))
  }

  func test__error__givenUnrecognizableChunk_shouldReturnError() throws {
    let requestChain = ErrorRequestChain()

    MultipartResponseParsingInterceptor().interceptAsync(
      chain: requestChain,
      request: .mock(operation: MockSubscription.mock()),
      response: .mock(
        headerFields: ["Content-Type": "multipart/mixed;boundary=graphql"],
        data: """
          --graphql
          content-type: application/json

          something
          --graphql
          """.crlfFormattedData()
      )
    ) { result in }

    expect(requestChain.error as? MultipartResponseParsingInterceptor.MultipartResponseParsingError)
      .to(equal(.cannotParseChunkData))
  }

  // MARK: Parsing tests

  private class Time: MockSelectionSet {
    typealias Schema = MockSchemaMetadata

    override class var __selections: [Selection] {[
      .field("__typename", String.self),
      .field("ticker", Int.self)
    ]}

    var ticker: Int { __data["ticker"] }
  }

  private func buildNetworkTransport(
    responseData: Data
  ) -> RequestChainNetworkTransport {
    let client = MockURLSessionClient(
      response: .mock(headerFields: ["Content-Type": "multipart/mixed;boundary=graphql"]),
      data: responseData
    )

    let provider = MockInterceptorProvider([
      NetworkFetchInterceptor(client: client),
      MultipartResponseParsingInterceptor(),
      JSONResponseParsingInterceptor()
    ])

    return RequestChainNetworkTransport(
      interceptorProvider: provider,
      endpointURL: TestURL.mockServer.url
    )
  }

  func test__parsing__givenHeartbeat_shouldIgnore() throws {
    let network = buildNetworkTransport(responseData: """
      --graphql
      content-type: application/json

      {}
      --graphql
      """.crlfFormattedData()
    )

    let expectation = expectation(description: "Heartbeat ignored")
    expectation.isInverted = true

    _ = network.send(operation: MockSubscription<Time>()) { result in
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: defaultTimeout)
  }

  func test__parsing__givenPayloadNull_shouldIgnore() throws {
    let network = buildNetworkTransport(responseData: """
      --graphql
      content-type: application/json

      {
        "payload": null
      }
      --graphql
      """.crlfFormattedData()
    )

    let expectation = expectation(description: "Payload (null) ignored")
    expectation.isInverted = true

    _ = network.send(operation: MockSubscription<Time>()) { result in
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: defaultTimeout)
  }

  func test__parsing__givenSingleChunk_shouldReturnSuccess() throws {
    let network = buildNetworkTransport(responseData: """
      --graphql
      content-type: application/json

      {
        "payload": {
          "data": {
            "__typename": "Time",
            "ticker": 1
          }
        }
      }
      --graphql
      """.crlfFormattedData()
    )

    let expectedData = try Time(data: [
      "__typename": "Time",
      "ticker": 1
    ], variables: nil)

    let expectation = expectation(description: "Multipart data received")

    _ = network.send(operation: MockSubscription<Time>()) { result in
      defer {
        expectation.fulfill()
      }

      switch (result) {
      case let .success(data):
        expect(data.data).to(equal(expectedData))
      case let .failure(error):
        fail("Unexpected failure result - \(error)")
      }
    }

    wait(for: [expectation], timeout: defaultTimeout)
  }

  func test__parsing__givenMultipleChunks_shouldReturnMultipleSuccesses() throws {
    let network = buildNetworkTransport(responseData: """
      --graphql
      content-type: application/json

      {
        "payload": {
          "data": {
            "__typename": "Time",
            "ticker": 2
          }
        }
      }
      --graphql
      content-type: application/json

      {
        "payload": {
          "data": {
            "__typename": "Time",
            "ticker": 3
          }
        }
      }
      --graphql
      """.crlfFormattedData()
    )

    let expectation = expectation(description: "Multipart data received")
    expectation.expectedFulfillmentCount = 2

    _ = network.send(operation: MockSubscription<Time>()) { result in
      switch (result) {
      case let .success(data):
        guard let time = data.data else {
          fail("Unexpected missing data!")
          return
        }

        expect(time.__typename).to(equal("Time"))
        switch time.ticker {
        case 2...3: expectation.fulfill()
        default: fail("Unexpected data value!")
        }

      case let .failure(error):
        fail("Unexpected failure result - \(error)")
      }
    }

    wait(for: [expectation], timeout: defaultTimeout)
  }

  func test__parsing__givenChunkWithGraphQLError_shouldReturnSuccessWithGraphQLError() throws {
    let network = buildNetworkTransport(responseData: """
      --graphql
      content-type: application/json

      {
        "payload": {
          "data": {
            "__typename": "Time",
            "ticker": 4
          },
          "errors": [
            {
              "message": "test error"
            }
          ]
        }
      }
      --graphql
      """.crlfFormattedData()
    )

    let expectation = expectation(description: "Multipart data received")

    _ = network.send(operation: MockSubscription<Time>()) { result in
      switch (result) {
      case let .success(data):
        guard let time = data.data else {
          fail("Unexpected missing data!")
          return
        }

        expect(time.__typename).to(equal("Time"))
        expect(time.ticker).to(equal(4))
        expect(data.errors).to(equal([GraphQLError("test error")]))

        expectation.fulfill()

      case let .failure(error):
        fail("Unexpected failure result - \(error)")
      }
    }

    wait(for: [expectation], timeout: defaultTimeout)
  }
  
  func test__parsing__givenEndOfStream_shouldReturnSuccess() throws {
    let network = buildNetworkTransport(responseData: """
      --graphql
      content-type: application/json

      {
        "payload": {
          "data": {
            "__typename": "Time",
            "ticker": 5
          }
        }
      }
      --graphql--
      """.crlfFormattedData()
    )

    let expectedData = try Time(data: [
      "__typename": "Time",
      "ticker": 5
    ], variables: nil)

    let expectation = expectation(description: "Multipart data received")

    _ = network.send(operation: MockSubscription<Time>()) { result in
      defer {
        expectation.fulfill()
      }

      switch (result) {
      case let .success(data):
        expect(data.data).to(equal(expectedData))
      case let .failure(error):
        fail("Unexpected failure result - \(error)")
      }
    }

    wait(for: [expectation], timeout: defaultTimeout)
  }
}
