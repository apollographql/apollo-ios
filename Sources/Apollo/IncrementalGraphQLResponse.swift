import Foundation
#if !COCOAPODS
import ApolloAPI
#endif

/// Represents an incremental GraphQL response received from a server.
final class IncrementalGraphQLResponse<Operation: GraphQLOperation> {
  public enum ResponseError: Error, LocalizedError {
    case missingPath
    case cannotParseIncrementalData

    public var errorDescription: String? {
      switch self {
      case .missingPath:
        return "Incremental responses must have a 'path' key."

      case .cannotParseIncrementalData:
        return "Cannot parse the incremental data."
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
    guard 
      let label = base.body["label"] as? String,
      let path = base.body["path"] as? [JSONValue],
      let selectionSetType = Operation.deferredSelectionSetType(withLabel: label, atPath: path)
    else {
      throw ResponseError.cannotParseIncrementalData
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
      path: path.compactMap(PathComponent.init),
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
