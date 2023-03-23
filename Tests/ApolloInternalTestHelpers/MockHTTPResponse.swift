import Apollo
import ApolloAPI

extension HTTPResponse {
  public static func mock(
    statusCode: Int = 200,
    headerFields: [String : String] = [:],
    data: Data = Data()
  ) -> HTTPResponse {
    return HTTPResponse(
      response: .mock(
        statusCode: statusCode,
        headerFields: headerFields
      ),
      rawData: data,
      parsedResponse: nil
    )
  }
}

extension HTTPURLResponse {
  public static func mock(
    url: URL = TestURL.mockServer.url,
    statusCode: Int = 200,
    httpVersion: String? = nil,
    headerFields: [String : String]? = nil
  ) -> HTTPURLResponse {
    return HTTPURLResponse(
      url: url,
      statusCode: statusCode,
      httpVersion: httpVersion,
      headerFields: headerFields
    )!
  }
}
