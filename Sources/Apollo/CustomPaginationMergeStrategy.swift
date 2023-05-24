#if !COCOAPODS
import ApolloAPI
#endif

public class CustomPaginationMergeStrategy<Query: GraphQLQuery, Output: Hashable>: PaginationMergeStrategy {

  let _transform: (PaginationDataResponse<Query, Output>) -> Output

  public init(transform: @escaping (PaginationDataResponse<Query, Output>) -> Output) {
    self._transform = transform
  }

  public func mergePageResults(paginationResponse: PaginationDataResponse<Query, Output>) -> Output {
    _transform(paginationResponse)
  }
}
