#if !COCOAPODS
import ApolloAPI
#endif

/// An abstract GraphQL response used for full and incremental responses.
struct AnyGraphQLResponse {
  public let body: JSONObject

  private let rootKey: CacheReference
  private let variables: GraphQLOperation.Variables?

  init(
    body: JSONObject,
    rootKey: CacheReference,
    variables: GraphQLOperation.Variables?
  ) {
    self.body = body
    self.rootKey = rootKey
    self.variables = variables
  }


  func execute<
    Accumulator: GraphQLResultAccumulator,
    Operation: GraphQLOperation
  >(
    selectionSet: any SelectionSet.Type,
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
  public static func == (lhs: AnyGraphQLResponse, rhs: AnyGraphQLResponse) -> Bool {
    lhs.body == rhs.body &&
    lhs.rootKey == rhs.rootKey &&
    lhs.variables?._jsonEncodableObject._jsonValue == rhs.variables?._jsonEncodableObject._jsonValue
  }
}

// MARK: - Hashable Conformance

extension AnyGraphQLResponse: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(body)
    hasher.combine(rootKey)
    hasher.combine(variables?._jsonEncodableObject._jsonValue)
  }
}
