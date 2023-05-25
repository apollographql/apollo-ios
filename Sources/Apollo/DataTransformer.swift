#if !COCOAPODS
import ApolloAPI
#endif

/// The protocol by which we transform a network/cache response into some `Output`.
public protocol DataTransformer {
  associatedtype Query: GraphQLQuery
  associatedtype Output: Hashable

  /// Given a network response, transform it into the intended result type of the `PaginationStrategy`.
  /// - Parameter data: A network response
  /// - Returns: `Output`
  func transform(data: Query.Data) -> Output?
}
