#if !COCOAPODS
import ApolloAPI
#endif

public struct CustomDataTransformer<Query: GraphQLQuery, Output: Hashable>: DataTransformer {

  public let _transform: (Query.Data) -> Output?

  public init(transform: @escaping (Query.Data) -> Output?) {
    self._transform = transform
  }

  public func transform(data: Query.Data) -> Output? {
    _transform(data)
  }
}
