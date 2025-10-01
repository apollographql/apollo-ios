import ApolloAPI

/// A result parsed from GraphQL specification compliant response data.
public struct ParsedResult<Operation: GraphQLOperation>: Sendable, Hashable {

  /// The parsed ``GraphQLResponse`` for the operation.
  public let result: GraphQLResponse<Operation>

  /// The parsed response data as a ``RecordSet`` suitable for writing to an ``ApolloStore``
  public let cacheRecords: RecordSet?

  /// Designated Initializer
  /// - Parameters:
  ///   - result: The parsed ``GraphQLResponse`` for the operation.
  ///   - cacheRecords: The parsed response data as a ``RecordSet`` suitable for writing to an ``ApolloStore``
  public init(result: GraphQLResponse<Operation>, cacheRecords: RecordSet?) {
    self.result = result
    self.cacheRecords = cacheRecords
  }
}
