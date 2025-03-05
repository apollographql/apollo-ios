#if !COCOAPODS
import ApolloMigrationAPI
#endif

public enum RootSelectionSetInitializeError: Error {
  case hasNonHashableValue
}

extension RootSelectionSet {
  /// Initializes a `SelectionSet` with a raw JSON response object.
  ///
  /// The process of converting a JSON response into `SelectionSetData` is done by using a
  /// `GraphQLExecutor` with a`GraphQLSelectionSetMapper` to parse, validate, and transform
  /// the JSON response data into the format expected by `SelectionSet`.
  ///
  /// - Parameters:
  ///   - data: A dictionary representing a JSON response object for a GraphQL object.
  ///   - variables: [Optional] The operation variables that would be used to obtain
  ///                the given JSON response data.
  @_disfavoredOverload
  public init(
    data: [String: Any],
    variables: GraphQLOperation.Variables? = nil
  ) throws {
    let jsonObject = try Self.convertToAnyHashableValueDict(dict: data)
    try self.init(data: jsonObject, variables: variables)
  }
  
  /// Convert dictionary type [String: Any] to [String: AnyHashable]
  /// - Parameter dict: [String: Any] type dictionary
  /// - Returns: converted [String: AnyHashable] type dictionary
  private static func convertToAnyHashableValueDict(dict: [String: Any]) throws -> [String: AnyHashable] {
    var result = [String: AnyHashable]()
    
    for (key, value) in dict {
      if let arrayValue = value as? [Any] {
        result[key] = try convertToAnyHashableArray(array: arrayValue)
      } else  {
        if let dictValue = value as? [String: Any] {
          result[key] = try convertToAnyHashableValueDict(dict: dictValue)
        } else if let hashableValue = value as? AnyHashable {
          result[key] = hashableValue
        } else {
          throw RootSelectionSetInitializeError.hasNonHashableValue
        }
      }
    }
    return result
  }

  /// Convert Any type Array type to AnyHashable type Array
  /// - Parameter array: Any type Array
  /// - Returns: AnyHashable type Array
  private static func convertToAnyHashableArray(array: [Any]) throws -> [AnyHashable] {
    var result: [AnyHashable] = []
    for value in array {
      if let array = value as? [Any] {
        result.append(try convertToAnyHashableArray(array: array))
      } else if let dict = value as? [String: Any] {
        result.append(try convertToAnyHashableValueDict(dict: dict))
      } else if let hashable = value as? AnyHashable {
        result.append(hashable)
      } else {
        throw RootSelectionSetInitializeError.hasNonHashableValue
      }
    }
    return result
  }
}
