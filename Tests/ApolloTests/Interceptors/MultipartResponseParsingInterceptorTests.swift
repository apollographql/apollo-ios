import XCTest
import Nimble
@testable import Apollo
import ApolloAPI
import ApolloInternalTestHelpers

final class MultipartResponseParsingInterceptorTests: XCTestCase {

  let defaultTimeout = 0.5

  // MARK: - Error tests

  func test__error__givenNoResponse_shouldReturnError() throws {
    let subject = InterceptorTester(interceptor: MultipartResponseParsingInterceptor())

    let expectation = expectation(description: "Received callback")

    subject.intercept(request: .mock(operation: MockSubscription.mock())) { result in
      defer {
        expectation.fulfill()
      }

      expect(result).to(beFailure { error in
        expect(error).to(
          matchError(MultipartResponseParsingInterceptor.ParsingError.noResponseToParse)
        )
      })
    }

    wait(for: [expectation], timeout: defaultTimeout)
  }

  func test__error__givenResponse_withMissingMultipartBoundaryHeader_shouldReturnError() throws {
    let subject = InterceptorTester(interceptor: MultipartResponseParsingInterceptor())

    let expectation = expectation(description: "Received callback")

    subject.intercept(
      request: .mock(operation: MockSubscription.mock()),
      response: .mock(headerFields: ["Content-Type": "multipart/mixed"])
    ) { result in
      defer {
        expectation.fulfill()
      }

      expect(result).to(beFailure { error in
        expect(error).to(
          matchError(MultipartResponseParsingInterceptor.ParsingError.cannotParseResponse)
        )
      })
    }

    wait(for: [expectation], timeout: defaultTimeout)
  }

  func test__error__givenResponse_withMissingMultipartProtocolHeader_shouldReturnError() throws {
    let subject = InterceptorTester(interceptor: MultipartResponseParsingInterceptor())

    let expectation = expectation(description: "Received callback")

    subject.intercept(
      request: .mock(operation: MockSubscription.mock()),
      response: .mock(headerFields: ["Content-Type": "multipart/mixed;boundary=\"graphql\""])
    ) { result in
      defer {
        expectation.fulfill()
      }

      expect(result).to(beFailure { error in
        expect(error).to(
          matchError(MultipartResponseParsingInterceptor.ParsingError.cannotParseResponse)
        )
      })
    }

    wait(for: [expectation], timeout: defaultTimeout)
  }

  func test__error__givenResponse_withUnknownMultipartParser_shouldReturnError() throws {
    let subject = InterceptorTester(interceptor: MultipartResponseParsingInterceptor())

    let expectation = expectation(description: "Received callback")

    subject.intercept(
      request: .mock(operation: MockSubscription.mock()),
      response: .mock(headerFields: ["Content-Type": "multipart/mixed;boundary=\"graphql\";unknownSpec=0"])
    ) { result in
      defer {
        expectation.fulfill()
      }

      expect(result).to(beFailure { error in
        expect(error).to(
          matchError(MultipartResponseParsingInterceptor.ParsingError.cannotParseResponse)
        )
      })
    }

    wait(for: [expectation], timeout: defaultTimeout)
  }
}
