#if !COCOAPODS
import ApolloAPI
#endif

/// An overall `PaginationStrategy`, composed of a `PageExtractionStrategy`, a `DataTransformer`, a `NextPageStrategy`, and a `PaginationMergeStrategy`.
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

  /// The callback to trigger when a `GraphQLQueryWatcher` has a formed result.
  /// - Parameter result: The result of a `GraphQLQueryWatcher`.
  func onWatchResult(result: Result<GraphQLResult<Query.Data>, Error>)

  /// Whether or not this strategy is able to fetch the next page.
  /// - Returns: A `Bool` that states whether or not we are capable of fetching another page.
  func canFetchNextPage() -> Bool

  /// Resets the state of the `PaginationStrategy`. Intended to be used for `refetch`ing all data.
  func reset()
}
