import Foundation

/// Data about a response received by an HTTP request.
public class HTTPResponse<ParsedValue: Parseable> {
  public var httpResponse: HTTPURLResponse?
  public var rawData: Data?
  public var parsedResponse: ParsedValue?
  
  /// Designated initializer
  ///
  /// - Parameters:
  ///   - response: [optional] The `HTTPURLResponse` received from the server. Will be nil if not yet received or if the response received was not an `HTTPURLResponse`.
  ///   - rawData: [optional] The raw, unparsed data received from the server. Will be nil if not yet received or if data received from the server was nil.
  ///   - parsedResponse: [optional] The response parsed into the `ParsedValue` type. Will be nil if not yet received, not yet parsed, or if parsing failed.
  public init(response: HTTPURLResponse?,
              rawData: Data?,
              parsedResponse: ParsedValue?) {
    self.httpResponse = response
    self.rawData = rawData
    self.parsedResponse = parsedResponse
  }
}
