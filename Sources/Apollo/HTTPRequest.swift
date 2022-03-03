import Foundation

/// Encapsulation of all information about a request before it hits the network
open class HTTPRequest<Operation: GraphQLOperation> {
  
  /// The endpoint to make a GraphQL request to
  open var graphQLEndpoint: URL
  
  /// The GraphQL Operation to execute
  open var operation: Operation
  
  /// Any additional headers you wish to add by default to this request
  open var additionalHeaders: [String: String]
  
  /// The `CachePolicy` to use for this request.
  open var cachePolicy: CachePolicy
  
  /// [optional] A unique identifier for this request, to help with deduping cache hits for watchers.
  public let contextIdentifier: UUID?
  
  /// Designated Initializer
  ///
  /// - Parameters:
  ///   - graphQLEndpoint: The endpoint to make a GraphQL request to
  ///   - operation: The GraphQL Operation to execute
  ///   - contextIdentifier:  [optional] A unique identifier for this request, to help with deduping cache hits for watchers. Defaults to `nil`.
  ///   - contentType: The `Content-Type` header's value. Should usually be set for you by a subclass.
  ///   - clientName: The name of the client to send with the `"apollographql-client-name"` header
  ///   - clientVersion:  The version of the client to send with the `"apollographql-client-version"` header
  ///   - additionalHeaders: Any additional headers you wish to add by default to this request.
  ///   - cachePolicy: The `CachePolicy` to use for this request. Defaults to the `.default` policy
  public init(graphQLEndpoint: URL,
              operation: Operation,
              contextIdentifier: UUID? = nil,
              contentType: String,
              clientName: String,
              clientVersion: String,
              additionalHeaders: [String: String],
              cachePolicy: CachePolicy = .default) {
    self.graphQLEndpoint = graphQLEndpoint
    self.operation = operation
    self.contextIdentifier = contextIdentifier
    self.additionalHeaders = additionalHeaders
    self.cachePolicy = cachePolicy
    
    self.addHeader(name: "Content-Type", value: contentType)
    self.addHeader(name: "X-APOLLO-OPERATION-NAME", value: self.operation.operationName)
    self.addHeader(name: "X-APOLLO-OPERATION-TYPE", value: String(describing: operation.operationType))
    if let operationID = self.operation.operationIdentifier {
      self.addHeader(name: "X-APOLLO-OPERATION-ID", value: operationID)
    }
    
    self.addHeader(name: "apollographql-client-version", value: clientVersion)
    self.addHeader(name: "apollographql-client-name", value: clientName)
  }
  
  open func addHeader(name: String, value: String) {
    self.additionalHeaders[name] = value
  }
  
  open func updateContentType(to contentType: String) {
    self.addHeader(name: "Content-Type", value: contentType)
  }
  
  /// Converts this object to a fully fleshed-out `URLRequest`
  ///
  /// - Throws: Any error in creating the request
  /// - Returns: The URL request, ready to send to your server.
  open func toURLRequest() throws -> URLRequest {
    var request = URLRequest(url: self.graphQLEndpoint)
    
    for (fieldName, value) in additionalHeaders {
      request.addValue(value, forHTTPHeaderField: fieldName)
    }
    
    return request
  }
}

extension HTTPRequest: Equatable {
  
  public static func == (lhs: HTTPRequest<Operation>, rhs: HTTPRequest<Operation>) -> Bool {
    lhs.graphQLEndpoint == rhs.graphQLEndpoint
      && lhs.contextIdentifier == rhs.contextIdentifier
      && lhs.additionalHeaders == rhs.additionalHeaders
      && lhs.cachePolicy == rhs.cachePolicy
      && lhs.operation.queryDocument == rhs.operation.queryDocument
  }
}

extension HTTPRequest: CustomDebugStringConvertible {
  public var debugDescription: String {
    var debugStrings = [String]()
    debugStrings.append("HTTPRequest details:")
    debugStrings.append("Endpoint: \(self.graphQLEndpoint)")
    debugStrings.append("Additional Headers: [")
    for (key, value) in self.additionalHeaders {
      debugStrings.append("\t\(key): \(value),")
    }
    debugStrings.append("]")
    debugStrings.append("Cache Policy: \(self.cachePolicy)")
    debugStrings.append("Operation: \(self.operation)")
    debugStrings.append("Context identifier: \(String(describing: self.contextIdentifier))")
    return debugStrings.joined(separator: "\n\t")
  }
}
