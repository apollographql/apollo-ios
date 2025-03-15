import Foundation
#if !COCOAPODS
import ApolloAPI
#endif
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A network transport is responsible for sending GraphQL operations to a server.
public protocol NetworkTransport: AnyObject {

  /// Send a GraphQL operation to a server and return a response.
  ///
  /// Note if you're implementing this yourself rather than using one of the batteries-included versions of `NetworkTransport` (which handle this for you): The `clientName` and `clientVersion` should be sent with any URL request which needs headers so your client can be identified by tools meant to see what client is using which request. The `addApolloClientHeaders` method is provided below to do this for you if you're using Apollo Studio.
  ///
  /// - Parameters:
  ///   - operation: The operation to send.
  ///   - cachePolicy: The `CachePolicy` to use making this request.
  ///   - contextIdentifier:  [optional] A unique identifier for this request, to help with deduping cache hits for watchers. Defaults to `nil`.
  ///   - context: [optional] A context that is being passed through the request chain. Defaults to `nil`.
  ///   - callbackQueue: The queue to call back on with the results. Should default to `.main`.
  ///   - completionHandler: A closure to call when a request completes. On `success` will contain the response received from the server. On `failure` will contain the error which occurred.
  /// - Returns: An object that can be used to cancel an in progress request.
  func send<Operation: GraphQLOperation>(operation: Operation,
                                         cachePolicy: CachePolicy,
                                         contextIdentifier: UUID?,
                                         context: (any RequestContext)?,
                                         callbackQueue: DispatchQueue,
                                         completionHandler: @escaping (Result<GraphQLResult<Operation.Data>, any Error>) -> Void) -> any Cancellable

  /// The name of the client to send as a header value.
  var clientName: String { get }

  /// The version of the client to send as a header value.
  var clientVersion: String { get }
}

public extension NetworkTransport {

  /// The field name for the Apollo Client Name header
  static var headerFieldNameApolloClientName: String {
    return "apollographql-client-name"
  }

  /// The field name for the Apollo Client Version header
  static var headerFieldNameApolloClientVersion: String {
    return "apollographql-client-version"
  }

  /// The default client name to use when setting up the `clientName` property
  static var defaultClientName: String {
    guard let identifier = Bundle.main.bundleIdentifier else {
      return "apollo-ios-client"
    }

    return "\(identifier)-apollo-ios"
  }

  var clientName: String {
    return Self.defaultClientName
  }

  /// The default client version to use when setting up the `clientVersion` property.
  static var defaultClientVersion: String {
    var version = String()
#if !os(Linux)
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
#endif // !os(Linux)

    if version.isEmpty {
      version = "(unknown)"
    }

    return version
  }

  var clientVersion: String {
    return Self.defaultClientVersion
  }

  /// Adds the Apollo client headers for this instance of `NetworkTransport` to the given request
  /// - Parameter request: A mutable URLRequest to add the headers to.
  func addApolloClientHeaders(to request: inout URLRequest) {
    request.setValue(self.clientName, forHTTPHeaderField: Self.headerFieldNameApolloClientName)
    request.setValue(self.clientVersion, forHTTPHeaderField: Self.headerFieldNameApolloClientVersion)
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
  ///   - context: [optional] A context that is being passed through the request chain.
  ///   - callbackQueue: The queue to call back on with the results. Should default to `.main`.
  ///   - completionHandler: The completion handler to execute when the request completes or errors
  /// - Returns: An object that can be used to cancel an in progress request.
  func upload<Operation: GraphQLOperation>(
    operation: Operation,
    files: [GraphQLFile],
    context: (any RequestContext)?,
    callbackQueue: DispatchQueue,
    completionHandler: @escaping (Result<GraphQLResult<Operation.Data>,any Error>) -> Void) -> any Cancellable
}
