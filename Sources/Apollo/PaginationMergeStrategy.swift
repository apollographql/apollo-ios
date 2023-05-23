#if !COCOAPODS
import ApolloAPI
#endif

/// The strategy by which a `GraphQLPaginatedQueryWatcher` operates
public protocol PaginationStrategy {
  /// The `Query` associated with such a strategy
  associatedtype Query: GraphQLQuery
  /// The expected output of the strategy
  associatedtype Output: Hashable

  /// Transforms a new `Query.Data` result into a results tuple.
  /// - Parameter data: input data from the underlying `GraphQLQueryWatcher`
  /// - Returns: A tuple which contains the expected `Output` value of this strategy as well as the `Page` that this `Output` is tied to.
  func transform(data: Query.Data) -> (Output?, Page?)?

  /// How the strategy goes about combining the results of many watchers.
  /// - Parameter response: Contains all page results, the page that triggered the update, as well as the source of the update
  /// - Returns: The finalized `Output` to be returned to the user via the `resultHandler`.
  func mergePageResults(response: PaginationDataResponse<Query, Output>) -> Output

  /// The callback by which the user handles the result of the `GraphQLPaginatedQueryWatcher`.
  /// - Parameters:
  ///   - result: The transformed and merged result of the `GraphQLPaginatedQueryWatcher`.
  ///   - source: Whether that result came from the cache or the network.
  func resultHandler(result: Result<Output, Error>, source: GraphQLResult<Query.Data>.Source?)
}
