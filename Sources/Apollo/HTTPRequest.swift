import Foundation

open class HTTPRequest<Operation: GraphQLOperation> {
  
  public enum HTTPRequestError: Error {
    case noRequestConstructed
  }
  
  open var graphQLEndpoint: URL
  open var operation: Operation
  open var contentType: String
  open var additionalHeaders: [String: String]
  open var clientName: String? = nil
  open var clientVersion: String? = nil
  
  public init(graphQLEndpoint: URL,
              operation: Operation,
              contentType: String,
              additionalHeaders: [String: String]) {
    self.graphQLEndpoint = graphQLEndpoint
    self.operation = operation
    self.contentType = contentType
    self.additionalHeaders = additionalHeaders
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

