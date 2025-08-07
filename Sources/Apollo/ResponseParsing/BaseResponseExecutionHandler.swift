@_spi(Internal) import ApolloAPI

struct BaseResponseExecutionHandler: Sendable {

  let responseBody: JSONObject
  let rootKey: CacheReference
  let variables: GraphQLOperation.Variables?

  init(
    responseBody: JSONObject,
    rootKey: CacheReference,
    variables: GraphQLOperation.Variables?
  ) {
    self.responseBody = try! JSONObject(_jsonValue: responseBody as JSONValue)
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
  ) async throws -> Accumulator.FinalResult? {
    guard let dataEntry = responseBody["data"] as? JSONObject else {
      return nil
    }

    return try await executor.execute(
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
  ) async throws -> Accumulator.FinalResult? {
    guard let dataEntry = responseBody["data"] as? JSONObject else {
      return nil
    }

    return try await executor.execute(
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
    guard let errorsEntry = self.responseBody["errors"] as? [JSONObject] else {
      return nil
    }

    return errorsEntry.map {
      GraphQLError($0)
    }
  }

  func parseExtensions() -> JSONObject? {
    return self.responseBody["extensions"] as? JSONObject
  }
}
