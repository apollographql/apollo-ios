import Foundation

#if !COCOAPODS
@_spi(Internal) import ApolloAPI
#endif

public enum IncrementalResponseError: Error, LocalizedError, Equatable {
  case missingExistingData
  case missingPath
  case missingLabel
  case missingDeferredSelectionSetType(String, String)

  public var errorDescription: String? {
    switch self {
    case .missingExistingData:
      return "Incremental response must be returned after initial response."
    case .missingPath:
      return "Incremental responses must have a 'path' key."

    case .missingLabel:
      return "Incremental responses must have a 'label' key."

    case let .missingDeferredSelectionSetType(label, path):
      return "The operation does not have a deferred selection set for label '\(label)' at field path '\(path)'."
    }
  }
}

extension JSONResponseParser {
  /// Represents an incremental GraphQL response received from a server.
  struct IncrementalResponseExecutionHandler {

    private let base: BaseResponseExecutionHandler

    init(
      responseBody: JSONObject,
      operationVariables: Operation.Variables?
    ) throws {
      guard let path = responseBody["path"] as? [JSONValue] else {
        throw IncrementalResponseError.missingPath
      }

      let rootKey = try CacheReference.rootCacheReference(for: Operation.operationType, path: path)

      self.base = BaseResponseExecutionHandler(
        responseBody: responseBody,
        rootKey: rootKey,
        variables: operationVariables
      )
    }

    #warning("Fix Docs")
    /// Parses the response into a `IncrementalGraphQLResult` and a `RecordSet` depending on the cache policy. The result
    /// can be used to merge into a partial result and the `RecordSet` can be merged into a local cache.
    ///
    /// - Returns: A tuple of a `IncrementalGraphQLResult` and an optional `RecordSet`.
    ///
    /// - Parameter cachePolicy: Used to determine whether a cache `RecordSet` is returned. A cache policy that does
    /// not read or write to the cache will return a `nil` cache `RecordSet`.
    func execute(
      includeCacheRecords: Bool
    ) async throws -> (IncrementalGraphQLResult, RecordSet?) {
      switch includeCacheRecords {
      case false:
        return (try await parseIncrementalResultOmittingCacheRecords(), nil)

      case true:
        return try await parseIncrementalResultIncludingCacheRecords()
      }
    }

    private func parseIncrementalResultIncludingCacheRecords()
      async throws -> (IncrementalGraphQLResult, RecordSet?)
    {
      let accumulator = zip(
        DataDictMapper(),
        ResultNormalizerFactory.networkResponseDataNormalizer(),
        GraphQLDependencyTracker()
      )

      var cacheKeys: RecordSet? = nil
      let result = try await makeResult { deferrableSelectionSetType in
        let executionResult = try await base.execute(
          selectionSet: deferrableSelectionSetType,
          in: Operation.self,
          with: accumulator
        )
        cacheKeys = executionResult?.1

        return (executionResult?.0, executionResult?.2)
      }

      return (result, cacheKeys)
    }

    private func parseIncrementalResultOmittingCacheRecords() async throws -> IncrementalGraphQLResult {
      let accumulator = DataDictMapper()
      let result = try await makeResult { deferrableSelectionSetType in
        let executionResult = try await base.execute(
          selectionSet: deferrableSelectionSetType,
          in: Operation.self,
          with: accumulator
        )

        return (executionResult, nil)
      }

      return result
    }

    fileprivate func makeResult(
      executor: ((any Deferrable.Type) async throws -> (data: DataDict?, dependentKeys: Set<CacheKey>?))
    ) async throws -> IncrementalGraphQLResult {
      guard let path = base.responseBody["path"] as? [JSONValue] else {
        throw IncrementalResponseError.missingPath
      }
      guard let label = base.responseBody["label"] as? String else {
        throw IncrementalResponseError.missingLabel
      }

      let pathComponents: [PathComponent] = path.compactMap(PathComponent.init)
      let fieldPath = pathComponents.fieldPath
      let fragmentIdentifier = DeferredFragmentIdentifier(label: label, fieldPath: fieldPath)
      
      guard let deferredResponseFormat = Operation.responseFormat as? IncrementalDeferredResponseFormat,
            let selectionSetType = deferredResponseFormat.deferredFragments[fragmentIdentifier] as? (any Deferrable.Type) else {
        throw IncrementalResponseError.missingDeferredSelectionSetType(label, fieldPath.joined(separator: "."))
      }

      let executionResult = try await executor(selectionSetType)
      let selectionSet: (any SelectionSet)?

      if let data = executionResult.data {
        selectionSet = selectionSetType.init(_dataDict: data)
      } else {
        selectionSet = nil
      }

      return IncrementalGraphQLResult(
        label: label,
        path: pathComponents,
        data: selectionSet,
        extensions: base.parseExtensions(),
        errors: base.parseErrors(),
        dependentKeys: executionResult.dependentKeys
      )
    }
  }
}

extension CacheReference {
  fileprivate static func rootCacheReference(
    for operationType: GraphQLOperationType,
    path: [JSONValue]
  ) throws -> CacheReference {
    var keys: [String] = [rootCacheReference(for: operationType).key]
    for component in path {
      keys.append(try String(_jsonValue: component))
    }

    return CacheReference(keys.joined(separator: "."))
  }
}

extension [PathComponent] {
  fileprivate var fieldPath: [String] {
    return self.compactMap({ pathComponent in
      if case let .field(name) = pathComponent {
        return name
      }

      return nil
    })
  }
}
