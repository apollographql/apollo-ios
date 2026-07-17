import Foundation
@_spi(Execution) @_spi(Internal) @_spi(Unsafe) import ApolloAPI

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
  struct IncrementalResponseExecutionHandler<Operation: GraphQLOperation> {

    private let base: BaseResponseExecutionHandler

    init(
      responseBody: JSONObject,
      operationVariables: GraphQLOperation.Variables?,
      existingRecords: RecordSet?
    ) throws {
      guard let path = responseBody["path"] as? [JSONValue] else {
        throw IncrementalResponseError.missingPath
      }

      let rootKey = try CacheReference.rootCacheReference(
        for: Operation.operationType,
        path: path,
        rootSelectionSet: Operation.Data.self,
        variables: operationVariables,
        resolvingAgainst: existingRecords
      )

      self.base = BaseResponseExecutionHandler(
        responseBody: responseBody,
        rootKey: rootKey,
        variables: operationVariables
      )
    }
    
    /// Parses the response into a `IncrementalGraphQLResult` and a `RecordSet` depending on the cache policy. The result
    /// can be used to merge into a partial result and the `RecordSet` can be merged into a local cache.
    ///
    /// - Returns: A tuple of a `IncrementalGraphQLResult` and an optional `RecordSet`.
    ///
    /// - Parameter includeCacheRecords: Used to determine whether a cache `RecordSet` is returned.
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
    path: [JSONValue],
    rootSelectionSet: any SelectionSet.Type,
    variables: GraphQLOperation.Variables?,
    resolvingAgainst records: RecordSet?
  ) throws -> CacheReference {
    let rootKey = rootCacheReference(for: operationType).key

    if let records,
       let resolvedKey = resolveCacheKey(
        forPath: path,
        fromRootKey: rootKey,
        rootSelectionSet: rootSelectionSet,
        variables: variables,
        in: records
       ) {
      return CacheReference(resolvedKey)
    }

    var keys: [String] = [rootKey]
    for component in path {
      keys.append(try String(_jsonValue: component))
    }

    return CacheReference(keys.joined(separator: "."))
  }

  private static func resolveCacheKey(
    forPath path: [JSONValue],
    fromRootKey rootKey: String,
    rootSelectionSet: any SelectionSet.Type,
    variables: GraphQLOperation.Variables?,
    in records: RecordSet
  ) -> String? {
    var current: JSONValue? = CacheReference(rootKey)
    var currentSelectionSet: (any SelectionSet.Type)? = rootSelectionSet

    for component in path {
      switch current {
      case let reference as CacheReference:
        guard let responseKey = component as? String,
              let record = records[reference.key],
              let selectionSet = currentSelectionSet,
              let field = field(matching: responseKey, in: selectionSet.__selections, variables: variables),
              let cacheKey = try? field.cacheKey(with: variables) else {
          return nil
        }
        current = record[cacheKey]
        currentSelectionSet = objectType(of: field.type)

      case let list as [JSONValue?]:
        guard let index = pathIndex(from: component), list.indices.contains(index) else {
          return nil
        }
        current = list[index]

      default:
        return nil
      }
    }

    return (current as? CacheReference)?.key
  }

  private static func field(
    matching responseKey: String,
    in selections: [Selection],
    variables: GraphQLOperation.Variables?
  ) -> Selection.Field? {
    var matches: [Selection.Field] = []
    collectFields(forResponseKey: responseKey, in: selections, into: &matches)

    guard let first = matches.first else { return nil }
    let firstCacheKey = try? first.cacheKey(with: variables)
    for match in matches.dropFirst() where (try? match.cacheKey(with: variables)) != firstCacheKey {
      return nil
    }
    return first
  }

  private static func collectFields(
    forResponseKey responseKey: String,
    in selections: [Selection],
    into matches: inout [Selection.Field]
  ) {
    for selection in selections {
      switch selection {
      case let .field(field):
        if field.responseKey == responseKey {
          matches.append(field)
        }
      case let .fragment(fragment):
        collectFields(forResponseKey: responseKey, in: fragment.__selections, into: &matches)
      case let .inlineFragment(inlineFragment):
        collectFields(forResponseKey: responseKey, in: inlineFragment.__selections, into: &matches)
      case let .deferred(_, deferred, _):
        collectFields(forResponseKey: responseKey, in: deferred.__selections, into: &matches)
      case let .conditional(_, conditionalSelections):
        collectFields(forResponseKey: responseKey, in: conditionalSelections, into: &matches)
      }
    }
  }

  private static func objectType(of outputType: Selection.Field.OutputType) -> (any SelectionSet.Type)? {
    if case let .object(rootSelectionSetType) = outputType.namedType {
      return rootSelectionSetType
    }
    return nil
  }

  private static func pathIndex(from component: JSONValue) -> Int? {
    if let index = component as? Int { return index }
    if let string = component as? String { return Int(string) }
    return nil
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
