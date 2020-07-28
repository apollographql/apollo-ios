import Foundation

public class HTTPResponse<ParsedValue: Parseable> {
  public var httpResponse: HTTPURLResponse?
  public var rawData: Data?
  public var parsedResponse: ParsedValue?
  
  public init(response: HTTPURLResponse?,
              rawData: Data?,
              parsedResponse: ParsedValue?) {
    self.httpResponse = response
    self.rawData = rawData
    self.parsedResponse = parsedResponse
  }
}
