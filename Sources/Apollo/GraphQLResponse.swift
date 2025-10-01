@_spi(Internal) @_spi(Unsafe) import ApolloAPI

/// Represents the result of a GraphQL operation, including the response data as well as any ``GraphQLError``s
/// or extension data included in the response.
public struct GraphQLResponse<Operation: GraphQLOperation>: Sendable {

  /// Represents the source of the response's data
  public enum Source: Sendable, Hashable {
    /// Indicates response data was fetched from a local cache
    case cache
    /// Indicates response data was fetched from a remote server
    case server
  }

  /// The typed result data, or `nil` if an error was encountered that prevented a valid response.
  public let data: Operation.Data?
  /// A list of errors, or `nil` if the operation completed without encountering any errors.
  public let errors: [GraphQLError]?
  /// A dictionary which services can use however they see fit to provide additional information to clients.
  public let extensions: JSONObject?
  /// Source of data
  public let source: Source

  /// The cache keys for the fields that were included in this response. Custom ``ApolloStoreSubscriber``s can use these
  /// keys to understand when changes to the cache would affect the result of a specific response.
  @_spi(Execution)
  public let dependentKeys: Set<CacheKey>?

  public init(
    data: Operation.Data?,
    extensions: JSONObject?,
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

  func merging(_ incrementalResult: IncrementalGraphQLResult) throws -> GraphQLResponse<Operation> {
    let mergedDataDict = try merge(
      incrementalResult.data?.__data,
      into: self.data?.__data
    ) { currentDataDict, incrementalDataDict in
      try currentDataDict.merging(incrementalDataDict, at: incrementalResult.path)
    }
    var mergedData: Operation.Data? = nil
    if let mergedDataDict {
      mergedData = Operation.Data(_dataDict: mergedDataDict)
    }

    let mergedErrors = try merge(
      incrementalResult.errors,
      into: self.errors
    ) { currentErrors, incrementalErrors in
      currentErrors + incrementalErrors
    }

    let mergedExtensions = try merge(
      incrementalResult.extensions,
      into: self.extensions
    ) { currentExtensions, incrementalExtensions in
      currentExtensions.merging(incrementalExtensions) { _, new in new }
    }

    let mergedDependentKeys = try merge(
      incrementalResult.dependentKeys,
      into: self.dependentKeys
    ) { currentDependentKeys, incrementalDependentKeys in
      currentDependentKeys.union(incrementalDependentKeys)
    }

    return GraphQLResponse(
      data: mergedData,
      extensions: mergedExtensions,
      errors: mergedErrors,
      source: source,
      dependentKeys: mergedDependentKeys
    )
  }

  fileprivate func merge<T>(
    _ newValue: T?,
    into currentValue: T?,
    onMerge: (_ currentValue: T, _ newValue: T) throws -> T
  ) throws -> T? {
    switch (currentValue, newValue) {
    case let (currentValue, nil):
      return currentValue

    case let (.some(currentValue), .some(newValue)):
      return try onMerge(currentValue, newValue)

    case let (nil, newValue):
      return newValue
    }
  }
}

// MARK: - Equatable/Hashable Conformance
extension GraphQLResponse: Equatable where Operation.Data: Equatable {
  public static func == (lhs: GraphQLResponse<Operation>, rhs: GraphQLResponse<Operation>) -> Bool {
    lhs.data == rhs.data &&
    lhs.errors == rhs.errors &&
    AnySendableHashable.equatableCheck(lhs.extensions, rhs.extensions) &&
    lhs.source == rhs.source &&
    lhs.dependentKeys == rhs.dependentKeys
  }
}

extension GraphQLResponse: Hashable where Operation.Data: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(data)
    hasher.combine(errors)
    hasher.combine(extensions)
    hasher.combine(source)
    hasher.combine(dependentKeys)
  }
}

extension GraphQLResponse {

  /// Converts a ``GraphQLResponse`` into a basic JSON dictionary for use.
  ///
  /// - Returns: A `[String: Any]` JSON dictionary representing the ``GraphQLResponse``.
  public func asJSONDictionary() -> [String: Any] {
    var dict: [String: Any] = [:]
    if let data { dict["data"] = JSONConverter.convert(data) }
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
