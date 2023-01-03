#if !COCOAPODS
import ApolloAPI
#endif

/// Represents a GraphQL response received from a server.
public final class GraphQLResponse<Data: RootSelectionSet> {

  public let body: JSONObject

  private let rootKey: CacheReference
  private let variables: GraphQLOperation.Variables?

  public init<Operation: GraphQLOperation>(operation: Operation, body: JSONObject) where Operation.Data == Data {
    self.body = body
    rootKey = CacheReference.rootCacheReference(for: Operation.operationType)
    variables = operation.__variables
  }

  /// Parses a response into a `GraphQLResult` and a `RecordSet`.
  /// The result can be sent to a completion block for a request.
  /// The `RecordSet` can be merged into a local cache.
  /// - Returns: A `GraphQLResult` and a `RecordSet`.
  public func parseResult() throws -> (GraphQLResult<Data>, RecordSet?) {
    let accumulator = zip(
      GraphQLSelectionSetMapper<Data>(stripNullValues: true),
      GraphQLResultNormalizer(),
      GraphQLDependencyTracker()
    )

    let executionResult = try execute(with: accumulator, computeCachePaths: true)
    let result = makeResult(data: executionResult?.0, dependentKeys: executionResult?.2)
    return (result, executionResult?.1)
  }

  private func execute<Accumulator: GraphQLResultAccumulator>(
    with accumulator: Accumulator,
    computeCachePaths: Bool
  ) throws -> Accumulator.FinalResult? {
    guard let dataEntry = body["data"] as? JSONObject else {
      return nil
    }

    let executor = GraphQLExecutor { object, info in
      return object[info.responseKeyForField]
    }

    executor.shouldComputeCachePath = computeCachePaths

    return try executor.execute(selectionSet: Data.self,
                                on: dataEntry,
                                withRootCacheReference: rootKey,
                                variables: variables,
                                accumulator: accumulator)
  }

  private func makeResult(data: Data?, dependentKeys: Set<CacheKey>?) -> GraphQLResult<Data> {
    let errors = self.parseErrors()
    let extensions = body["extensions"] as? JSONObject

    return GraphQLResult(data: data,
                         extensions: extensions,
                         errors: errors,
                         source: .server,
                         dependentKeys: dependentKeys)
  }

  private func parseErrors() -> [GraphQLError]? {
    guard let errorsEntry = self.body["errors"] as? [JSONObject] else {
      return nil
    }

    return errorsEntry.map(GraphQLError.init)
  }

  /// Parses a response into a `GraphQLResult` for use without the cache. This parsing does not
  /// create dependent keys or a `RecordSet` for the cache.
  ///
  /// This is faster than `parseResult()` and should be used when cache the response is not needed.
  public func parseResultFast() throws -> GraphQLResult<Data>  {
    let accumulator = GraphQLSelectionSetMapper<Data>(stripNullValues: true)
    let data = try execute(with: accumulator, computeCachePaths: false)
    return makeResult(data: data, dependentKeys: nil)    
  }
}

// MARK: - Equatable Conformance

extension GraphQLResponse: Equatable where Data: Equatable {
  public static func == (lhs: GraphQLResponse<Data>, rhs: GraphQLResponse<Data>) -> Bool {
    lhs.body == rhs.body &&
    lhs.rootKey == rhs.rootKey &&
    lhs.variables?._jsonEncodableObject._jsonValue == rhs.variables?._jsonEncodableObject._jsonValue
  }
}

// MARK: - Hashable Conformance

extension GraphQLResponse: Hashable where Data: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(body)
    hasher.combine(rootKey)
    hasher.combine(variables?._jsonEncodableValue?._jsonValue)
  }
}
