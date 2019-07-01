import Foundation

public protocol HTTPNetworkTransportDelegate: class {
  
  /// Called when a request is about to send, to validate that it should be sent.
  /// Good for early-exiting if your user is not logged in, for example.
  ///
  /// - Parameters:
  ///   - networkTransport: The network transport which wants to send a request
  ///   - request: The request, BEFORE it has been modified by `willSend`
  /// - Returns: True if the request should proceed, false if not.
  func networkTransport(_ networkTransport: HTTPNetworkTransport, shouldSend request: URLRequest) -> Bool
  
  /// Called when a request is about to send. Allows last minute modification of any properties on the request,
  ///
  ///
  /// - Parameters:
  ///   - networkTransport: The network transport which is about to send a request
  ///   - request: The request, as an `inout` variable for modification
  func networkTransport(_ networkTransport: HTTPNetworkTransport, willSend request: inout URLRequest)
}

/// A network transport that uses HTTP POST requests to send GraphQL operations to a server, and that uses `URLSession` as the networking implementation.
public class HTTPNetworkTransport: NetworkTransport {
  let url: URL
  let session: URLSession
  let serializationFormat = JSONSerializationFormat.self
  let useGETForQueries: Bool
  let delegate: HTTPNetworkTransportDelegate?

  /// Creates a network transport with the specified server URL and session configuration.
  ///
  /// - Parameters:
  ///   - url: The URL of a GraphQL server to connect to.
  ///   - configuration: A session configuration used to configure the session. Defaults to `URLSessionConfiguration.default`.
  ///   - sendOperationIdentifiers: Whether to send operation identifiers rather than full operation text, for use with servers that support query persistence. Defaults to false.
  ///   - useGETForQueries: If query operation should be sent using GET instead of POST. Defaults to false.
  public init(url: URL,
              configuration: URLSessionConfiguration = .default,
              sendOperationIdentifiers: Bool = false,
              useGETForQueries: Bool = false,
              delegate: HTTPNetworkTransportDelegate? = nil) {
    self.url = url
    self.session = URLSession(configuration: configuration)
    self.sendOperationIdentifiers = sendOperationIdentifiers
    self.useGETForQueries = useGETForQueries
    self.delegate = delegate
  }
  
  /// Send a GraphQL operation to a server and return a response.
  ///
  /// - Parameters:
  ///   - operation: The operation to send.
  ///   - completionHandler: A closure to call when a request completes.
  ///   - response: The response received from the server, or `nil` if an error occurred.
  ///   - error: An error that indicates why a request failed, or `nil` if the request was succesful.
  /// - Returns: An object that can be used to cancel an in progress request.
  public func send<Operation>(operation: Operation, completionHandler: @escaping (_ response: GraphQLResponse<Operation>?, _ error: Error?) -> Void) -> Cancellable {
    let body = requestBody(for: operation)
    var request = URLRequest(url: url)
 
    if self.useGETForQueries && operation.operationType == .query {
      if let urlForGet = mountUrlWithQueryParamsIfNeeded(body: body) {
        request = URLRequest(url: urlForGet)
        request.httpMethod = GraphQLHTTPMethod.GET.rawValue
      } else {
        completionHandler(nil, GraphQLHTTPRequestError.serializedQueryParamsMessageError)
        return EmptyCancellable()
      }
    } else {
      do {
        request.httpBody = try serializationFormat.serialize(value: body)
        request.httpMethod = GraphQLHTTPMethod.POST.rawValue
      } catch {
        completionHandler(nil, GraphQLHTTPRequestError.serializedBodyMessageError)
        return EmptyCancellable()
      }
    }
    
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    // If there's a delegate, do a pre-flight check and allow modifications to the request.
    if let delegate = self.delegate {
      guard delegate.networkTransport(self, shouldSend: request) else {
        completionHandler(nil, GraphQLHTTPRequestError.cancelledByDeveloper)
        return ErrorCancellable()
      }
      
      delegate.networkTransport(self, willSend: &request)
    }
    
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
    let transformer = GraphQLGETTransformer(body: body, url: self.url)
    return transformer.mountUrlWithQueryParamsIfNeeded()
  }
}
