import Foundation

extension URLSessionTask: Cancellable {}

/// A transport-level, HTTP-specific error.
public struct GraphQLHTTPResponseError: Error, LocalizedError {
  public enum ErrorKind {
    case errorResponse
    case invalidResponse
    
    var description: String {
      switch self {
      case .errorResponse:
        return "Received error response"
      case .invalidResponse:
        return "Received invalid response"
      }
    }
  }
  
  /// The body of the response.
  public let body: Data?
  /// Information about the response as provided by the server.
  public let response: HTTPURLResponse
  public let kind: ErrorKind

    public init(body: Data? = nil, response: HTTPURLResponse, kind: ErrorKind) {
        self.body = body
        self.response = response
        self.kind = kind
    }
  
  public var bodyDescription: String {
    if let body = body {
      if let description = String(data: body, encoding: response.textEncoding ?? .utf8) {
        return description
      } else {
        return "Unreadable response body"
      }
    } else {
      return "Empty response body"
    }
  }
  
  public var errorDescription: String? {
    return "\(kind.description) (\(response.statusCode) \(response.statusCodeDescription)): \(bodyDescription)"
  }
}

public struct GraphQLHTTPRequestError: Error, LocalizedError {
  public enum ErrorKind {
    case serializedBodyMessageError
    case serializedQueryParamsMessageError
    
    var description: String {
      switch self {
        case .serializedBodyMessageError:
          return "JSONSerialization error: Error while serializing request's body"
        case .serializedQueryParamsMessageError:
          return "QueryParams error: Error while serializing variables as query parameters."
        }
      }
    }
    
    public init(kind: ErrorKind) {
      self.kind = kind
    }
    
    public let kind: ErrorKind
    
    public var errorDescription: String? {
      return "\(kind.description)"
    }
}

/// A network transport that uses HTTP POST requests to send GraphQL operations to a server, and that uses `URLSession` as the networking implementation.
public class HTTPNetworkTransport: NetworkTransport {
  let url: URL
  let session: URLSession
  let serializationFormat = JSONSerializationFormat.self
  
  /// Creates a network transport with the specified server URL and session configuration.
  ///
  /// - Parameters:
  ///   - url: The URL of a GraphQL server to connect to.
  ///   - configuration: A session configuration used to configure the session. Defaults to `URLSessionConfiguration.default`.
  ///   - sendOperationIdentifiers: Whether to send operation identifiers rather than full operation text, for use with servers that support query persistence. Defaults to false.
  public init(url: URL, configuration: URLSessionConfiguration = URLSessionConfiguration.default, sendOperationIdentifiers: Bool = false) {
    self.url = url
    self.session = URLSession(configuration: configuration)
    self.sendOperationIdentifiers = sendOperationIdentifiers
  }
  
  /// Send a GraphQL operation to a server and return a response.
  ///
  /// - Parameters:
  ///   - operation: The operation to send.
  ///   - fetchHTTPMethod: The HTTP Method to be used in operation.
  ///   - completionHandler: A closure to call when a request completes.
  ///   - response: The response received from the server, or `nil` if an error occurred.
  ///   - error: An error that indicates why a request failed, or `nil` if the request was succesful.
  /// - Returns: An object that can be used to cancel an in progress request.
  public func send<Operation>(operation: Operation, fetchHTTPMethod: FetchHTTPMethod, completionHandler: @escaping (_ response: GraphQLResponse<Operation>?, _ error: Error?) -> Void) -> Cancellable {
    let body = requestBody(for: operation)
    var request = URLRequest(url: url)
    
    switch fetchHTTPMethod {
    case .GET:
      if let urlForGet = mountUrlWithQueryParamsIfNeeded(body: body) {
        request = URLRequest(url: urlForGet)
      } else {
        completionHandler(nil, GraphQLHTTPRequestError(kind: .serializedQueryParamsMessageError))
      }
    default:
      do {
        request.httpBody = try serializationFormat.serialize(value: body)
      } catch {
        completionHandler(nil, GraphQLHTTPRequestError(kind: .serializedBodyMessageError))
      }
    }
    
    request.httpMethod = fetchHTTPMethod.rawValue
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
      if error != nil {
        completionHandler(nil, error)
        return
      }

      guard let httpResponse = response as? HTTPURLResponse else {
        fatalError("Response should be an HTTPURLResponse")
      }

      if (!httpResponse.isSuccessful) {
        completionHandler(nil, GraphQLHTTPResponseError(body: data, response: httpResponse, kind: .errorResponse))
        return
      }

      guard let data = data else {
        completionHandler(nil, GraphQLHTTPResponseError(body: nil, response: httpResponse, kind: .invalidResponse))
        return
      }

      do {
        guard let body =  try self.serializationFormat.deserialize(data: data) as? JSONObject else {
          throw GraphQLHTTPResponseError(body: data, response: httpResponse, kind: .invalidResponse)
        }
        let response = GraphQLResponse(operation: operation, body: body)
        completionHandler(response, nil)
      } catch {
        completionHandler(nil, error)
      }
    }
    
    task.resume()
    
    return task
  }

  private let sendOperationIdentifiers: Bool

  private func requestBody<Operation: GraphQLOperation>(for operation: Operation) -> GraphQLMap {
    if sendOperationIdentifiers {
      guard let operationIdentifier = operation.operationIdentifier else {
        preconditionFailure("To send operation identifiers, Apollo types must be generated with operationIdentifiers")
      }
      return ["id": operationIdentifier, "variables": operation.variables]
    }
    return ["query": operation.queryDocument, "variables": operation.variables]
  }
    
  private func mountUrlWithQueryParamsIfNeeded(body: GraphQLMap) -> URL? {
    guard let query = body.jsonObject["query"], var queryParam = queryString(withItems:  [URLQueryItem(name: "query", value: "\(query)")]) else {
        return self.url
    }
    if areThereVariables(in: body) {
        guard let serializedVariables = try? serializationFormat.serialize(value: body.jsonObject["variables"]) else {
            return URL(string: "\(self.url.absoluteString)?\(queryParam)")
        }
        queryParam += getVariablesEncodedString(of: serializedVariables)
    }
    guard let urlForGet = URL(string: "\(self.url.absoluteString)?\(queryParam)") else {
        return URL(string: "\(self.url.absoluteString)?\(queryParam)")
    }
    return urlForGet
  }

  private func areThereVariables(in map: GraphQLMap) -> Bool {
    if let variables = map.jsonObject["variables"], "\(variables)" != "<null>" {
        return true
    }
    return false
  }

  private func getVariablesEncodedString(of data: Data) -> String {
    var dataString = String(data: data, encoding: String.Encoding.utf8) ?? ""
    dataString = dataString.replacingOccurrences(of: ";", with: ",")
    dataString = dataString.replacingOccurrences(of: "=", with: ":")
    guard let variablesEncoded = queryString(withItems:  [URLQueryItem(name: "variables", value: "\(dataString)")]) else { return "" }
    return "&\(variablesEncoded)"
  }

  private func queryString(withItems items: [URLQueryItem], percentEncoded: Bool = true) -> String? {
    let url = NSURLComponents()
    url.queryItems = items
    let queryString = percentEncoded ? url.percentEncodedQuery : url.query
    
    if let queryString = queryString {
        return "\(queryString)"
    }
    return nil
  }
}
