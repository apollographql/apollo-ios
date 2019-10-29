import Foundation

/// A network transport is responsible for sending GraphQL operations to a server.
public protocol NetworkTransport: class {
  
  /// Send a GraphQL operation to a server and return a response.
  ///
  /// - Parameters:
  ///   - operation: The operation to send.
  ///   - completionHandler: A closure to call when a request completes. On `success` will contain the response received from the server. On `failure` will contain the error which occurred.
  /// - Returns: An object that can be used to cancel an in progress request.
  func send<Operation>(operation: Operation, completionHandler: @escaping (_ result: Result<GraphQLResponse<Operation>, Error>) -> Void) -> Cancellable
  
  /// The name of the client to send as the `"apollographql-client-name"` header.
  var clientName: String { get set }
  
  /// The version of the client to send as the `"apollographql-client-version"` header
  var clientVersion: String { get set }
}

public extension NetworkTransport {
  
  /// The header field name for the Client Name
  static var headerFieldNameClientName: String {
    return "apollographql-client-name"
  }
  
  /// The header field name for the client version
  static var headerFieldNameClientVersion: String {
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
