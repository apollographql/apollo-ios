#if !COCOAPODS
import ApolloAPI
#endif
import Foundation

/// Represents the result of a GraphQL operation.
public struct GraphQLResult<Data: RootSelectionSet> {

  /// Represents source of data
  public enum Source: Hashable {
    case cache
    case server
  }

  /// The typed result data, or `nil` if an error was encountered that prevented a valid response.
  public let data: Data?
  /// A list of errors, or `nil` if the operation completed without encountering any errors.
  public let errors: [GraphQLError]?
  /// A dictionary which services can use however they see fit to provide additional information to clients.
  public let extensions: [String: AnyHashable]?
  /// Source of data
  public let source: Source

  let dependentKeys: Set<CacheKey>?

  public init(
    data: Data?,
    extensions: [String: AnyHashable]?,
    errors: [GraphQLError]?,
    source: Source,
    dependentKeys: Set<CacheKey>?
  ) {
    self.data = data
    self.extensions = extensions
    self.errors = errors
    self.source = source
    self.dependentKeys = dependentKeys
  }

  func merging(_ incrementalResult: IncrementalGraphQLResult) throws -> GraphQLResult<Data> {
    var mergedData = self.data
    if let incrementalDataDict = incrementalResult.data?.__data {
      if var currentDataDict = mergedData?.__data {
        mergedData = Data(
          _dataDict: try currentDataDict.merging(incrementalDataDict, at: incrementalResult.path)
        )

      } else {
        mergedData = Data(_dataDict: incrementalDataDict)
      }
    }

    var mergedErrors = self.errors
    if let incrementalErrors = incrementalResult.errors {
      if let currentErrors = mergedErrors {
        mergedErrors = currentErrors + incrementalErrors

      } else {
        mergedErrors = incrementalErrors
      }
    }

    var mergedExtensions = self.extensions
    if let incrementalExtensions = incrementalResult.extensions {
      if let currentExtensions = mergedExtensions {
        mergedExtensions = currentExtensions.merging(incrementalExtensions) { _, new in new }

      } else {
        mergedExtensions = incrementalExtensions
      }
    }

    var mergedDependentKeys = self.dependentKeys
    if let incrementalDependentKeys = incrementalResult.dependentKeys {
      if let currentDependentKeys = mergedDependentKeys {
        mergedDependentKeys = currentDependentKeys.union(incrementalDependentKeys)
      }
    }

    return GraphQLResult(
      data: mergedData,
      extensions: mergedExtensions,
      errors: mergedErrors,
      source: source,
      dependentKeys: mergedDependentKeys
    )
  }
}

// MARK: - Equatable/Hashable Conformance
extension GraphQLResult: Equatable where Data: Equatable {
  public static func == (lhs: GraphQLResult<Data>, rhs: GraphQLResult<Data>) -> Bool {
    lhs.data == rhs.data &&
    lhs.errors == rhs.errors &&
    lhs.extensions == rhs.extensions &&
    lhs.source == rhs.source &&
    lhs.dependentKeys == rhs.dependentKeys
  }
}

extension GraphQLResult: Hashable where Data: Hashable {}

extension GraphQLResult {

  /// Converts a ``GraphQLResult`` into a basic JSON dictionary for use.
  ///
  /// - Returns: A `[String: Any]` JSON dictionary representing the ``GraphQLResult``.
  public func asJSONDictionary() -> [String: Any] {
    var dict: [String: Any] = [:]
    if let data { dict["data"] = convert(value: data.__data) }
    if let errors { dict["errors"] = errors.map { $0.asJSONDictionary() } }
    if let extensions { dict["extensions"] = extensions }
    return dict
  }

  private func convert(value: Any) -> Any {
      var val: Any = value
      if let value = value as? ApolloAPI.DataDict {
          val = value._data
      } else if let value = value as? CustomScalarType {
          val = value._jsonValue
      }
      if let dict = val as? [String: Any] {
          return dict.mapValues(convert)
      } else if let arr = val as? [Any] {
          return arr.map(convert)
      }
      return val
  }
}

fileprivate extension DataDict {
  enum Error: Swift.Error, LocalizedError {
    case invalidPathDataType(String)
    case cannotOverwriteData(AnyHashable, AnyHashable)

    public var errorDescription: String? {
      switch self {
      case let .invalidPathDataType(got):
        return "Invalid data type for merge - \(got)"

      case let .cannotOverwriteData(current, new):
        return "Incremental merging cannot overwrite existing data \(current) with \(new)"
      }
    }
  }

  func merging(_ newDataDict: DataDict, at path: [PathComponent]) throws -> DataDict {
    guard let pathDataDict = (self[path] as? DataDict) else {
      throw Error.invalidPathDataType(String(describing: type(of: value)))
    }

    let mergedData = try pathDataDict._data.merging(newDataDict._data) { current, new in
      throw Error.cannotOverwriteData(current, new)
    }

    let mergedFulfilledFragments = pathDataDict._fulfilledFragments
      .union(newDataDict._fulfilledFragments)

    let mergedDeferredFragments = pathDataDict._deferredFragments
      .subtracting(newDataDict._fulfilledFragments)
      .union(newDataDict._deferredFragments)

    let mergedDataDict = DataDict(
      data: mergedData,
      fulfilledFragments: mergedFulfilledFragments,
      deferredFragments: mergedDeferredFragments
    )

    var result = self
    result[path] = mergedDataDict

    return result
  }
}
