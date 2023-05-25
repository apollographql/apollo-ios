#if !COCOAPODS
import ApolloAPI
#endif

/// The strategy by which we create the next query in a series of paginated queries.
public protocol NextPageStrategy {
  associatedtype Query: GraphQLQuery
  associatedtype Page: Hashable

  /// Given some `Page`, returns a formed `Query` that uses the information contained within the `Page` to paginate.
  func createNextPageQuery(page: Page) -> Query
}
