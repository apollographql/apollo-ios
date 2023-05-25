#if !COCOAPODS
import ApolloAPI
#endif

/// The strategy by which several responses of a paginated query are merged into one `Output`.
public protocol PaginationMergeStrategy {
  associatedtype Query: GraphQLQuery
  associatedtype Output: Hashable

  /// The function by which we merge several responses, in the form of a `PaginationDataResponse` into one `Output`.
  /// - Parameter paginationResponse: A data type which contains the most recent response, the source of that response, and all other responses.
  /// - Returns: `Output`
  func mergePageResults(paginationResponse: PaginationDataResponse<Query, Output>) -> Output
}
