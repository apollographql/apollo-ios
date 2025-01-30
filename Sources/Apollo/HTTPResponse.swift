import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

#warning("""
TODO: Can we kill this? Data is not all data for response in multi-part, making this confusing.
Alternatively, add more properties to help understand which portion of a multi-part response is being returned.
""")
/// Data about a response received by an HTTP request.
public struct HTTPResponse<Operation: GraphQLOperation>: Sendable {

  /// The `HTTPURLResponse` received from the URL loading system
  public var httpResponse: HTTPURLResponse
  
  /// The raw data received from the URL loading system
  public var rawData: Data
  
  /// [optional] The data as parsed into a `GraphQLResult`, which can eventually be returned to the UI. Will be nil 
  /// if not yet parsed.
  public var parsedResponse: GraphQLResult<Operation.Data>?

  /// A set of cache records from the response
  public var cacheRecords: RecordSet?

  /// Designated initializer
  ///
  /// - Parameters:
  ///   - response: The `HTTPURLResponse` received from the server.
  ///   - rawData: The raw, unparsed data received from the server.
  ///   - parsedResponse: [optional] The response parsed into the `ParsedValue` type. Will be nil if not yet parsed, 
  ///   or if parsing failed.
  public init(
    response: HTTPURLResponse,
    rawData: Data,
    parsedResponse: GraphQLResult<Operation.Data>?
  ) {
    self.httpResponse = response
    self.rawData = rawData
    self.parsedResponse = parsedResponse
  }
}

// MARK: - Equatable Conformance

extension HTTPResponse: Equatable where Operation.Data: Equatable {
  public static func == (lhs: HTTPResponse<Operation>, rhs: HTTPResponse<Operation>) -> Bool {
    lhs.httpResponse == rhs.httpResponse &&
    lhs.rawData == rhs.rawData &&
    lhs.parsedResponse == rhs.parsedResponse &&    
    lhs.cacheRecords == rhs.cacheRecords
  }
}

// MARK: - Hashable Conformance

extension HTTPResponse: Hashable where Operation.Data: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(httpResponse)
    hasher.combine(rawData)
    hasher.combine(parsedResponse)
    hasher.combine(cacheRecords)
  }
}
