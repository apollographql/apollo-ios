import Foundation
#if !COCOAPODS
import ApolloMigrationAPI
#endif

/// A request which sends JSON related to a GraphQL operation.
open class JSONRequest<Operation: GraphQLOperation>: HTTPRequest<Operation> {
  
  public let requestBodyCreator: any RequestBodyCreator
  
  public let autoPersistQueries: Bool
  public let useGETForQueries: Bool
  public let useGETForPersistedQueryRetry: Bool
  public var isPersistedQueryRetry = false {
    didSet {
      _body = nil
    }
  }

  private var _body: JSONEncodableDictionary?
  public var body: JSONEncodableDictionary {
      if _body == nil {
        _body = createBody()
      }
      return _body!
  }
  
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
  ///   - context: [optional] A context that is being passed through the request chain. Defaults to `nil`.
  ///   - autoPersistQueries: `true` if Auto-Persisted Queries should be used. Defaults to `false`.
  ///   - useGETForQueries: `true` if Queries should use `GET` instead of `POST` for HTTP requests. Defaults to `false`.
  ///   - useGETForPersistedQueryRetry: `true` if when an Auto-Persisted query is retried, it should use `GET` instead of `POST` to send the query. Defaults to `false`.
  ///   - requestBodyCreator: An object conforming to the `RequestBodyCreator` protocol to assist with creating the request body. Defaults to the provided `ApolloRequestBodyCreator` implementation.
  public init(
    operation: Operation,
    graphQLEndpoint: URL,
    contextIdentifier: UUID? = nil,
    clientName: String,
    clientVersion: String,
    additionalHeaders: [String: String] = [:],
    cachePolicy: CachePolicy = .default,
    context: (any RequestContext)? = nil,
    autoPersistQueries: Bool = false,
    useGETForQueries: Bool = false,
    useGETForPersistedQueryRetry: Bool = false,
    requestBodyCreator: any RequestBodyCreator = ApolloRequestBodyCreator()
  ) {
    self.autoPersistQueries = autoPersistQueries
    self.useGETForQueries = useGETForQueries
    self.useGETForPersistedQueryRetry = useGETForPersistedQueryRetry
    self.requestBodyCreator = requestBodyCreator

    super.init(
      graphQLEndpoint: graphQLEndpoint,
      operation: operation,
      contextIdentifier: contextIdentifier,
      contentType: "application/json",
      clientName: clientName,
      clientVersion: clientVersion,
      additionalHeaders: additionalHeaders,
      cachePolicy: cachePolicy,
      context: context
    )
  }

  open override func toURLRequest() throws -> URLRequest {
    var request = try super.toURLRequest()
    let useGetMethod: Bool
    let body = self.body
    
    switch Operation.operationType {
    case .query:
      if isPersistedQueryRetry {
        useGetMethod = self.useGETForPersistedQueryRetry
      } else {
        useGetMethod = self.useGETForQueries || (self.autoPersistQueries && self.useGETForPersistedQueryRetry)
      }
    default:
      useGetMethod = false
    }
    
    let httpMethod: GraphQLHTTPMethod = useGetMethod ? .GET : .POST
    
    switch httpMethod {
    case .GET:
      let transformer = GraphQLGETTransformer(body: body, url: self.graphQLEndpoint)
      if let urlForGet = transformer.createGetURL() {
        request.url = urlForGet
        request.httpMethod = GraphQLHTTPMethod.GET.rawValue
        request.cachePolicy = requestCachePolicy

        // GET requests shouldn't have a content-type since they do not provide actual content.
        request.allHTTPHeaderFields?.removeValue(forKey: "Content-Type")
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

  private func createBody() -> JSONEncodableDictionary {
    let sendQueryDocument: Bool
    let autoPersistQueries: Bool
    switch Operation.operationType {
    case .query:
      if isPersistedQueryRetry {
        sendQueryDocument = true
        autoPersistQueries = true
      } else {
        sendQueryDocument = !self.autoPersistQueries
        autoPersistQueries = self.autoPersistQueries
      }
    case .mutation:
      if isPersistedQueryRetry {
        sendQueryDocument = true
        autoPersistQueries = true
      } else {
        sendQueryDocument = !self.autoPersistQueries
        autoPersistQueries = self.autoPersistQueries
      }
    default:
      sendQueryDocument = true
      autoPersistQueries = false
    }
    
    let body = self.requestBodyCreator.requestBody(
      for: operation,
      sendQueryDocument: sendQueryDocument,
      autoPersistQuery: autoPersistQueries
    )
    
    return body
  }

  /// Convert the Apollo iOS cache policy into a matching cache policy for URLRequest.
  private var requestCachePolicy: URLRequest.CachePolicy {
    switch cachePolicy {
    case .returnCacheDataElseFetch:
      return .useProtocolCachePolicy
    case .fetchIgnoringCacheData:
      return .reloadIgnoringLocalCacheData
    case .fetchIgnoringCacheCompletely:
      return .reloadIgnoringLocalAndRemoteCacheData
    case .returnCacheDataDontFetch:
      return .returnCacheDataDontLoad
    case .returnCacheDataAndFetch:
      return .reloadRevalidatingCacheData
    }
  }

  // MARK: - Equtable/Hashable Conformance

  public static func == (lhs: JSONRequest<Operation>, rhs: JSONRequest<Operation>) -> Bool {
    lhs as HTTPRequest<Operation> == rhs as HTTPRequest<Operation> &&
    type(of: lhs.requestBodyCreator) == type(of: rhs.requestBodyCreator) &&
    lhs.autoPersistQueries == rhs.autoPersistQueries &&
    lhs.useGETForQueries == rhs.useGETForQueries &&
    lhs.useGETForPersistedQueryRetry == rhs.useGETForPersistedQueryRetry &&
    lhs.isPersistedQueryRetry == rhs.isPersistedQueryRetry &&
    lhs.body._jsonObject == rhs.body._jsonObject
  }

  public override func hash(into hasher: inout Hasher) {
    super.hash(into: &hasher)
    hasher.combine("\(type(of: requestBodyCreator))")
    hasher.combine(autoPersistQueries)
    hasher.combine(useGETForQueries)
    hasher.combine(useGETForPersistedQueryRetry)
    hasher.combine(isPersistedQueryRetry)
    hasher.combine(body._jsonObject)
  }

}
