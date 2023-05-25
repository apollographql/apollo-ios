#if !COCOAPODS
import ApolloAPI
#endif

/// The strategy by which we create the next query in a series of paginated queries. Gives full custom control over mapping a `Page` into a `Query`.
public struct CustomNextPageStrategy<Page: Hashable, Query: GraphQLQuery>: NextPageStrategy {
  private let _transform: (Page) -> Query

  public init(transform: @escaping (Page) -> Query) {
    self._transform = transform
  }

  public func createNextPageQuery(page: Page) -> Query {
    _transform(page)
  }
}
