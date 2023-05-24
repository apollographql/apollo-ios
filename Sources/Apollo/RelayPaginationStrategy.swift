#if !COCOAPODS
import ApolloAPI
#endif

public class RelayPaginationStrategy<
  Query: GraphQLQuery,
  Output: Hashable,
  OutputTransformer: DataTransformer,
  MergeStrategy: PaginationMergeStrategy
>: PaginationStrategy
where MergeStrategy.Output == OutputTransformer.Output,
      OutputTransformer.Output == Output,
      MergeStrategy.Query == OutputTransformer.Query,
      OutputTransformer.Query == Query {
  public typealias PageInput = Query.Data
  public typealias Page = PageExtractor.Page

  public var pageExtractionStrategy: RelayPageExtractor<Query>
  public var outputTransformer: OutputTransformer
  public var nextPageStrategy: CustomNextPageStrategy<RelayPageExtractor<Query>.Page, Query>
  public var mergeStrategy: MergeStrategy

  var _resultHandler: (Result<MergeStrategy.Output, Error>, GraphQLResult<Query.Data>.Source?) -> Void

  public private(set) var pages: [Page?] = [nil]
  public private(set) var currentPage: Page?
  private var modelMap: [Page?: Output] = [:]
  private var mostRecentModel: Output?

  public init(
    pageExtractionStrategy: RelayPageExtractor<Query>,
    outputTransformer: OutputTransformer,
    nextPageStrategy: CustomNextPageStrategy<RelayPageExtractor<Query>.Page, Query>,
    mergeStrategy: MergeStrategy,
    resultHandler: @escaping (Result<Output, Error>, GraphQLResult<Query.Data>.Source?) -> Void
  ) {
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
      resultHandler(result: .failure(error), source: nil)
    case .success(let graphQLResult):
      guard let data = graphQLResult.data,
            let transformedModel = transformResult(input: data)
      else { return }
      let page = extractPage(input: data)
      modelMap[currentPage] = transformedModel
      let model = mergeStrategy.mergePageResults(paginationResponse: .init(
        allResponses: pages.compactMap { [weak self] page in
          self?.modelMap[page]
        },
        mostRecent: transformedModel,
        source: graphQLResult.source
      ))

      guard model != self.mostRecentModel else { return }
      resultHandler(result: .success(model), source: graphQLResult.source)
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
    result: Result<Output, Error>,
    source: GraphQLResult<Query.Data>.Source?
  ) {
    _resultHandler(result, source)
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
