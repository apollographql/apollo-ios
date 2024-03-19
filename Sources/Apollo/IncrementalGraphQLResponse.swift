import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

/// Represents an incremental GraphQL response received from a server.
final class IncrementalGraphQLResponse<Operation: GraphQLOperation> {
  public enum ResponseError: Error, LocalizedError, Equatable {
    case missingPath
    case missingLabel
    case missingDeferredSelectionSetType(String, String)

    public var errorDescription: String? {
      switch self {
      case .missingPath:
        return "Incremental responses must have a 'path' key."

      case .missingLabel:
        return "Incremental responses must have a 'label' key."

      case let .missingDeferredSelectionSetType(label, path):
        return "The operation does not have a deferred selection set for label '\(label)' at field path '\(path)'."
      }
    }
  }

  private let base: AnyGraphQLResponse

  public init(operation: Operation, body: JSONObject) throws {
    guard let path = body["path"] as? [JSONValue] else {
      throw ResponseError.missingPath
    }

    let rootKey = try CacheReference.rootCacheReference(for: Operation.operationType, path: path)

    self.base = AnyGraphQLResponse(
      body: body,
      rootKey: rootKey,
      variables: operation.__variables
    )
  }

  func parseIncrementalResult() throws -> IncrementalGraphQLResult {
    guard let path = base.body["path"] as? [JSONValue] else { throw ResponseError.missingPath }
    guard let label = base.body["label"] as? String else { throw ResponseError.missingLabel }

    let pathComponents: [PathComponent] = path.compactMap(PathComponent.init)
    let fieldPath = pathComponents.fieldPath

    guard let selectionSetType = Operation.deferredSelectionSetType(
      for: Operation.self,
      withLabel: label,
      atFieldPath: fieldPath
    ) as? (any Deferrable.Type) else {
      throw ResponseError.missingDeferredSelectionSetType(label, fieldPath.joined(separator: "."))
    }

    let accumulator = zip(
      DataDictMapper(),
      ResultNormalizerFactory.networkResponseDataNormalizer(),
      GraphQLDependencyTracker()
    )

    let executionResult = try base.execute(
      selectionSet: selectionSetType,
      in: Operation.self,
      with: accumulator
    )

    let selectionSet: (any SelectionSet)?
    if let data = executionResult?.0 {
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
      dependentKeys: executionResult?.2
    )
  }
}

fileprivate extension CacheReference {
  static func rootCacheReference(
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
