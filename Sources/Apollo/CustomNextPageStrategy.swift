#if !COCOAPODS
import ApolloAPI
#endif

public struct CustomNextPageStrategy<Page: Hashable, Query: GraphQLQuery>: NextPageStrategy {
  public let _transform: (Page) -> Query

  public init(transform: @escaping (Page) -> Query) {
    self._transform = transform
  }

  public func createNextPageQuery(page: Page) -> Query {
    _transform(page)
  }
}
