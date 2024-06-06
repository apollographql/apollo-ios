#if !COCOAPODS
import ApolloAPI
#endif

/// Represents the result of a GraphQL operation.
public struct GraphQLResult<Data: RootSelectionSet> {

  /// The typed result data, or `nil` if an error was encountered that prevented a valid response.
  public let data: Data?
  /// A list of errors, or `nil` if the operation completed without encountering any errors.
  public let errors: [GraphQLError]?
  /// A dictionary which services can use however they see fit to provide additional information to clients.
  public let extensions: [String: AnyHashable]?

  /// Represents source of data
  public enum Source: Hashable {
    case cache
    case server
  }
  /// Source of data
  public let source: Source

  let dependentKeys: Set<CacheKey>?

  public init(data: Data?,
              extensions: [String: AnyHashable]?,
              errors: [GraphQLError]?,
              source: Source,
              dependentKeys: Set<CacheKey>?) {
    self.data = data
    self.extensions = extensions
    self.errors = errors
    self.source = source
    self.dependentKeys = dependentKeys
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
      if let value = value as? DataDict {
          val = value._data
      } else if let value = value as? (any CustomScalarType) {
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
