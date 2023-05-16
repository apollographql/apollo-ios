import ApolloAPI

enum PaginationMergeStrategy<Query: GraphQLQuery, T> {
//  case simple(SimplePaginationStrategy<Query, T>)
  case custom(CustomPaginationStrategy<Query, T>)

  func transform(data: Query.Data) -> (T?, Page?)? {
    switch self {
    case .custom(let strategy):
      return strategy.transform(data)
    }
  }

  func mergePageResults(response: PaginationDataResponse<Query, T>) -> T {
    switch self {
    case .custom(let strategy):
      return strategy.mergePageResults(response)
    }
  }

  func resultHandler(result: Result<T, Error>) -> Void {
    switch self {
    case .custom(let strategy):
      return strategy.resultHandler(result)
    }
  }
}

public struct PaginationDataResponse<Query: GraphQLQuery, T> {
  let allResponses: [T]
  let mostRecent: T
  let source: GraphQLResult<Query.Data>.Source
}

final class CustomPaginationStrategy<Query: GraphQLQuery, T> {
  var transform: (Query.Data) -> (T?, Page?)?
  var mergePageResults: (PaginationDataResponse<Query, T>) -> T
  var resultHandler: (Result<T, Error>) -> Void

  init(
    transform: @escaping (Query.Data) -> (T?, Page?)?,
    mergePageResults: @escaping (PaginationDataResponse<Query, T>) -> T,
    resultHandler: @escaping (Result<T, Error>) -> Void
  ) {
    self.transform = transform
    self.mergePageResults = mergePageResults
    self.resultHandler = resultHandler
  }
}
