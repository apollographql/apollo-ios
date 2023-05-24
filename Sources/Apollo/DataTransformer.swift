#if !COCOAPODS
import ApolloAPI
#endif

public protocol DataTransformer {
  associatedtype Query: GraphQLQuery
  associatedtype Output: Hashable

  func transform(data: Query.Data) -> Output?
}
