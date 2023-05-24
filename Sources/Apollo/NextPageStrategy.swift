#if !COCOAPODS
import ApolloAPI
#endif

public protocol NextPageStrategy {
  associatedtype Query: GraphQLQuery
  associatedtype Page: Hashable

  func createNextPageQuery(page: Page) -> Query
}
