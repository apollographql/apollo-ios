import Foundation

/// Empty base protocol to allow multiple sub-protocols to just use a single parameter.
public protocol HTTPNetworkTransportDelegate: class {}

/// Methods which will be called prior to a request being sent to the server.
public protocol HTTPNetworkTransportPreflightDelegate: HTTPNetworkTransportDelegate {
  
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

// MARK: -

/// Methods which will be called after some kind of response has been received to a `URLSessionTask`.
public protocol HTTPNetworkTransportTaskCompletedDelegate: HTTPNetworkTransportDelegate {
  
  /// A callback to allow hooking in URL session responses for things like logging and examining headers.
  /// NOTE: This will call back on whatever thread the URL session calls back on, which is never the main thread. Call `DispatchQueue.main.async` before touching your UI!
  ///
  /// - Parameters:
  ///   - networkTransport: The network transport that completed a task
  ///   - request: The request which was completed by the task
  ///   - data: [optional] Any data received. Passed through from `URLSession`.
  ///   - response: [optional] Any response received. Passed through from `URLSession`.
  ///   - error: [optional] Any error received. Passed through from `URLSession`.
  func networkTransport(_ networkTransport: HTTPNetworkTransport,
                        didCompleteRawTaskForRequest request: URLRequest,
                        withData data: Data?,
                        response: URLResponse?,
                        error: Error?)
}

// MARK: -

public protocol HTTPNetworkTransportRetryDelegate: HTTPNetworkTransportDelegate {
  
  /// Called when an error has been received after a request has been sent to the server to see if an operation should be retried or not.
  /// NOTE: Don't just call the `retryHandler` with `true` all the time, or you can potentially wind up in an infinite loop of errors
  ///
  /// - Parameters:
  ///   - networkTransport: The network transport which received the error
  ///   - error: The received error
  ///   - request: The URLRequest which generated the error
  ///   - response: [Optional] Any response received when the error was generated
  ///   - retryHandler: A closure indicating whether the operation should be retried. Asyncrhonous to allow for re-authentication or other async operations to complete.
  func networkTransport(_ networkTransport: HTTPNetworkTransport,
                        receivedError error: Error,
                        for request: URLRequest,
                        response: URLResponse?,
                        retryHandler: @escaping (_ shouldRetry: Bool) -> Void)
}

// MARK: -

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
  ///   - preflightDelegate: A delegate to check with before sending a request.
  ///   - requestCompletionDelegate: A delegate to notify when the URLSessionTask has completed.
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
    let request: URLRequest
    do {
      request = try self.createRequest(for: operation)
    } catch {
      completionHandler(nil, error)
      return EmptyCancellable()
    }
    
    let task = session.dataTask(with: request) { [weak self] data, response, error in
      self?.rawTaskCompleted(request: request,
                             data: data,
                             response: response,
                             error: error)

      if let receivedError = error {
        self?.handleErrorOrRetry(operation: operation,
                                 error: receivedError,
                                 for: request,
                                 response: response,
                                 completionHandler: completionHandler)
        return
      }

      guard let httpResponse = response as? HTTPURLResponse else {
        fatalError("Response should be an HTTPURLResponse")
      }

      guard httpResponse.isSuccessful else {
        let unsuccessfulError = GraphQLHTTPResponseError(body: data,
                                                         response: httpResponse,
                                                         kind: .errorResponse)
        self?.handleErrorOrRetry(operation: operation,
                                 error: unsuccessfulError,
                                 for: request,
                                 response: response,
                                 completionHandler: completionHandler)
        return
      }

      guard let data = data else {
        let error = GraphQLHTTPResponseError(body: nil,
                                             response: httpResponse,
                                             kind: .invalidResponse)
        self?.handleErrorOrRetry(operation: operation,
                                 error: error,
                                 for: request,
                                 response: response,
                                 completionHandler: completionHandler)
        return
      }

      do {
        guard let body = try self?.serializationFormat.deserialize(data: data) as? JSONObject else {
          throw GraphQLHTTPResponseError(body: data, response: httpResponse, kind: .invalidResponse)
        }
        let response = GraphQLResponse(operation: operation, body: body)
        completionHandler(response, nil)
      } catch let parsingError {
        self?.handleErrorOrRetry(operation: operation,
                                 error: parsingError,
                                 for: request,
                                 response: response,
                                 completionHandler: completionHandler)
      }
    }
    
    task.resume()
    
    return task
  }

  private let sendOperationIdentifiers: Bool
  
  private func handleErrorOrRetry<Operation>(operation: Operation,
                                             error: Error,
                                             for request: URLRequest,
                                             response: URLResponse?,
                                             completionHandler: @escaping (_ response: GraphQLResponse<Operation>?, _ error: Error?) -> Void) {
    guard
      let delegate = self.delegate,
      let retrier = delegate as? HTTPNetworkTransportRetryDelegate else {
      completionHandler(nil, error)
      return
    }
    
    retrier.networkTransport(
      self,
      receivedError: error,
      for: request,
      response: response,
      retryHandler: { [weak self] shouldRetry in
        guard shouldRetry else {
          completionHandler(nil, error)
          return
        }
        
        _ = self?.send(operation: operation, completionHandler: completionHandler)
    })
  }
  
  private func rawTaskCompleted(request: URLRequest,
                                data: Data?,
                                response: URLResponse?,
                                error: Error?) {
    guard
      let delegate = self.delegate,
      let taskDelegate = delegate as? HTTPNetworkTransportTaskCompletedDelegate else {
      return
    }
    
    taskDelegate.networkTransport(self,
                                  didCompleteRawTaskForRequest: request,
                                  withData: data,
                                  response: response,
                                  error: error)
  }
  
  private func createRequest<Operation: GraphQLOperation>(for operation: Operation) throws -> URLRequest {
    let body = requestBody(for: operation)
    var request = URLRequest(url: self.url)
    
    if self.useGETForQueries && operation.operationType == .query {
      let transformer = GraphQLGETTransformer(body: body, url: self.url)
      if let urlForGet = transformer.createGetURL() {
        request = URLRequest(url: urlForGet)
        request.httpMethod = GraphQLHTTPMethod.GET.rawValue
      } else {
        throw GraphQLHTTPRequestError.serializedQueryParamsMessageError
      }
    } else {
      do {
        request.httpBody = try serializationFormat.serialize(value: body)
        request.httpMethod = GraphQLHTTPMethod.POST.rawValue
      } catch {
        throw GraphQLHTTPRequestError.serializedBodyMessageError
      }
    }
    
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    // If there's a delegate, do a pre-flight check and allow modifications to the request.
    if
      let delegate = self.delegate,
      let preflightDelegate = delegate as? HTTPNetworkTransportPreflightDelegate {
        guard preflightDelegate.networkTransport(self, shouldSend: request) else {
          throw GraphQLHTTPRequestError.cancelledByDelegate
        }
      
        preflightDelegate.networkTransport(self, willSend: &request)
    }
    
    return request
  }

  private func requestBody<Operation: GraphQLOperation>(for operation: Operation) -> GraphQLMap {
    if sendOperationIdentifiers {
      guard let operationIdentifier = operation.operationIdentifier else {
        preconditionFailure("To send operation identifiers, Apollo types must be generated with operationIdentifiers")
      }
      
      return ["id": operationIdentifier, "variables": operation.variables]
    }
    
    return ["query": operation.queryDocument, "variables": operation.variables]
  }
}
