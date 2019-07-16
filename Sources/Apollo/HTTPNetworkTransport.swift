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
  var session: URLSession
  let serializationFormat = JSONSerializationFormat.self
  let delegate: HTTPNetworkTransportDelegate?

  private let useGETForQueries: Bool
  private let enableAutoPersistedQueries: Bool
  private let useHttpGetMethodForPersistedQueries: Bool
  
  /// Creates a network transport with the specified server URL and session configuration.
  ///
  /// - Parameters:
  ///   - url: The URL of a GraphQL server to connect to.
  ///   - configuration: A session configuration used to configure the session. Defaults to `URLSessionConfiguration.default`.
  ///   - useGETForQueries: If query operation should be sent using GET instead of POST. Defaults to false.
  ///   - enableAutoPersistedQueries: Whether to send persistedQuery extension. QueryDocument will be absent at 1st request, retry with QueryDocument if server respond PersistedQueryNotFound or PersistedQueryNotSupport. Defaults to false.
  ///   - useHttpGetMethodForPersistedQueries: Whether to send PersistedQuery supported request with HTTPGETMethod, retry with HTTPPOSTMethod if PersistedQuery not support/not found in server.
  ///   - preflightDelegate: A delegate to check with before sending a request.
  ///   - requestCompletionDelegate: A delegate to notify when the URLSessionTask has completed.
  public init(url: URL, configuration: URLSessionConfiguration = URLSessionConfiguration.default,
              useGETForQueries: Bool = false,
              enableAutoPersistedQueries: Bool = false,
              useHttpGetMethodForPersistedQueries: Bool = false,
              delegate: HTTPNetworkTransportDelegate? = nil
    ) {
    self.url = url
    self.session = URLSession(configuration: configuration)
    self.delegate = delegate
    self.useGETForQueries = useGETForQueries
    self.enableAutoPersistedQueries = enableAutoPersistedQueries
    self.useHttpGetMethodForPersistedQueries = useHttpGetMethodForPersistedQueries
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
    return send(operation: operation, retryFor: nil, completionHandler: completionHandler)
  }
  
  private func send<Operation>(operation: Operation, retryFor reason:Error? = nil, completionHandler: @escaping (_ response: GraphQLResponse<Operation>?, _ error: Error?) -> Void) -> Cancellable {
    
    let request: URLRequest
    do {
      if operation.operationType != .query {
        request = try self.createRequest(for: operation,
                                         httpMethod: .POST,
                                         sendQueryDocument: true,
                                         autoPersistQueries: false)
      } else {
        let useGetMethod: Bool
        let sendQueryDocument: Bool
        if let reason = reason as? GraphQLHTTPResponseError,
          [GraphQLHTTPResponseError.ErrorKind.persistedQueryNotFound,
           GraphQLHTTPResponseError.ErrorKind.persistedQueryNotSupported].contains(reason.kind) {
          // retry for APQs, with document
          useGetMethod = useGETForQueries
          sendQueryDocument = true
        } else {
          useGetMethod = useGETForQueries || (enableAutoPersistedQueries && useHttpGetMethodForPersistedQueries)
          sendQueryDocument = !enableAutoPersistedQueries
        }
        
        request = try self.createRequest(for: operation,
                                         httpMethod: useGetMethod ? .GET : .POST,
                                         sendQueryDocument: sendQueryDocument,
                                         autoPersistQueries: enableAutoPersistedQueries)
      }
    } catch {
      completionHandler(nil, error)
      return EmptyCancellable()
    }
    
    let task = session.dataTask(with: request) { [weak self] data, response, error in
      guard let self = self else { return }
      
      self.rawTaskCompleted(request: request,
                            data: data,
                            response: response,
                            error: error)
      
      if let receivedError = error {
        self.handleErrorOrRetry(operation: operation,
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
        self.handleErrorOrRetry(operation: operation,
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
        self.handleErrorOrRetry(operation: operation,
                                error: error,
                                for: request,
                                response: response,
                                completionHandler: completionHandler)
        return
      }
      
      do {
        guard let body = try self.serializationFormat.deserialize(data: data) as? JSONObject else {
          throw GraphQLHTTPResponseError(body: data, response: httpResponse, kind: .invalidResponse)
        }
        if self.enableAutoPersistedQueries,
          let error = body["errors"] as? [JSONObject],
          let errorMsg = error.filter ({ $0["message"] as? String != nil }).first?["message"] as? String,
          ["PersistedQueryNotFound","PersistedQueryNotSupported"].contains(errorMsg) {
          
          let errorKind: GraphQLHTTPResponseError.ErrorKind = (errorMsg == "PersistedQueryNotFound") ? .persistedQueryNotFound : .persistedQueryNotSupported
          let apqsError = GraphQLHTTPResponseError(body: data,
                                                   response: httpResponse,
                                                   kind: errorKind)
          
          let retryByDefault: Bool
          if let reason = reason as? GraphQLHTTPResponseError,
            reason.kind == apqsError.kind {
            // if the same error occurs, respect retry option from delegate
            retryByDefault = false
          } else {
            retryByDefault = true
          }
          // Auto Persisted Query handling
          self.handleErrorOrRetry(operation: operation,
                                  error: apqsError,
                                  for: request,
                                  response: response,
                                  retryByDefault: retryByDefault,
                                  completionHandler: completionHandler)

        }else {
          // no errors
          let response = GraphQLResponse(operation: operation, body: body)
          completionHandler(response, nil)
        }
      } catch let parsingError {
        self.handleErrorOrRetry(operation: operation,
                                error: parsingError,
                                for: request,
                                response: response,
                                completionHandler: completionHandler)
        
      }
    }
    task.resume()
    return task
  }
  
  // retryByDefault: still retry if delegate is absent, otherwise repect the value from delegate
  private func handleErrorOrRetry<Operation>(operation: Operation, error: Error, for request: URLRequest, response: URLResponse?, retryByDefault: Bool = false, completionHandler: @escaping (_ response: GraphQLResponse<Operation>?, _ error: Error?) -> Void) {
    if let delegate = self.delegate,
      let retrier = delegate as? HTTPNetworkTransportRetryDelegate {
      retrier.networkTransport(
        self,
        receivedError: error,
        for: request,
        response: response,
        retryHandler: { [weak self] shouldRetry in
          guard let self = self, shouldRetry else {
            completionHandler(nil, error)
            return
          }
          _ = self.send(operation: operation, retryFor: error, completionHandler: completionHandler)
      })
    } else if retryByDefault {
      _ = self.send(operation: operation, retryFor: error, completionHandler: completionHandler)
    } else {
      completionHandler(nil, error)
      return
    }
  }

  private func rawTaskCompleted(request: URLRequest, data: Data?, response: URLResponse?, error: Error?) {
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
  
  private func createRequest<Operation: GraphQLOperation>(for operation: Operation, httpMethod: GraphQLHTTPMethod, sendQueryDocument: Bool, autoPersistQueries: Bool) throws -> URLRequest {
    
    var request: URLRequest
    let body = requestBody(for: operation, sendQueryDocument: sendQueryDocument, autoPersistQueries: autoPersistQueries)
    
    if httpMethod == .GET {
      let transformer = GraphQLGETTransformer(body: body, url: self.url)
      if let urlForGet = transformer.createGetURL() {
        request = URLRequest(url: urlForGet)
        request.httpMethod = GraphQLHTTPMethod.GET.rawValue
      } else {
        throw GraphQLHTTPRequestError.serializedQueryParamsMessageError
      }
    } else {
      do {
        request = URLRequest(url: self.url)
        request.httpMethod = GraphQLHTTPMethod.POST.rawValue
        request.httpBody = try serializationFormat.serialize(value: body)
      } catch {
        throw GraphQLHTTPRequestError.serializedBodyMessageError
      }
    }

    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(operation.operationIdentifier, forHTTPHeaderField: "X-APOLLO-OPERATION-ID")
    
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

  private func requestBody<Operation: GraphQLOperation>(for operation: Operation,
                                                        sendQueryDocument: Bool,
                                                        autoPersistQueries: Bool) -> GraphQLMap {
    
    var payload: GraphQLMap = [:]
    
    if autoPersistQueries {
      guard let operationIdentifier = operation.operationIdentifier else {
        preconditionFailure("To enabled autoPersistQueries, Apollo types must be generated with operationIdentifiers")
      }
      payload["extensions"] = [
        "persistedQuery" : ["sha256Hash": operationIdentifier, "version": 1]
      ]
    }
    
    if let variables = operation.variables?.compactMapValues({ $0 }), variables.count > 0 {
      payload["variables"] = variables
    }
    
    if sendQueryDocument {
      // TODO: This work-around fix "operationId is invalid for swift codegen" (https://github.com/apollographql/apollo-tooling/issues/1362), please remove this work-around after it's fixed.
      let modifiedQuery = operation.queryDocument.replacingOccurrences(of: "fragment", with: "\nfragment")
      payload["query"] = modifiedQuery
    }
    
    return payload
  }
}
