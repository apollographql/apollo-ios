#if !COCOAPODS
import ApolloAPI
#endif

/// A data transformer which allows the `Query.Data` to pass through unaltered.
public struct PassthroughDataTransformer<Query: GraphQLQuery>: DataTransformer {
  public init() { }

  public func transform(data: Query.Data) -> Query.Data? {
    data
  }
}
