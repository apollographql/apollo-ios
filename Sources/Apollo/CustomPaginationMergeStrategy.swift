#if !COCOAPODS
import ApolloAPI
#endif

/// A `PaginationMergeStrategy` which gives the caller fine-grain control over how to merge data together.
public class CustomPaginationMergeStrategy<Query: GraphQLQuery, Output: Hashable>: PaginationMergeStrategy {

  let _transform: (PaginationDataResponse<Query, Output>) -> Output

  /// Designated initializer
  /// - Parameter transform: a user-defined function which can transform a `PaginationDataResponse` into an `Output`.
  public init(transform: @escaping (PaginationDataResponse<Query, Output>) -> Output) {
    self._transform = transform
  }

  /// The function by which we merge several responses, in the form of a `PaginationDataResponse` into one `Output`.
  /// - Parameter paginationResponse: A data type which contains the most recent response, the source of that response, and all other responses.
  /// - Returns: `Output`
  public func mergePageResults(paginationResponse: PaginationDataResponse<Query, Output>) -> Output {
    _transform(paginationResponse)
  }
}
