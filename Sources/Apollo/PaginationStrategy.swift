#if !COCOAPODS
import ApolloAPI
#endif

public protocol PaginationStrategy {
  associatedtype Query: GraphQLQuery
  associatedtype Output: Hashable
  associatedtype PageInput: Hashable
  associatedtype PageExtractor: PageExtractionStrategy where PageExtractor.Input == PageInput
  associatedtype OutputTransformer: DataTransformer
  where OutputTransformer.Query == Query, OutputTransformer.Output == Output

  associatedtype NextPageConstructor: NextPageStrategy
  where NextPageConstructor.Page == PageExtractor.Page,
        NextPageConstructor.Query == OutputTransformer.Query,
        NextPageConstructor.Query == Query

  associatedtype MergeStrategy: PaginationMergeStrategy
  where MergeStrategy.Query == Query,
        MergeStrategy.Query == NextPageConstructor.Query,
        MergeStrategy.Query == OutputTransformer.Query,
        MergeStrategy.Output == OutputTransformer.Output,
        MergeStrategy.Output == Output

  var pageExtractionStrategy: PageExtractor { get }
  var outputTransformer: OutputTransformer { get }
  var nextPageStrategy: NextPageConstructor { get }
  var mergeStrategy: MergeStrategy { get }
  var currentPage: PageExtractor.Page? { get }
  var pages: [PageExtractor.Page?] { get }
  func onWatchResult(result: Result<GraphQLResult<Query.Data>, Error>) -> Void
  func canFetchNextPage() -> Bool
  func reset()
}
