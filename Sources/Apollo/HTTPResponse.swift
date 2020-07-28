import Foundation

public class HTTPResponse<ParsedValue: Parseable> {
  public var httpResponse: HTTPURLResponse?
  public var rawData: Data?
  public var parsedResponse: ParsedValue?
  public var sourceType: FetchSourceType
  
  public init(response: HTTPURLResponse?,
              rawData: Data?,
              parsedResponse: ParsedValue?,
              sourceType: FetchSourceType) {
    self.httpResponse = response
    self.rawData = rawData
    self.parsedResponse = parsedResponse
    self.sourceType = sourceType
  }
}
