/// A configuration struct used by a `GraphQLRequest` to configure the usage of
/// [Automatic Persisted Queries (APQs).](https://www.apollographql.com/docs/apollo-server/performance/apq)
///
/// APQs are a feature of Apollo Server and the Apollo GraphOS Router.
/// When using Apollo iOS to connect to any other GraphQL server, setting `autoPersistQueries` to
///  `true` will result in unintended network errors.
public struct AutoPersistedQueryConfiguration: Sendable, Hashable {
  /// Indicates if Auto Persisted Queries should be used for the request. Defaults to `false`.
  public var autoPersistQueries: Bool

  /// `true` if when an Auto Persisted query is retried, it should use `GET` instead of `POST` to
  /// send the query. Defaults to `false`.
  public var useGETForPersistedQueryRetry: Bool

  /// - Parameters:
  ///   - autoPersistQueries: `true` if Auto Persisted Queries should be used. Defaults to `false`.
  ///   - useGETForPersistedQueryRetry: `true` if when an Auto-Persisted query is retried, it should use `GET`
  ///   instead of `POST` to send the query. Defaults to `false`.
  public init(
    autoPersistQueries: Bool = false,
    useGETForPersistedQueryRetry: Bool = false
  ) {
    self.autoPersistQueries = autoPersistQueries
    self.useGETForPersistedQueryRetry = useGETForPersistedQueryRetry
  }
}

public protocol AutoPersistedQueryCompatibleRequest: GraphQLRequest {

  /// A configuration struct used by a `GraphQLRequest` to configure the usage of
  /// [Automatic Persisted Queries (APQs).](https://www.apollographql.com/docs/apollo-server/performance/apq)
  /// By default, APQs are disabled.
  var apqConfig: AutoPersistedQueryConfiguration { get set }

  /// Flag used to track the state of the Auto Persisted Query request. Should default to `false`.
  ///
  /// If the request containing this config has already received a network response indicating that
  /// the persisted query id was not recognized, the `AutomaticPersistedQueryInterceptor` will set
  /// this to `true` and then invoke a retry of the request.
  ///
  /// If this is set to `false`, the requests should include only the persisted query operation
  /// identifier. If `true`, the request should also include the query body to register with the
  /// server as a persisted query.
  var isPersistedQueryRetry: Bool { get set}
}
