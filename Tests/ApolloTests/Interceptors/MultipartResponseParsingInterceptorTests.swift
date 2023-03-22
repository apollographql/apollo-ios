import XCTest
import Nimble
@testable import Apollo
import ApolloAPI
import ApolloInternalTestHelpers

final class MultipartResponseParsingInterceptorTests: XCTestCase {

  private class ErrorRequestChain: RequestChain {
    var isCancelled: Bool = false
    var error: Error? = nil

    init() {}

    func kickoff<Operation>(
      request: Apollo.HTTPRequest<Operation>,
      completion: @escaping (Result<Apollo.GraphQLResult<Operation.Data>, Error>
    ) -> Void) {}

    func proceedAsync<Operation>(
      request: Apollo.HTTPRequest<Operation>,
      response: Apollo.HTTPResponse<Operation>?,
      completion: @escaping (Result<Apollo.GraphQLResult<Operation.Data>, Error>
    ) -> Void) {}

    func cancel() {}

    func retry<Operation>(
      request: Apollo.HTTPRequest<Operation>,
      completion: @escaping (Result<Apollo.GraphQLResult<Operation.Data>, Error>
    ) -> Void) {}

    func handleErrorAsync<Operation>(
      _ error: Error,
      request: Apollo.HTTPRequest<Operation>,
      response: Apollo.HTTPResponse<Operation>?,
      completion: @escaping (Result<Apollo.GraphQLResult<Operation.Data>, Error>
    ) -> Void) {
      self.error = error
    }

    func returnValueAsync<Operation>(
      for request: Apollo.HTTPRequest<Operation>,
      value: Apollo.GraphQLResult<Operation.Data>,
      completion: @escaping (Result<Apollo.GraphQLResult<Operation.Data>, Error>
    ) -> Void) {}
  }

  private class TestProvider: InterceptorProvider {
    let mockClient: MockURLSessionClient = {
      let client = MockURLSessionClient()

      client.response = HTTPURLResponse(
        url: TestURL.mockServer.url,
        statusCode: 200,
        httpVersion: nil,
        headerFields: nil
      )
      client.data = Data()

      return client
    }()
    
    func interceptors<Operation>(for operation: Operation) -> [ApolloInterceptor] {
      [
        NetworkFetchInterceptor(client: mockClient),
        MultipartResponseParsingInterceptor()
      ]
    }
  }

  // MARK: - Error tests

  func test__error__givenNoResponse_shouldReturnError() throws {
    let requestChain = ErrorRequestChain()

    MultipartResponseParsingInterceptor().interceptAsync(
      chain: requestChain,
      request: HTTPRequest.mock(operation: MockSubscription.mock()),
      response: nil
    ) { result in }

    expect(requestChain.error as? MultipartResponseParsingInterceptor.MultipartResponseParsingError)
      .to(equal(.noResponseToParse))
  }

  func test__error__givenResponse_withMissingMultipartBoundaryHeader_shouldReturnError() throws {
    let requestChain = ErrorRequestChain()

    MultipartResponseParsingInterceptor().interceptAsync(
      chain: requestChain,
      request: HTTPRequest.mock(operation: MockSubscription.mock()),
      response: HTTPResponse.mock(headerFields: ["Content-Type": "multipart/mixed"])
    ) { result in }

    expect(requestChain.error as? MultipartResponseParsingInterceptor.MultipartResponseParsingError)
      .to(equal(.cannotParseResponseData))
  }

  func test__error__givenChunk_withIncorrectContentType_shouldReturnError() throws {
    let requestChain = ErrorRequestChain()

    MultipartResponseParsingInterceptor().interceptAsync(
      chain: requestChain,
      request: HTTPRequest.mock(operation: MockSubscription.mock()),
      response: HTTPResponse.mock(
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
      request: HTTPRequest.mock(operation: MockSubscription.mock()),
      response: HTTPResponse.mock(
        headerFields: ["Content-Type": "multipart/mixed;boundary=graphql"],
        data: """
          --graphql
          content-type: application/json

          {
            "errors" : [
              {
                "message" : "forced test failure!"
              }
            ],
            "done": true
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
      request: HTTPRequest.mock(operation: MockSubscription.mock()),
      response: HTTPResponse.mock(
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
      request: HTTPRequest.mock(operation: MockSubscription.mock()),
      response: HTTPResponse.mock(
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

  // heartbeat no error test
}

fileprivate extension String {
  func crlfFormattedData() -> Data {
    return replacingOccurrences(of: "\n\n", with: "\r\n\r\n").data(using: .utf8)!
  }
}
