import Foundation

/// A request which sends JSON related to a GraphQL operation.
open class JSONRequest<Operation: GraphQLOperation>: HTTPRequest<Operation> {
  
  public let requestBodyCreator: RequestBodyCreator
  
  public let autoPersistQueries: Bool
  public let useGETForQueries: Bool
  public let useGETForPersistedQueryRetry: Bool
  public var isPersistedQueryRetry = false
  
  public let serializationFormat = JSONSerializationFormat.self
  
  /// Designated initializer
  /// 
  /// - Parameters:
  ///   - operation: The GraphQL Operation to execute
  ///   - graphQLEndpoint: The endpoint to make a GraphQL request to
  ///   - contextIdentifier:  [optional] A unique identifier for this request, to help with deduping cache hits for watchers. Defaults to `nil`.
  ///   - clientName: The name of the client to send with the `"apollographql-client-name"` header
  ///   - clientVersion:  The version of the client to send with the `"apollographql-client-version"` header
  ///   - additionalHeaders: Any additional headers you wish to add by default to this request
  ///   - cachePolicy: The `CachePolicy` to use for this request.
  ///   - autoPersistQueries: `true` if Auto-Persisted Queries should be used. Defaults to `false`.
  ///   - useGETForQueries: `true` if Queries should use `GET` instead of `POST` for HTTP requests. Defaults to `false`.
  ///   - useGETForPersistedQueryRetry: `true` if when an Auto-Persisted query is retried, it should use `GET` instead of `POST` to send the query. Defaults to `false`.
  ///   - requestBodyCreator: An object conforming to the `RequestBodyCreator` protocol to assist with creating the request body. Defaults to the provided `ApolloRequestBodyCreator` implementation.
  public init(operation: Operation,
              graphQLEndpoint: URL,
              contextIdentifier: UUID? = nil,
              clientName: String,
              clientVersion: String,
              additionalHeaders: [String: String] = [:],
              cachePolicy: CachePolicy = .default,
              autoPersistQueries: Bool = false,
              useGETForQueries: Bool = false,
              useGETForPersistedQueryRetry: Bool = false,
              requestBodyCreator: RequestBodyCreator = ApolloRequestBodyCreator()) {
    self.autoPersistQueries = autoPersistQueries
    self.useGETForQueries = useGETForQueries
    self.useGETForPersistedQueryRetry = useGETForPersistedQueryRetry
    self.requestBodyCreator = requestBodyCreator
    
    super.init(graphQLEndpoint: graphQLEndpoint,
               operation: operation,
               contextIdentifier: contextIdentifier,
               contentType: "application/json",
               clientName: clientName,
               clientVersion: clientVersion,
               additionalHeaders: additionalHeaders,
               cachePolicy: cachePolicy)
  }
  
  open var sendOperationIdentifier: Bool {
    self.operation.operationIdentifier != nil
  }
  
  open override func toURLRequest() throws -> URLRequest {
    var request = try super.toURLRequest()
        
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
        useGetMethod = self.useGETForQueries || (self.autoPersistQueries && self.useGETForPersistedQueryRetry)
        sendQueryDocument = !self.autoPersistQueries
        autoPersistQueries = self.autoPersistQueries
      }
    case .mutation:
      useGetMethod = false
      if isPersistedQueryRetry {
        sendQueryDocument = true
        autoPersistQueries = true
      } else {
        sendQueryDocument = !self.autoPersistQueries
        autoPersistQueries = self.autoPersistQueries
      }
    default:
      useGetMethod = false
      sendQueryDocument = true
      autoPersistQueries = false
    }
    
    let body = self.requestBodyCreator.requestBody(for: operation,
                                               sendOperationIdentifiers: self.sendOperationIdentifier,
                                               sendQueryDocument: sendQueryDocument,
                                               autoPersistQuery: autoPersistQueries)
    
    let httpMethod: GraphQLHTTPMethod = useGetMethod ? .GET : .POST
    switch httpMethod {
    case .GET:
      let transformer = GraphQLGETTransformer(body: body, url: self.graphQLEndpoint)
      if let urlForGet = transformer.createGetURL() {
        request.url = urlForGet
        request.httpMethod = GraphQLHTTPMethod.GET.rawValue
      } else {
        throw GraphQLHTTPRequestError.serializedQueryParamsMessageError
      }
    case .POST:
      do {
        request.httpBody = try serializationFormat.serialize(value: body)
        request.httpMethod = GraphQLHTTPMethod.POST.rawValue
      } catch {
        throw GraphQLHTTPRequestError.serializedBodyMessageError
      }
    }
    
    return request
  }
}
