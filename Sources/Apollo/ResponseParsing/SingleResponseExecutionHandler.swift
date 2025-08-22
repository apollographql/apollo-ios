@_spi(Unsafe) import ApolloAPI

extension JSONResponseParser {
  @_spi(Execution)
  public struct SingleResponseExecutionHandler<Operation: GraphQLOperation> {
    private let base: BaseResponseExecutionHandler

    public init(
      responseBody: JSONObject,
      operationVariables: GraphQLOperation.Variables?
    ) {
      self.base = BaseResponseExecutionHandler(
        responseBody: responseBody,
        rootKey: CacheReference.rootCacheReference(for: Operation.operationType),
        variables: operationVariables
      )
    }

    /// Runs GraphQLExecution over the "data" of the JSON response object and converts it into a
    /// `GraphQLResult` and optional `RecordSet`.
    /// The result can be sent to a completion block for a request and the `RecordSet` can be
    /// merged into a local cache.
    ///
    /// - Returns: A `GraphQLResult` and optional `RecordSet`.
    public func execute(
      includeCacheRecords: Bool
    ) async throws -> ParsedResult<Operation> {
      switch includeCacheRecords {
      case false:
        return ParsedResult(result: try await parseResultOmittingCacheRecords(), cacheRecords: nil)

      case true:
        return try await parseResultIncludingCacheRecords()
      }
    }

    /// Parses a response into a ``ParsedResult`` that includes ``ParsedResult/cacheRecords``.
    ///
    /// - Returns: A ``ParsedResult``
    private func parseResultIncludingCacheRecords() async throws -> ParsedResult<Operation> {
      let accumulator = zip(
        DataDictMapper(),
        ResultNormalizerFactory.networkResponseDataNormalizer(),
        GraphQLDependencyTracker()
      )
      let executionResult = try await base.execute(
        selectionSet: Operation.Data.self,
        with: accumulator
      )

      let result = makeResult(
        data: executionResult?.0 != nil ? Operation.Data(_dataDict: executionResult!.0) : nil,
        dependentKeys: executionResult?.2
      )

      return ParsedResult(result: result, cacheRecords: executionResult?.1)
    }

    /// Parses a response into a `GraphQLResponse` for use without the cache. This parsing does not
    /// create dependent keys or a `RecordSet` for the cache.
    ///
    /// This is faster than `parseResult()` and should be used when cache the response is not needed.
    private func parseResultOmittingCacheRecords() async throws -> GraphQLResponse<Operation> {
      let accumulator = DataDictMapper()
      let data = try await base.execute(
        selectionSet: Operation.Data.self,
        with: accumulator
      )

      return makeResult(
        data: data != nil ? Operation.Data(_dataDict: data!) : nil,
        dependentKeys: nil
      )
    }

    private func makeResult(
      data: Operation.Data?,
      dependentKeys: Set<CacheKey>?
    ) -> GraphQLResponse<Operation> {      
      return GraphQLResponse<Operation>(
        data: data,
        extensions: base.parseExtensions(),
        errors: base.parseErrors(),
        source: .server,
        dependentKeys: dependentKeys
      )
    }
  }
}
