#if !COCOAPODS
import ApolloAPI
#endif

/// Represents a complete GraphQL response received from a server.
public final class GraphQLResponse<Data: RootSelectionSet> {
  private let base: AnyGraphQLResponse

  public init<Operation: GraphQLOperation>(
    operation: Operation,
    body: JSONObject
  ) where Operation.Data == Data {
    self.base = AnyGraphQLResponse(
      body: body,
      rootKey: CacheReference.rootCacheReference(for: Operation.operationType),
      variables: operation.__variables
    )
  }

  /// Parses a response into a `GraphQLResult` and a `RecordSet`.
  /// The result can be sent to a completion block for a request.
  /// The `RecordSet` can be merged into a local cache.
  /// - Returns: A `GraphQLResult` and a `RecordSet`.
  public func parseResult() throws -> (GraphQLResult<Data>, RecordSet?) {
    let accumulator = zip(
      GraphQLSelectionSetMapper<Data>(),
      ResultNormalizerFactory.networkResponseDataNormalizer(),
      GraphQLDependencyTracker()
    )
    let executionResult = try base.execute(
      selectionSet: Data.self,
      with: accumulator
    )
    let result = makeResult(data: executionResult?.0, dependentKeys: executionResult?.2)

    return (result, executionResult?.1)
  }

  /// Parses a response into a `GraphQLResult` for use without the cache. This parsing does not
  /// create dependent keys or a `RecordSet` for the cache.
  ///
  /// This is faster than `parseResult()` and should be used when cache the response is not needed.
  public func parseResultFast() throws -> GraphQLResult<Data>  {
    let accumulator = GraphQLSelectionSetMapper<Data>()
    let data = try base.execute(
      selectionSet: Data.self,
      with: accumulator
    )

    return makeResult(data: data, dependentKeys: nil)
  }

  private func makeResult(data: Data?, dependentKeys: Set<CacheKey>?) -> GraphQLResult<Data> {
    let errors = base.parseErrors()
    let extensions = base.parseExtensions()

    return GraphQLResult(
      data: data,
      extensions: extensions,
      errors: errors,
      source: .server,
      dependentKeys: dependentKeys
    )
  }
}

// MARK: - Equatable Conformance

extension GraphQLResponse: Equatable where Data: Equatable {
  public static func == (lhs: GraphQLResponse<Data>, rhs: GraphQLResponse<Data>) -> Bool {
    lhs.base == rhs.base
  }
}

// MARK: - Hashable Conformance

extension GraphQLResponse: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(base)
  }
}
