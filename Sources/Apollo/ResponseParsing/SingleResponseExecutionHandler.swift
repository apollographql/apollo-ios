#if !COCOAPODS
  import ApolloAPI
#endif

extension JSONResponseParser {

  struct SingleResponseExecutionHandler<Operation: GraphQLOperation> {
    private let base: BaseResponseExecutionHandler

    init(
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
    func execute(
      includeCacheRecords: Bool
    ) async throws -> GraphQLResponse<Operation> {
      switch includeCacheRecords {
      case false:
        return GraphQLResponse(result: try await parseResultOmittingCacheRecords(), cacheRecords: nil)

      case true:
        return try await parseResultIncludingCacheRecords()
      }
    }

    /// Parses a response into a `GraphQLResult` and a `RecordSet`. The result can be sent to a completion block for a
    /// request and the `RecordSet` can be merged into a local cache.
    ///
    /// - Returns: A `GraphQLResult` and a `RecordSet`.
    public func parseResultIncludingCacheRecords() async throws -> GraphQLResponse<Operation> {
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

      return GraphQLResponse(result: result, cacheRecords: executionResult?.1)
    }

    /// Parses a response into a `GraphQLResult` for use without the cache. This parsing does not
    /// create dependent keys or a `RecordSet` for the cache.
    ///
    /// This is faster than `parseResult()` and should be used when cache the response is not needed.
    public func parseResultOmittingCacheRecords() async throws -> GraphQLResult<Operation.Data> {
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
    ) -> GraphQLResult<Operation.Data> {
      #warning("TODO: Do we need to make sure that there is either data or errors in the result?")
      return GraphQLResult<Operation.Data>(
        data: data,
        extensions: base.parseExtensions(),
        errors: base.parseErrors(),
        source: .server,
        dependentKeys: dependentKeys
      )
    }
  }
}
