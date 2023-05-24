#if !COCOAPODS
import ApolloAPI
#endif

public struct PassthroughDataTransformer<Query: GraphQLQuery>: DataTransformer {
  public init() { }

  public func transform(data: Query.Data) -> Query.Data? {
    data
  }
}
