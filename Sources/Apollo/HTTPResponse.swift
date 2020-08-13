import Foundation

/// Data about a response received by an HTTP request.
public class HTTPResponse<Operation: GraphQLOperation> {
  public var httpResponse: HTTPURLResponse
  public var rawData: Data?
  public var parsedResponse: GraphQLResult<Operation.Data>?
  
  /// Designated initializer
  ///
  /// - Parameters:
  ///   - response: The `HTTPURLResponse` received from the server.
  ///   - rawData: [optional] The raw, unparsed data received from the server. Will be nil if data received from the server was nil.
  ///   - parsedResponse: [optional] The response parsed into the `ParsedValue` type. Will be nil if not yet parsed, or if parsing failed.
  public init(response: HTTPURLResponse,
              rawData: Data?,
              parsedResponse: GraphQLResult<Operation.Data>?) {
    self.httpResponse = response
    self.rawData = rawData
    self.parsedResponse = parsedResponse
  }
}
