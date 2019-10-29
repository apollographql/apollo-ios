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

/// Methods which will be called if an error is receieved at the network level.
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

/// Methods which will be called after some kind of response has been received and it contains GraphQLErrors.
public protocol HTTPNetworkTransportGraphQLErrorDelegate: HTTPNetworkTransportDelegate {

  /// Called when response contains one or more GraphQL errors.
  ///
  /// NOTE: The mere presence of a GraphQL error does not necessarily mean a request failed!
  ///       GraphQL is design to allow partial success/failures to return, so make sure
  ///       you're validating the *type* of error you're getting in this before deciding whether to retry or not.
  ///
  /// ALSO NOTE: Don't just call the `retryHandler` with `true` all the time, or you can
  ///            potentially wind up in an infinite loop of errors
  ///
  /// - Parameters:
  ///   - networkTransport: The network transport which received the error
  ///   - errors: The received GraphQL errors
  ///   - retryHandler: A closure indicating whether the operation should be retried. Asyncrhonous to allow for re-authentication or other async operations to complete.
  func networkTransport(_ networkTransport: HTTPNetworkTransport, receivedGraphQLErrors errors: [GraphQLError], retryHandler: @escaping (_ shouldRetry: Bool) -> Void)
}

// MARK: -

/// A network transport that uses HTTP POST requests to send GraphQL operations to a server, and that uses `URLSession` as the networking implementation.
public class HTTPNetworkTransport {
  let url: URL
  let session: URLSession
  let serializationFormat = JSONSerializationFormat.self
  let useGETForQueries: Bool
  let enableAutoPersistedQueries: Bool
  let useGETForPersistedQueryRetry: Bool
  let delegate: HTTPNetworkTransportDelegate?
  private let requestCreator: RequestCreator
  private let sendOperationIdentifiers: Bool
  
  public lazy var clientName = HTTPNetworkTransport.defaultClientName
  public lazy var clientVersion = HTTPNetworkTransport.defaultClientVersion
  
  /// Creates a network transport with the specified server URL and session configuration.
  ///
  /// - Parameters:
  ///   - url: The URL of a GraphQL server to connect to.
  ///   - session: The URLSession to use. Defaults to `URLSession.shared`,
  ///   - sendOperationIdentifiers: Whether to send operation identifiers rather than full operation text, for use with servers that support query persistence. Defaults to false.
  ///   - useGETForQueries: If query operation should be sent using GET instead of POST. Defaults to false.
  ///   - enableAutoPersistedQueries: Whether to send persistedQuery extension. QueryDocument will be absent at 1st request, retry with QueryDocument if server respond PersistedQueryNotFound or PersistedQueryNotSupport. Defaults to false.
  ///   - useGETForPersistedQueryRetry: Whether to retry persistedQuery request with HttpGetMethod. Defaults to false.
  ///   - delegate: [Optional] A delegate which can conform to any or all of `HTTPNetworkTransportPreflightDelegate`, `HTTPNetworkTransportTaskCompletedDelegate`, and `HTTPNetworkTransportRetryDelegate`. Defaults to nil.
  public init(url: URL,
              session: URLSession = .shared,
              sendOperationIdentifiers: Bool = false,
              useGETForQueries: Bool = false,
              enableAutoPersistedQueries: Bool = false,
              useGETForPersistedQueryRetry: Bool = false,
              delegate: HTTPNetworkTransportDelegate? = nil,
              requestCreator: RequestCreator = ApolloRequestCreator()) {
    self.url = url
    self.session = session
    self.sendOperationIdentifiers = sendOperationIdentifiers
    self.useGETForQueries = useGETForQueries
    self.enableAutoPersistedQueries = enableAutoPersistedQueries
    self.useGETForPersistedQueryRetry = useGETForPersistedQueryRetry
    self.delegate = delegate
    self.requestCreator = requestCreator
  }
  
