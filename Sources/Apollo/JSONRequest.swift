import Foundation
#if !COCOAPODS
@_spi(Internal) import ApolloAPI
#endif

/// A request which sends JSON related to a GraphQL operation.
public struct JSONRequest<Operation: GraphQLOperation>: GraphQLRequest, AutoPersistedQueryCompatibleRequest, Hashable {

  /// The endpoint to make a GraphQL request to
  public var graphQLEndpoint: URL

  /// The GraphQL Operation to execute
  public var operation: Operation

  /// Any additional headers you wish to add to this request
  public var additionalHeaders: [String: String] = [:]

  /// The `FetchBehavior` to use for this request. Determines if fetching will include cache/network.
  public var fetchBehavior: FetchBehavior

  /// [optional] A context that is being passed through the request chain.
  public var context: (any RequestContext)?
  
  public let requestBodyCreator: any JSONRequestBodyCreator

  public var apqConfig: AutoPersistedQueryConfiguration

  public var isPersistedQueryRetry: Bool = false

  /// Set to  `true` if you want to use `GET` instead of `POST` for queries.
  ///
  /// This can improve performance if your GraphQL server uses a CDN (Content Delivery Network)
  /// to cache the results of queries that rarely change.
  ///
  /// Mutation operations always use POST, even when this is `false`
  public let useGETForQueries: Bool

  /// The telemetry metadata about the client. This is used by GraphOS Studio's
  /// [client awareness](https://www.apollographql.com/docs/graphos/platform/insights/client-segmentation)
  /// feature.
  public var clientAwarenessMetadata: ClientAwarenessMetadata

  /// Designated initializer
  ///
  /// - Parameters:
  ///   - operation: The GraphQL Operation to execute
  ///   - graphQLEndpoint: The endpoint to make a GraphQL request to
  ///   - clientName: The name of the client to send with the `"apollographql-client-name"` header
  ///   - clientVersion:  The version of the client to send with the `"apollographql-client-version"` header
  ///   - cachePolicy: The `CachePolicy` to use for this request.
  ///   - context: [optional] A context that is being passed through the request chain. Defaults to `nil`.
  ///   - apqConfig: A configuration struct used by a `GraphQLRequest` to configure the usage of
  ///   [Automatic Persisted Queries (APQs).](https://www.apollographql.com/docs/apollo-server/performance/apq) By default, APQs
  ///   are disabled.
  ///   - useGETForQueries: `true` if Queries should use `GET` instead of `POST` for HTTP requests. Defaults to `false`.
  ///   - requestBodyCreator: An object conforming to the `JSONRequestBodyCreator` protocol to assist with creating the request body. Defaults to the provided `DefaultRequestBodyCreator` implementation.
  public init(
    operation: Operation,
    graphQLEndpoint: URL,
    fetchBehavior: FetchBehavior,
    context: (any RequestContext)? = nil,
    apqConfig: AutoPersistedQueryConfiguration = .init(),
    useGETForQueries: Bool = false,
    requestBodyCreator: any JSONRequestBodyCreator = DefaultRequestBodyCreator(),
    clientAwarenessMetadata: ClientAwarenessMetadata = ClientAwarenessMetadata()
  ) {
    self.operation = operation
    self.graphQLEndpoint = graphQLEndpoint
    self.fetchBehavior = fetchBehavior
    self.context = context
    self.requestBodyCreator = requestBodyCreator

    self.apqConfig = apqConfig
    self.useGETForQueries = useGETForQueries
    self.clientAwarenessMetadata = clientAwarenessMetadata

    self.setupDefaultHeaders()
  }

  private mutating func setupDefaultHeaders() {
    self.addHeader(name: "Content-Type", value: "application/json")    

    if Operation.operationType == .subscription {
      self.addHeader(
        name: "Accept",
        value: "multipart/mixed;\(MultipartResponseSubscriptionParser.protocolSpec),application/graphql-response+json,application/json"
      )

    } else {
      self.addHeader(
        name: "Accept",
        value: "multipart/mixed;\(MultipartResponseDeferParser.protocolSpec),application/graphql-response+json,application/json"
      )
    }
  }

