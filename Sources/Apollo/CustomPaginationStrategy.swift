#if !COCOAPODS
import ApolloAPI
#endif

/// A custom pagination strategy that allows the caller to paginate using their own output model and gives fine-grain control over how page results are merged together.
public final class CustomPaginationStrategy<Query: GraphQLQuery, T: Hashable>: PaginationStrategy {
  private var _transform: (Query.Data) -> (T?, Page?)?
  private var _mergePageResults: (PaginationDataResponse<Query, T>) -> T
  private var _resultHandler: (Result<T, Error>, GraphQLResult<Query.Data>.Source?) -> Void

  /// Designated Initializer
  /// - Parameters:
  ///   - transform: A user supplied function which can transform a given watch result into an output of any type, and a page.
  ///   - mergePageResults: A user supplied function which merges many results into a concrete output.
  ///   - resultHandler: A user supplied function which responds to the final output of the watcher.
  public init(
    transform: @escaping (Query.Data) -> (T?, Page?)?,
    mergePageResults: @escaping (PaginationDataResponse<Query, T>) -> T,
    resultHandler: @escaping (Result<T, Error>, GraphQLResult<Query.Data>.Source?) -> Void
  ) {
    self._transform = transform
    self._mergePageResults = mergePageResults
    self._resultHandler = resultHandler
  }

  /// Transforms a new `Query.Data` result into a results tuple.
  /// - Parameter data: input data from the underlying `GraphQLQueryWatcher`
  /// - Returns: A tuple which contains the expected `Output` value of this strategy as well as the `Page` that this `Output` is tied to.
  public func transform(data: Query.Data) -> (T?, Page?)? {
    _transform(data)
  }

  /// How the strategy goes about combining the results of many watchers.
  /// - Parameter response: Contains all page results, the page that triggered the update, as well as the source of the update
  /// - Returns: The finalized `Output` to be returned to the user via the `resultHandler`.
  public func mergePageResults(response: PaginationDataResponse<Query, T>) -> T {
    _mergePageResults(response)
  }

  /// The callback by which the user handles the result of the `GraphQLPaginatedQueryWatcher`.
  /// - Parameters:
  ///   - result: The transformed and merged result of the `GraphQLPaginatedQueryWatcher`.
  ///   - source: Whether that result came from the cache or the network.
  public func resultHandler(result: Result<T, Error>, source: GraphQLResult<Query.Data>.Source?) {
    _resultHandler(result, source)
  }
}
