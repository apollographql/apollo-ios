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

/// A network transport that uses HTTP POST requests to send GraphQL operations to a server, and that uses `URLSession` as the networking implementation.
public class HTTPNetworkTransport: NetworkTransport {
  
  /// Allow to modify the request before it's sent.
  ///
  /// The block may modify the request for example by appending additional request headers. Once the delegate is done, the completion block must be called.
  ///
  /// - Parameters:
  ///   - request: Request that is about to be sent.
  ///   - completion: Block that must be called once the delegate has finished modifying the request. An error may be passed if the request should not be sent (for example, necessary authentication cannot be provided and the request would fail anyway).
  public typealias PrepareRequest = (_ request: URLRequest, _ completion: @escaping (Result<URLRequest>)->Void) -> Void
  
  let url: URL
  let session: URLSession
  let prepareRequest: PrepareRequest?
  let serializationFormat = JSONSerializationFormat.self
  
  /// Creates a network transport with the specified server URL and session configuration.
  ///
  /// - Parameters:
  ///   - url: The URL of a GraphQL server to connect to.
  ///   - configuration: A session configuration used to configure the session. Defaults to `URLSessionConfiguration.default`.
  ///   - requestDelegate: Delegate that may modify requests before they are sent out (for example, by adding additional headers).
  ///   - sendOperationIdentifiers: Whether to send operation identifiers rather than full operation text, for use with servers that support query persistence. Defaults to false.
  public init(url: URL, configuration: URLSessionConfiguration = URLSessionConfiguration.default, prepareRequest: PrepareRequest? = nil, sendOperationIdentifiers: Bool = false) {
    self.url = url
    self.session = URLSession(configuration: configuration)
    self.prepareRequest = prepareRequest
    self.sendOperationIdentifiers = sendOperationIdentifiers
  }
  
  /// Send a GraphQL operation to a server and return a response.
  ///
  /// - Parameters:
  ///   - operation: The operation to send.
  ///   - completionHandler: A closure to call when a request completes.
  ///   - response: The response received from the server, or `nil` if an error occurred.
  ///   - error: An error that indicates why a request failed, or `nil` if the request was succesful.
  /// - Returns: An object that can be used to cancel an in progress request.
  public func send<Operation>(operation: Operation, completionHandler: @escaping (GraphQLResponse<Operation>?, Error?) -> Void) -> Cancellable {
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let body = requestBody(for: operation)
    request.httpBody = try! serializationFormat.serialize(value: body)
    
    if let prepareRequest = prepareRequest {
      var cancellable: PromisedCancellable?
      let promise = Promise<Cancellable> {
        (fulfill, reject) in
        
        prepareRequest(request) {
          (result) in
          
          // Check whether the operation was cancelled and stop here instead of trying to send the request.
          if let cancellable = cancellable, cancellable.isCancelled {
            let error = URLError(.cancelled)
            reject(error)
            completionHandler(nil, error)
          }
          
          switch result {
          case .success(let preparedRequest):
            fulfill(self.send(operation: operation, request: preparedRequest, completionHandler: completionHandler))
            
          case .failure(let error):
            reject(error)
            completionHandler(nil, error)
          }
        }
      }
      
      let actualCancellable = PromisedCancellable(promise: promise)
      cancellable = actualCancellable
      return actualCancellable
      
    } else {
      return self.send(operation: operation, request: request, completionHandler: completionHandler)
    }
  }
  
  private func send<Operation>(operation: Operation, request: URLRequest, completionHandler: @escaping (GraphQLResponse<Operation>?, Error?) -> Void) -> Cancellable {
    let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
      if let error = error {
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
      guard let operationIdentifier = type(of: operation).operationIdentifier else {
        preconditionFailure("To send operation identifiers, Apollo types must be generated with operationIdentifiers")
      }
      return ["id": operationIdentifier, "variables": operation.variables]
    }
    return ["query": type(of: operation).requestString, "variables": operation.variables]
  }
}
