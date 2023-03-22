import Apollo
import ApolloAPI

extension HTTPResponse {
  public static func mock(
    statusCode: Int = 200,
    headerFields: [String : String] = [:],
    data: Data = Data()
  ) -> HTTPResponse {
    let urlResponse = HTTPURLResponse(
      url: TestURL.mockServer.url,
      statusCode: statusCode,
      httpVersion: nil,
      headerFields: headerFields
    )!

    return HTTPResponse(
      response: urlResponse,
      rawData: data,
      parsedResponse: nil
    )
  }
}
