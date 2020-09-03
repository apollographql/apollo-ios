import Foundation

/// Data about a response received by an HTTP request.
public class HTTPResponse<Operation: GraphQLOperation> {
  
  /// The `HTTPURLResponse` received from the URL loading system
  public var httpResponse: HTTPURLResponse
  
  /// The raw data received from the URL loading system
  public var rawData: Data
  
  /// [optional] The data as parsed into a `GraphQLResult`, which can eventually be returned to the UI. Will be nil if not yet parsed.
  public var parsedResponse: GraphQLResult<Operation.Data>?
  
  /// [optional] The data as parsed into a `GraphQLResponse` for legacy caching purposes. If you're not using the `LegacyParsingInterceptor`, you probably shouldn't be using this property.
  /// **NOTE:** This property will be removed when the transition to a Codable-based Codegen is complete.
  public var legacyResponse: GraphQLResponse<Operation.Data>? = nil
  
  /// Designated initializer
  ///
  /// - Parameters:
  ///   - response: The `HTTPURLResponse` received from the server.
  ///   - rawData: The raw, unparsed data received from the server.
  ///   - parsedResponse: [optional] The response parsed into the `ParsedValue` type. Will be nil if not yet parsed, or if parsing failed.
  public init(response: HTTPURLResponse,
              rawData: Data,
              parsedResponse: GraphQLResult<Operation.Data>?) {
    self.httpResponse = response
    self.rawData = rawData
    self.parsedResponse = parsedResponse
  }
}
