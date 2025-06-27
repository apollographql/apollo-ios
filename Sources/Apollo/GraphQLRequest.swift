import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

public protocol GraphQLRequest<Operation>: Sendable {
  associatedtype Operation: GraphQLOperation

  /// The endpoint to make a GraphQL request to
  var graphQLEndpoint: URL { get set }

  /// The GraphQL Operation to execute
  var operation: Operation { get set }

  /// Any additional headers you wish to add to this request.
  var additionalHeaders: [String: String] { get set }

  /// The timeout interval specifies the limit on the idle interval allotted to a request in the process of
  /// loading. This timeout interval is measured in seconds.
  ///
  /// The value of this property will be set as the `timeoutInterval` on the `URLRequest` created for this GraphQL request.
  var requestTimeout: TimeInterval? { get set }

  /// Converts the receiver into a `URLRequest` to be used for networking operations.
  ///
  /// - Note: This function should call `createDefaultRequest()` to obtain a request with the
  /// default configuration. The implementation may then modify that request. See the documentation
  /// for ``GraphQLRequest/createDefaultRequest()`` for more information.
  func toURLRequest() throws -> URLRequest
}

// MARK: - Helper Functions

extension GraphQLRequest {

  /// Creates a default `URLRequest` for the receiver.
  ///
  /// This function creates a `URLRequest` with the following behaviors:
  /// - `url` set to the receiver's `graphQLEndpoint`
  /// - `httpMethod` set to POST
  /// - Client awareness headers from `ApolloClient.clientAwarenessMetadata` added to `allHTTPHeaderFields`
  /// - All header's from `additionalHeaders` added to `allHTTPHeaderFields`
  /// - Sets the `timeoutInterval` to `requestTimeout` if not nil.
  ///
  /// - Note: This should be called within the implementation of `toURLRequest()` and the returned request
  /// can then be modified as necessary before being returned.
  ///
  /// - Returns: A `URLRequest` configured as described above.
  public func createDefaultRequest() -> URLRequest {
    var request = URLRequest(url: self.graphQLEndpoint)

    request.httpMethod = GraphQLHTTPMethod.POST.rawValue

    if let clientAwarenessMetadata = ApolloClient.context?.clientAwarenessMetadata {
      clientAwarenessMetadata.applyHeaders(to: &request)
    }

    for (fieldName, value) in self.additionalHeaders {
      request.addValue(value, forHTTPHeaderField: fieldName)
    }

    if let requestTimeout {
      request.timeoutInterval = requestTimeout
    }

    return request
  }

  public mutating func addHeader(name: String, value: String) {
    self.additionalHeaders[name] = value
  }

  public mutating func addHeaders(_ headers: [String: String]) {
    self.additionalHeaders.merge(headers) { (_, new) in new }
  }

}
