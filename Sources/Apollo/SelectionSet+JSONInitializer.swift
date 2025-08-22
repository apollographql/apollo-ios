@_spi(Unsafe) import ApolloAPI

extension RootSelectionSet {

  /// Initializes a `SelectionSet` with a raw JSON response object.
  ///
  /// The process of converting a JSON response into `SelectionSetData` is done by using a
  /// `GraphQLExecutor` with a`GraphQLSelectionSetMapper` to parse, validate, and transform
  /// the JSON response data into the format expected by `SelectionSet`.
  ///
  /// - Parameters:
  ///   - data: A dictionary representing a JSON response object for a GraphQL object.
  ///   - variables: [Optional] The operation variables that would be used to obtain
  ///                the given JSON response data.
  public init(
    data: JSONObject,
    variables: GraphQLOperation.Variables? = nil
  ) async throws {
    let accumulator = DataDictMapper(
      handleMissingValues: .allowForOptionalFields
    )
    let executor = GraphQLExecutor(executionSource: NetworkResponseExecutionSource())

    let dataDict = try await executor.execute(
      selectionSet: Self.self,
      on: data,
      variables: variables,
      accumulator: accumulator
    )

    self.init(_dataDict: dataDict)
  }

}

extension Deferrable {

  /// Initializes a `Deferrable` `SelectionSet` with a raw JSON response object.
  ///
  /// The process of converting a JSON response into `SelectionSetData` is done by using a
  /// `GraphQLExecutor` with a`GraphQLSelectionSetMapper` to parse, validate, and transform
  /// the JSON response data into the format expected by the `Deferrable` `SelectionSet`.
  ///
  /// - Parameters:
  ///   - data: A dictionary representing a JSON response object for a GraphQL object.
  ///   - operation: The operation which contains `data`.
  ///   - variables: [Optional] The operation variables that would be used to obtain
  ///                the given JSON response data.
  init(
    data: JSONObject,
    in operation: any GraphQLOperation.Type,
    variables: GraphQLOperation.Variables? = nil
  ) async throws {
    let accumulator = DataDictMapper(
      handleMissingValues: .allowForOptionalFields
    )
    let executor = GraphQLExecutor(executionSource: NetworkResponseExecutionSource())

    let dataDict = try await executor.execute(
      selectionSet: Self.self,
      in: operation,
      on: data,
      variables: variables,
      accumulator: accumulator
    )
    self.init(_dataDict: dataDict)
  }

}
