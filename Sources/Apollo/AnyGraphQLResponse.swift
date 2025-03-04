#if !COCOAPODS
@_spi(Internal) import ApolloAPI
#endif

/// An abstract GraphQL response used for full and incremental responses.
struct AnyGraphQLResponse {
  let body: JSONObject

  private let rootKey: CacheReference
  private let variables: GraphQLOperation.Variables?

  init(
    body: JSONObject,
    rootKey: CacheReference,
    variables: GraphQLOperation.Variables?
  ) {
    self.body = try! JSONObject(_jsonValue: body as JSONValue)
    self.rootKey = rootKey
    self.variables = variables
  }

  /// Call this function when you want to execute on an entire operation and its response data.
  /// This function should also be called to execute on the partial (initial) response of an
  /// operation with deferred selection sets.
  func execute<
    Accumulator: GraphQLResultAccumulator,
    Data: RootSelectionSet
  >(
    selectionSet: Data.Type,
    with accumulator: Accumulator
  ) throws -> Accumulator.FinalResult? {
    guard let dataEntry = body["data"] as? JSONObject else {
      return nil
    }

    return try executor.execute(
      selectionSet: Data.self,
      on: dataEntry,
      withRootCacheReference: rootKey,
      variables: variables,
      accumulator: accumulator
    )
  }

  /// Call this function to execute on a specific selection set and its incremental response data.
  /// This is typically used when executing on deferred selections.
  func execute<
    Accumulator: GraphQLResultAccumulator,
    Operation: GraphQLOperation
  >(
    selectionSet: any Deferrable.Type,
    in operation: Operation.Type,
    with accumulator: Accumulator
  ) throws -> Accumulator.FinalResult? {
    guard let dataEntry = body["data"] as? JSONObject else {
      return nil
    }

    return try executor.execute(
      selectionSet: selectionSet,
      in: Operation.self,
      on: dataEntry,
      withRootCacheReference: rootKey,
      variables: variables,
      accumulator: accumulator
    )
  }

  var executor: GraphQLExecutor<NetworkResponseExecutionSource> {
    GraphQLExecutor(executionSource: NetworkResponseExecutionSource())
  }

  func parseErrors() -> [GraphQLError]? {
    guard let errorsEntry = self.body["errors"] as? [JSONObject] else {
      return nil
    }

    return errorsEntry.map(GraphQLError.init)
  }

  func parseExtensions() -> JSONObject? {
    return self.body["extensions"] as? JSONObject
  }
}

// MARK: - Equatable Conformance

extension AnyGraphQLResponse: Equatable {
  static func == (lhs: AnyGraphQLResponse, rhs: AnyGraphQLResponse) -> Bool {
    AnySendableHashable.equatableCheck(lhs.body, rhs.body) &&
    lhs.rootKey == rhs.rootKey &&
    AnySendableHashable.equatableCheck(lhs.variables?._jsonEncodableObject._jsonValue, rhs.variables?._jsonEncodableObject._jsonValue)
  }
}

// MARK: - Hashable Conformance

extension AnyGraphQLResponse: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(body)
    hasher.combine(rootKey)
    hasher.combine(variables?._jsonEncodableObject._jsonValue)
  }
}
