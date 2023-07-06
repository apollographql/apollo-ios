#if !COCOAPODS
import ApolloAPI
#endif
import Foundation

/// A pagination strategy to be used withoffset-style cursor based pagination.
public class OffsetPaginationStrategy<
  Query: GraphQLQuery,
  Output: Hashable,
  NextPageConstructor: NextPageStrategy,
  OutputTransformer: DataTransformer,
  MergeStrategy: PaginationMergeStrategy
>: PaginationStrategy
where MergeStrategy.Output == OutputTransformer.Output,
      OutputTransformer.Output == Output,
      MergeStrategy.Query == OutputTransformer.Query,
      OutputTransformer.Query == Query,
      NextPageConstructor.Page == OffsetPageExtractor<Query>.Page,
      NextPageConstructor.Query == Query {
  public typealias PageInput = OffsetPageExtractor<Query>.Input
  public typealias Page = OffsetPageExtractor<Query>.Page

  public var pageExtractionStrategy: OffsetPageExtractor<Query>
  public var outputTransformer: OutputTransformer
  public var nextPageStrategy: NextPageConstructor
  public var mergeStrategy: MergeStrategy

  public var _resultHandler: (Result<PaginatedOutput<Query, MergeStrategy.Output>, Error>) -> Void

  public private(set) var pages: [Page?] = [nil]
  public private(set) var currentPage: Page?
  private var modelMap: [Page?: Output] = [:]
  private var mostRecentModel: Output?
  private let pageSize: Int

  public init(
    pageSize: Int,
    pageExtractionStrategy: OffsetPageExtractor<Query>,
    outputTransformer: OutputTransformer,
    nextPageStrategy: NextPageConstructor,
    mergeStrategy: MergeStrategy,
    resultHandler: @escaping (Result<PaginatedOutput<Query, MergeStrategy.Output>, Error>) -> Void
  ) {
    self.pageSize = pageSize
    self.pageExtractionStrategy = pageExtractionStrategy
    self.outputTransformer = outputTransformer
    self.nextPageStrategy = nextPageStrategy
    self.mergeStrategy = mergeStrategy
    self._resultHandler = resultHandler
  }

  public func onWatchResult(result: Result<GraphQLResult<Query.Data>, Error>) {
    switch result {
    case .failure(let error):
      guard !error.wasCancelled else { return }
      resultHandler(result: .failure(error))
    case .success(let graphQLResult):
      guard let data = graphQLResult.data,
            let transformedModel = transformResult(input: data)
      else { return }
      let page = extractPage(input: .init(data: data, offset: pages.last??.offset ?? 0, pageSize: pageSize))
      modelMap[page] = transformedModel
      let model = mergeStrategy.mergePageResults(paginationResponse: .init(
        allResponses: pages.compactMap { [weak self] page in
          self?.modelMap[page]
        },
        mostRecent: transformedModel,
        source: graphQLResult.source
      ))

      guard model != self.mostRecentModel else { return }
      resultHandler(result: .success(.init(
        value: model,
        errors: graphQLResult.errors,
        source: graphQLResult.source
      )))
      self.mostRecentModel = model
    }
  }

  public func canFetchNextPage() -> Bool {
    currentPage?.hasNextPage ?? false
  }

  public func reset() {
    pages = [nil]
    currentPage = nil
    modelMap = [:]
    mostRecentModel = nil
  }

  func resultHandler(
    result: Result<PaginatedOutput<Query, MergeStrategy.Output>, Error>
  ) {
    _resultHandler(result)
  }

  func mergePageResults(response: PaginationDataResponse<Query, Output>) -> Output {
    mergeStrategy.mergePageResults(paginationResponse: response)
  }

  func extractPage(input: PageInput) -> Page {
    let page = pageExtractionStrategy.transform(input: input)
    if let index = self.pages.firstIndex(of: page) {
      self.pages[index] = page
    } else {
      self.currentPage = page
      self.pages.append(page)
    }
    return page
  }

  func transformResult(input: Query.Data) -> Output? {
    outputTransformer.transform(data: input)
  }
}

private extension Error {
  var wasCancelled: Bool {
    if let apolloError = self as? URLSessionClient.URLSessionClientError,
       case let .networkError(data: _, response: _, underlying: underlying) = apolloError {
      return underlying.wasCancelled
    }

    return (self as NSError).code == NSURLErrorCancelled
  }
}
