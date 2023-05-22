#if !COCOAPODS
import ApolloAPI
#endif

public class AnyPaginationStrategy<Query: GraphQLQuery, Output: Hashable>: PaginationStrategy {
  private let _transform: (Query.Data) -> (Output?, Page?)?
  private let _mergePageResults: (PaginationDataResponse<Query, Output>) -> Output
  private let _resultHandler: (Result<Output, Error>, GraphQLResult<Query.Data>.Source?) -> Void

  public init<S: PaginationStrategy>(strategy: S) where S.Query == Query, S.Output == Output {
    self._transform = { data in strategy.transform(data: data) }
    self._mergePageResults = { response in strategy.mergePageResults(response: response) }
    self._resultHandler = { result, source in strategy.resultHandler(result: result, source: source) }
  }

  public func transform(data: Query.Data) -> (Output?, Page?)? {
    _transform(data)
  }

  public func mergePageResults(response: PaginationDataResponse<Query, Output>) -> Output {
    _mergePageResults(response)
  }

  public func resultHandler(result: Result<Output, Error>, source: GraphQLResult<Query.Data>.Source?) {
    _resultHandler(result, source)
  }
}

public extension PaginationStrategy {
  func eraseToAnyStrategy() -> AnyPaginationStrategy<Query, Output> {
    .init(strategy: self)
  }
}
