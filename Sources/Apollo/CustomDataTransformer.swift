#if !COCOAPODS
import ApolloAPI
#endif

/// Gives the caller full control over how to transform data.
/// Can be used to output a custom type, or can be used for fine grain control over how a `Query.Data` is merged.
public struct CustomDataTransformer<Query: GraphQLQuery, Output: Hashable>: DataTransformer {

  private let _transform: (Query.Data) -> Output?

  /// Designated intializer
  /// - Parameter transform: A user provided function which can transform a given network response into any `Hashable` output.
  public init(transform: @escaping (Query.Data) -> Output?) {
    self._transform = transform
  }

  /// The function by which we transform a `Query.Data` into an output
  /// - Parameter data: Network response
  /// - Returns: `Output`
  public func transform(data: Query.Data) -> Output? {
    _transform(data)
  }
}
