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

  public enum Error: Swift.Error, LocalizedError {
    case missingPartialData

    public var errorDescription: String? {
      switch self {
      case .missingPartialData:
        return "Cannot find partial data for incremental merge."
      }
    }
  }

  /// Private storage of public properties that can be mutated tp merge an incremental result
  private var _data: Data?
  private var _errors: [GraphQLError]?
  private var _extensions: [String: AnyHashable]?
  private var _dependentKeys: Set<CacheKey>?

  /// The typed result data, or `nil` if an error was encountered that prevented a valid response.
  public var data: Data? { _data }
  /// A list of errors, or `nil` if the operation completed without encountering any errors.
  public var errors: [GraphQLError]? { _errors }
  /// A dictionary which services can use however they see fit to provide additional information to clients.
  public var extensions: [String: AnyHashable]? { _extensions }
  /// Source of data
  public let source: Source

  var dependentKeys: Set<CacheKey>? { _dependentKeys }

  public init(
    data: Data?,
    extensions: [String: AnyHashable]?,
    errors: [GraphQLError]?,
    source: Source,
    dependentKeys: Set<CacheKey>?
  ) {
    self._data = data
    self._extensions = extensions
    self._errors = errors
    self.source = source
    self._dependentKeys = dependentKeys
  }

  mutating func merging(
    _ incrementalResult: IncrementalGraphQLResult
  ) throws -> GraphQLResult<Data> {
    guard let data = self.data else {
      throw Error.missingPartialData
    }

    if let incrementalData = incrementalResult.data?.__data {
      try data.__data.merging(dataDict: incrementalData, at: incrementalResult.path)
    }

    if let incrementalErrors = incrementalResult.errors {
      if self._errors == nil {
        self._errors = []
      }

      self._errors?.append(contentsOf: incrementalErrors)
    }

    if let incrementalExtensions = incrementalResult.extensions {
      if self._extensions == nil {
        self._extensions = [:]
      }

      self._extensions?.merge(incrementalExtensions) { _, new in new }
    }

    if let incrementalDependentKeys = incrementalResult.dependentKeys {
      if self._dependentKeys == nil {
        self._dependentKeys = []
      }

      self._dependentKeys?.formUnion(incrementalDependentKeys)
    }

    return self
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
    case invalidPartialDataType(String)
    case cannotOverwriteData(AnyHashable, AnyHashable)

    public var errorDescription: String? {
      switch self {
      case let .invalidPartialDataType(got):
        return "Invalid data type for merge - \(got)"

      case let .cannotOverwriteData(current, new):
        return "Incremental merging cannot overwrite existing data \(current) with \(new)"
      }
    }
  }

  func merging(dataDict: DataDict, at path: [PathComponent]) throws {
    guard
      let partialValue = self[path],
      var partialDataDict = partialValue as? DataDict
    else {
      throw Error.invalidPartialDataType(String(describing: type(of: value)))
    }

    try partialDataDict._data.merge(dataDict._data) { current, new in
      throw Error.cannotOverwriteData(current, new)
    }

    partialDataDict._fulfilledFragments.formUnion(dataDict._fulfilledFragments)
    partialDataDict._deferredFragments.subtract(dataDict._fulfilledFragments)
    partialDataDict._deferredFragments.formUnion(dataDict._deferredFragments)
  }
}
