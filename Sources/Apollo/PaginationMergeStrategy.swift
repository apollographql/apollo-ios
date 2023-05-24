#if !COCOAPODS
import ApolloAPI
#endif

public protocol PaginationMergeStrategy {
  associatedtype Query: GraphQLQuery
  associatedtype Output: Hashable
  func mergePageResults(paginationResponse: PaginationDataResponse<Query, Output>) -> Output
}
