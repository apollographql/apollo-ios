import XCTest
import Nimble
@testable import Apollo

final class HTTPURLResponseExtensionTests: XCTestCase {

  func createResponse(statusCode: Int, headers: [String: String]? = nil) -> HTTPURLResponse {
    return HTTPURLResponse(
      url: URL(string: "https://apollographql.com")!,
      statusCode: statusCode,
      httpVersion: nil,
      headerFields: headers
    )!
  }

  // MARK: - Response code tests

  func test__isSuccessful__givenLessThanLowerBound_shouldReturnFalse() {
    // given
    let response = createResponse(statusCode: 199)

    // then
    expect(response.isSuccessful).to(beFalse())
  }

  func test__isSuccessful__givenEqualToLowerBound_shouldReturnTrue() {
    // given
    let response = createResponse(statusCode: 200)

    // then
    expect(response.isSuccessful).to(beTrue())
  }

  func test__isSuccessful__givenBetweenBounds_shouldReturnTrue() {
    // given
    let response = createResponse(statusCode: 202)

    // then
    expect(response.isSuccessful).to(beTrue())
  }

  func test__isSuccessful__givenEqualToUpperBound_shouldReturnTrue() {
    // given
    let response = createResponse(statusCode: 299)

    // then
    expect(response.isSuccessful).to(beTrue())
  }

  func test__isSuccessful__givenMoreThanUpperBound_shouldReturnFalse() {
    // given
    let response = createResponse(statusCode: 300)

    // then
    expect(response.isSuccessful).to(beFalse())
  }

  // MARK: - Multipart tests
  func test__isMultipart__givenMultipartMixedContentType_shouldReturnTrue() {
    // given
    let response = createResponse(
      statusCode: 0,
      headers: ["Content-Type": "multipart/mixed; boundary=apollo"]
    )

    // then
    expect(response.isMultipart).to(beTrue())
  }

  func test__isMultipart__givenOtherContentType_shouldReturnFalse() {
    // given
    let response = createResponse(statusCode: 0, headers: ["Content-Type": "anything-else"])

    // then
    expect(response.isMultipart).to(beFalse())
  }

  func test__isMultipart__givenMissingContentType_shouldReturnFalse() {
    // given
    let response = createResponse(statusCode: 0)

    // then
    expect(response.isMultipart).to(beFalse())
  }

  func test__multipartBoundary__givenMissingContentType_shouldReturnNil() {
    // given
    let response = createResponse(statusCode: 0)

    // then
    expect(response.multipartBoundary).to(beNil())
  }

  func test__multipartBoundary__givenMissingBoundaryMarker_shouldReturnNil() {
    // given
    let response = createResponse(statusCode: 0, headers: ["Content-Type": "multipart/mixed"])

    // then
    expect(response.multipartBoundary).to(beNil())
  }

  func test__multipartBoundary__givenBoundaryMarker_shouldReturnBoundaryMarker() {
    // given
    let response = createResponse(
      statusCode: 0,
      headers: ["Content-Type": "multipart/mixed; boundary=apollo"]
    )

    // then
    expect(response.multipartBoundary).to(equal("apollo"))
  }

  func test__multipartBoundary__givenBoundaryMarkerWithPrefixWhitespace_shouldReturnBoundaryMarkerPreservingPrefixWhitespace() {
    // given
    let response = createResponse(
      statusCode: 0,
      headers: ["Content-Type": "multipart/mixed; boundary= apollo"]
    )

    // then
    expect(response.multipartBoundary).to(equal(" apollo"))
  }

  func test__multipartBoundary__givenBoundaryMarkerWithQuotations_shouldReturnBoundaryMarkerWithoutQuotations() {
    // given
    let response = createResponse(
      statusCode: 0,
      headers: ["Content-Type": "multipart/mixed; boundary=\"apollo\""]
    )

    // then
    expect(response.multipartBoundary).to(equal("apollo"))
  }

}