  public func toURLRequest() throws -> URLRequest {
    var request = createDefaultRequest()

    let useGetMethod: Bool
    let body = self.createBody()

    switch Operation.operationType {
    case .query:
      if isPersistedQueryRetry {
        useGetMethod = self.apqConfig.useGETForPersistedQueryRetry
      } else {
        useGetMethod = self.useGETForQueries ||
        (self.apqConfig.autoPersistQueries && self.apqConfig.useGETForPersistedQueryRetry)
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
        request.httpBody = try JSONSerializationFormat.serialize(value: body)
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
        sendQueryDocument = !self.apqConfig.autoPersistQueries
        autoPersistQueries = self.apqConfig.autoPersistQueries
      }
    case .mutation:
      if isPersistedQueryRetry {
        sendQueryDocument = true
        autoPersistQueries = true
      } else {
        sendQueryDocument = !self.apqConfig.autoPersistQueries
        autoPersistQueries = self.apqConfig.autoPersistQueries
      }
    default:
      sendQueryDocument = true
      autoPersistQueries = false
    }
    
    let body = self.requestBodyCreator.requestBody(
      for: self,
      sendQueryDocument: sendQueryDocument,
      autoPersistQuery: autoPersistQueries
    )    

    return body
  }

  /// Convert the Apollo iOS cache policy into a matching cache policy for URLRequest.
  private var requestCachePolicy: URLRequest.CachePolicy {
    if !fetchBehavior.shouldAttemptCacheRead {
      if fetchBehavior.shouldAttemptCacheWrite {
        return .reloadIgnoringLocalCacheData
      } else {
        return .reloadIgnoringLocalAndRemoteCacheData
      }
    } else {
      switch fetchBehavior.shouldAttemptNetworkFetch {
      case .always:
        return .reloadRevalidatingCacheData
      case .never:
        return .returnCacheDataDontLoad
      case .onCacheFailure:
        return .useProtocolCachePolicy
      }
    }
  }

  // MARK: - Equtable/Hashable Conformance

  public static func == (
    lhs: JSONRequest<Operation>,
    rhs: JSONRequest<Operation>
  ) -> Bool {
    lhs.graphQLEndpoint == rhs.graphQLEndpoint &&
    lhs.operation == rhs.operation &&
    lhs.additionalHeaders == rhs.additionalHeaders &&
    lhs.fetchBehavior == rhs.fetchBehavior &&
    lhs.apqConfig == rhs.apqConfig &&
    lhs.isPersistedQueryRetry == rhs.isPersistedQueryRetry &&
    lhs.useGETForQueries == rhs.useGETForQueries &&
    type(of: lhs.requestBodyCreator) == type(of: rhs.requestBodyCreator)
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(graphQLEndpoint)
    hasher.combine(operation)
    hasher.combine(additionalHeaders)
    hasher.combine(fetchBehavior)
    hasher.combine(apqConfig)
    hasher.combine(isPersistedQueryRetry)
    hasher.combine(useGETForQueries)
    hasher.combine("\(type(of: requestBodyCreator))")
  }

}

extension JSONRequest: CustomDebugStringConvertible {
  public var debugDescription: String {
    var debugStrings = [String]()
    debugStrings.append("HTTPRequest details:")
    debugStrings.append("Endpoint: \(self.graphQLEndpoint)")
    debugStrings.append("Additional Headers: [")
    for (key, value) in self.additionalHeaders {
      debugStrings.append("\t\(key): \(value),")
    }
    debugStrings.append("]")
    debugStrings.append("Fetch Behavior: \(self.fetchBehavior)")
    debugStrings.append("Operation: \(self.operation)")
    return debugStrings.joined(separator: "\n\t")
  }
}
