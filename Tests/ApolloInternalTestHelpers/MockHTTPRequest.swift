import Apollo
import ApolloAPI

extension HTTPRequest {
  public static func mock(operation: Operation) -> HTTPRequest {
    return HTTPRequest(
      graphQLEndpoint: TestURL.mockServer.url,
      operation: operation,
      contentType: "application/json",
      clientName: "test-client",
      clientVersion: "test-version",
      additionalHeaders: [:]
    )
  }
}
