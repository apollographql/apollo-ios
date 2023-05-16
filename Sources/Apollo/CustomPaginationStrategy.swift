import ApolloAPI

/// A custom pagination strategy that allows the caller to paginate using their own output model and gives fine-grain control over how page results are merged together.
public final class CustomPaginationStrategy<Query: GraphQLQuery, T>: PaginationStrategy {
  private var _transform: (Query.Data) -> (T?, Page?)?
  private var _mergePageResults: (PaginationDataResponse<Query, T>) -> T
  private var _resultHandler: (Result<T, Error>) -> Void


  /// Designated Initializer
  /// - Parameters:
  ///   - transform: A user supplied function which can transform a given watch result into an output of any type, and a page.
  ///   - mergePageResults: A user supplied function which merges many results into a concrete output.
  ///   - resultHandler: A user supplied function which responds to the final output of the watcher.
  public init(
    transform: @escaping (Query.Data) -> (T?, Page?)?,
    mergePageResults: @escaping (PaginationDataResponse<Query, T>) -> T,
    resultHandler: @escaping (Result<T, Error>) -> Void
  ) {
    self._transform = transform
    self._mergePageResults = mergePageResults
    self._resultHandler = resultHandler
  }

  public func transform(data: Query.Data) -> (T?, Page?)? {
    _transform(data)
  }

  public func mergePageResults(response: PaginationDataResponse<Query, T>) -> T {
    _mergePageResults(response)
  }

  public func resultHandler(result: Result<T, Error>) {
    _resultHandler(result)
  }
}