  private func send<Operation>(operation: Operation, isPersistedQueryRetry: Bool, files: [GraphQLFile]?, completionHandler: @escaping (_ results: Result<GraphQLResponse<Operation>, Error>) -> Void) -> Cancellable {
    let request: URLRequest
    do {
      request = try self.createRequest(for: operation,
                                       isPersistedQueryRetry: isPersistedQueryRetry,
                                       files: files)
    } catch {
      completionHandler(.failure(error))
      return EmptyCancellable()
    }
    
    let task = session.dataTask(with: request) { [weak self] data, response, error in
      guard let self = self else {
        // None of the rest of this really matters
        return
      }
      
      self.rawTaskCompleted(request: request,
                            data: data,
                            response: response,
                            error: error)
      
      if let receivedError = error {
        self.handleErrorOrRetry(operation: operation,
                                files: files,
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
                                files: files,
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
                                files: files,
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
        
        let graphQLResponse = GraphQLResponse(operation: operation, body: body)
        
        if let errors = graphQLResponse.parseErrorsOnlyFast() {
          // Handle specific errors from response
          self.handleGraphQLErrorsIfNeeded(operation: operation,
                                           files: files,
                                           for: request,
                                           body: body,
                                           errors: errors,
                                           completionHandler: completionHandler)
        } else {
          completionHandler(.success(graphQLResponse))
        }
      } catch let parsingError {
        self.handleErrorOrRetry(operation: operation,
                                files: files,
                                error: parsingError,
                                for: request,
                                response: response,
                                completionHandler: completionHandler)
      }
    }
    
    task.resume()
    
    return task
  }

  private func handleGraphQLErrorsOrComplete<Operation>(operation: Operation,
                                                        files: [GraphQLFile]?,
                                                        response: GraphQLResponse<Operation>,
                                                        completionHandler: @escaping (_ result: Result<GraphQLResponse<Operation>, Error>) -> Void) {
    guard
      let delegate = self.delegate as? HTTPNetworkTransportGraphQLErrorDelegate,
      let graphQLErrors = response.parseErrorsOnlyFast(),
      graphQLErrors.isNotEmpty else {
        completionHandler(.success(response))
        return
    }
    
    delegate.networkTransport(self, receivedGraphQLErrors: graphQLErrors, retryHandler: { [weak self] shouldRetry in
      guard let self = self else {
        // None of the rest of this really matters
        return
      }

      guard shouldRetry else {
        completionHandler(.success(response))
        return
      }
      
      _ = self.send(operation: operation,
                    isPersistedQueryRetry: self.enableAutoPersistedQueries,
                    files: files,
                    completionHandler: completionHandler)
    })
  }
  
  private func handleGraphQLErrorsIfNeeded<Operation>(operation: Operation,
                                                      files: [GraphQLFile]?,
                                                      for request: URLRequest,
                                                      body: JSONObject,
                                                      errors: [GraphQLError],
                                                      completionHandler: @escaping (_ results: Result<GraphQLResponse<Operation>, Error>) -> Void) {

    let errorMessages = errors.compactMap { $0.message }
    if self.enableAutoPersistedQueries,
      errorMessages.contains("PersistedQueryNotFound") {
      // We need to retry this with the full body.
      _ = self.send(operation: operation,
                    isPersistedQueryRetry: true,
                    files: nil,
                    completionHandler: completionHandler)
    } else {
      // Pass the response on to the rest of the chain
      let response = GraphQLResponse(operation: operation, body: body)
      handleGraphQLErrorsOrComplete(operation: operation, files: files, response: response, completionHandler: completionHandler)
    }
  }

  private func handleErrorOrRetry<Operation>(operation: Operation,
                                             files: [GraphQLFile]?,
                                             error: Error,
                                             for request: URLRequest,
                                             response: URLResponse?,
                                             completionHandler: @escaping (_ result: Result<GraphQLResponse<Operation>, Error>) -> Void) {    
    guard
      let delegate = self.delegate,
      let retrier = delegate as? HTTPNetworkTransportRetryDelegate else {
        completionHandler(.failure(error))
        return
    }
    
    retrier.networkTransport(
      self,
      receivedError: error,
      for: request,
      response: response,
      retryHandler: { [weak self] shouldRetry in
        guard let self = self else {
          // None of the rest of this really matters
          return
        }
        
        guard shouldRetry else {
          completionHandler(.failure(error))
          return
        }
        
        _ = self.send(operation: operation,
                      isPersistedQueryRetry: self.enableAutoPersistedQueries,
                      files: files,
                      completionHandler: completionHandler)
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
  
  private func createRequest<Operation: GraphQLOperation>(for operation: Operation, isPersistedQueryRetry: Bool, files: [GraphQLFile]?) throws -> URLRequest {
    let useGetMethod: Bool
    let sendQueryDocument: Bool
    let autoPersistQueries: Bool
    switch operation.operationType {
    case .query:
      if isPersistedQueryRetry {
        useGetMethod = self.useGETForPersistedQueryRetry
        sendQueryDocument = true
        autoPersistQueries = true
      } else {
        useGetMethod = self.useGETForQueries || (self.enableAutoPersistedQueries && self.useGETForPersistedQueryRetry)
        sendQueryDocument = !self.enableAutoPersistedQueries
        autoPersistQueries = self.enableAutoPersistedQueries
      }
    default:
      useGetMethod = false
      sendQueryDocument = true
      autoPersistQueries = false
    }
    
    return try self.createRequest(for: operation,
                                  files: files,
                                  httpMethod: useGetMethod ? .GET : .POST,
                                  sendQueryDocument: sendQueryDocument,
                                  autoPersistQueries: autoPersistQueries)
  }

  private func createRequest<Operation: GraphQLOperation>(for operation: Operation,
                                                          files: [GraphQLFile]?,
                                                          httpMethod: GraphQLHTTPMethod,
                                                          sendQueryDocument: Bool,
                                                          autoPersistQueries: Bool) throws -> URLRequest {
    let body = self.requestCreator.requestBody(for: operation,
                                               sendOperationIdentifiers: self.sendOperationIdentifiers,
                                               sendQueryDocument: sendQueryDocument,
                                               autoPersistQuery: autoPersistQueries)
    var request = URLRequest(url: self.url)
    request.setValue(self.clientName, forHTTPHeaderField: HTTPNetworkTransport.headerFieldNameClientName)
    request.setValue(self.clientVersion, forHTTPHeaderField: HTTPNetworkTransport.headerFieldNameClientVersion)
    
    // We default to json, but this can be changed below if needed.
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    switch httpMethod {
    case .GET:
      let transformer = GraphQLGETTransformer(body: body, url: self.url)
      if let urlForGet = transformer.createGetURL() {
        request = URLRequest(url: urlForGet)
        request.httpMethod = GraphQLHTTPMethod.GET.rawValue
      } else {
        throw GraphQLHTTPRequestError.serializedQueryParamsMessageError
      }
    case .POST:
      do {
        if
          let files = files,
          files.isNotEmpty {
            let formData = try requestCreator.requestMultipartFormData(
              for: operation,
              files: files,
              sendOperationIdentifiers: self.sendOperationIdentifiers,
              serializationFormat: self.serializationFormat,
              manualBoundary: nil)
            
            request.setValue("multipart/form-data; boundary=\(formData.boundary)", forHTTPHeaderField: "Content-Type")
            request.httpBody = try formData.encode()
        } else {
          request.httpBody = try serializationFormat.serialize(value: body)
        }
        
        request.httpMethod = GraphQLHTTPMethod.POST.rawValue
      } catch {
        throw GraphQLHTTPRequestError.serializedBodyMessageError
      }
    }
    
    request.setValue(operation.operationName, forHTTPHeaderField: "X-APOLLO-OPERATION-NAME")
    
    if let operationID = operation.operationIdentifier {
      request.setValue(operationID, forHTTPHeaderField: "X-APOLLO-OPERATION-ID")
    }
    
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
}

// MARK: - NetworkTransport conformance

extension HTTPNetworkTransport: NetworkTransport {
  
  public func send<Operation>(operation: Operation, completionHandler: @escaping (_ result: Result<GraphQLResponse<Operation>, Error>) -> Void) -> Cancellable {
    return send(operation: operation,
                isPersistedQueryRetry: false,
                files: nil,
                completionHandler: completionHandler)
  }
}

// MARK: - UploadingNetworkTransport conformance

extension HTTPNetworkTransport: UploadingNetworkTransport {
  
  public func upload<Operation>(operation: Operation, files: [GraphQLFile], completionHandler: @escaping (_ result: Result<GraphQLResponse<Operation>, Error>) -> Void) -> Cancellable {
    return send(operation: operation,
                isPersistedQueryRetry: false,
                files: files,
                completionHandler: completionHandler)
  }
}

// MARK: - Equatable conformance

extension HTTPNetworkTransport: Equatable {
  
  public static func ==(lhs: HTTPNetworkTransport, rhs: HTTPNetworkTransport) -> Bool {
    return lhs.url == rhs.url
      && lhs.session == rhs.session
      && lhs.sendOperationIdentifiers == rhs.sendOperationIdentifiers
      && lhs.useGETForQueries == rhs.useGETForQueries
  }
}
