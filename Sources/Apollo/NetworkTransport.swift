import Foundation

/// A network transport is responsible for sending GraphQL operations to a server.
public protocol NetworkTransport: class {
  
  /// Send a GraphQL operation to a server and return a response.
  ///
  /// Note: The `clientName` and `clientVersion` should be sent with any URL request which needs headers so your client can be identified by tools like Apollo Graph Manager. The `addClientHeaders` method is provided below to do this for you automatically, and this is handled for you by batteries-included versions of `NetworkTransport`. 
  ///
  /// - Parameters:
  ///   - operation: The operation to send.
  ///   - completionHandler: A closure to call when a request completes. On `success` will contain the response received from the server. On `failure` will contain the error which occurred.
  /// - Returns: An object that can be used to cancel an in progress request.
  func send<Operation>(operation: Operation, completionHandler: @escaping (_ result: Result<GraphQLResponse<Operation>, Error>) -> Void) -> Cancellable
  
  /// The name of the client to send as the `"apollographql-client-name"` header.
  var clientName: String { get }
  
  /// The version of the client to send as the `"apollographql-client-version"` header
  var clientVersion: String { get }
}

public extension NetworkTransport {
  
  /// The field name for the Apollo Client Name header
  var headerFieldNameApolloClientName: String {
    return "apollographql-client-name"
  }
  
  /// The field name for the Apollo Client Version header
  var headerFieldNameApolloClientVersion: String {
    return "apollographql-client-version"
  }
  
  /// The default client name to use when setting up the `clientName` property
  static var defaultClientName: String {
    guard let identifier = Bundle.main.bundleIdentifier else {
      return "apollo-ios-client"
    }
    
    return "\(identifier)-apollo-ios"
  }
  
  /// The default client version to use when setting up the `clientVersion` property.
  static var defaultClientVersion: String {
    var version = String()
    if let shortVersion = Bundle.main.shortVersion {
      version.append(shortVersion)
    }
    
    if let buildNumber = Bundle.main.buildNumber {
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
  
  /// Adds the Apollo client headers for this instance of `NetworkTransport` to the given request
  /// - Parameter request: A mutable URLRequest to add the headers to.
  func addApolloClientHeaders(to request: inout URLRequest) {
    request.setValue(self.clientName, forHTTPHeaderField: self.headerFieldNameApolloClientName)
    request.setValue(self.clientVersion, forHTTPHeaderField: self.headerFieldNameApolloClientVersion)
  }
}

// MARK: -

/// A network transport which can also handle uploads of files.
public protocol UploadingNetworkTransport: NetworkTransport {
  
  /// Uploads the given files with the given operation.
  ///
  /// - Parameters:
  ///   - operation: The operation to send
  ///   - files: An array of `GraphQLFile` objects to send.
  ///   - completionHandler: The completion handler to execute when the request completes or errors
  /// - Returns: An object that can be used to cancel an in progress request.
  func upload<Operation>(operation: Operation, files: [GraphQLFile], completionHandler: @escaping (_ result: Result<GraphQLResponse<Operation>, Error>) -> Void) -> Cancellable
}
