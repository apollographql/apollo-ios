import Foundation

/// Encapsulation of all information about a request before it hits the network
open class HTTPRequest<Operation: GraphQLOperation> {
  
  /// The endpoint to make a GraphQL request to
  open var graphQLEndpoint: URL
  
  /// The GraphQL Operation to execute
  open var operation: Operation
  
  /// The `Content-Type` header's value
  open var contentType: String
  
  /// Any additional headers you wish to add by default to this request
  open var additionalHeaders: [String: String]
  
  /// [optional] The name of the current client, defaults to nil
  open var clientName: String? = nil
  
  /// [optional] The version of the current client, defaults to nil
  open var clientVersion: String? = nil
  
  /// How many times this request has been retried. Must be incremented manually. Defaults to zero.
  open var retryCount: Int = 0
  
  /// The `CachePolicy` to use for this request.
  public let cachePolicy: CachePolicy
  
  /// Designated Initializer
  ///
  /// - Parameters:
  ///   - graphQLEndpoint: The endpoint to make a GraphQL request to
  ///   - operation: The GraphQL Operation to execute
  ///   - contentType: The `Content-Type` header's value. Should usually be set for you by a subclass.
  ///   - additionalHeaders: Any additional headers you wish to add by default to this request.
  ///   - cachePolicy: The `CachePolicy` to use for this request. Defaults to the `.default` policy
  public init(graphQLEndpoint: URL,
              operation: Operation,
              contentType: String,
              additionalHeaders: [String: String],
              cachePolicy: CachePolicy = .default) {
    self.graphQLEndpoint = graphQLEndpoint
    self.operation = operation
    self.contentType = contentType
    self.additionalHeaders = additionalHeaders
    self.cachePolicy = cachePolicy
  }
  
  public var defaultClientName: String {
    guard let identifier = Bundle.main.bundleIdentifier else {
      return "apollo-ios-client"
    }
    
    return "\(identifier)-apollo-ios"
  }
  
  public var defaultClientVersion: String {
    var version = String()
    if let shortVersion = Bundle.main.apollo.shortVersion {
      version.append(shortVersion)
    }
    
    if let buildNumber = Bundle.main.apollo.buildNumber {
      if version.isEmpty {
        version.append(buildNumber)
      } else {
        version.append("-\(buildNumber)")
      }
    }
    
    if version.isEmpty {
      version = "(unknown)"
    }
    
    return version
  }
  
  open func addHeader(name: String, value: String) {
    self.additionalHeaders[name] = value
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
    
    request.addValue(self.contentType, forHTTPHeaderField: "Content-Type")
    request.addValue(self.operation.operationName, forHTTPHeaderField: "X-APOLLO-OPERATION-NAME")
    if let operationID = self.operation.operationIdentifier {
      request.addValue(operationID, forHTTPHeaderField: "X-APOLLO-OPERATION-ID")
    }
    request.addValue(self.clientVersion ?? self.defaultClientVersion, forHTTPHeaderField: "apollographql-client-version")
    request.addValue(self.clientName ?? self.defaultClientVersion   , forHTTPHeaderField: "apollographql-client-name")
    
    return request
  }
}

extension HTTPRequest: Equatable {
  
  public static func == (lhs: HTTPRequest<Operation>, rhs: HTTPRequest<Operation>) -> Bool {
    lhs.graphQLEndpoint == rhs.graphQLEndpoint
      && lhs.additionalHeaders == rhs.additionalHeaders
      && lhs.cachePolicy == rhs.cachePolicy
      && lhs.contentType == rhs.contentType
      && lhs.operation.queryDocument == rhs.operation.queryDocument
      && lhs.clientName == rhs.clientName
      && lhs.clientVersion == rhs.clientVersion
  }  
}
