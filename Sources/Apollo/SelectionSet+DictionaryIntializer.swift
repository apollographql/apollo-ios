import ApolloAPI

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
  ) async throws {
    let jsonObject = try Self.convertToSendableHashableValueDict(dict: data)
    try await self.init(data: jsonObject, variables: variables)
  }
  
  /// Convert dictionary type [String: Any] to [String: any Sendable & Hashable]
  /// - Parameter dict: [String: Any] type dictionary
  /// - Returns: converted [String: any Sendable & Hashable] type dictionary
  private static func convertToSendableHashableValueDict(dict: [String: Any]) throws -> JSONObject {
    var result = JSONObject()

    for (key, value) in dict {
      if let arrayValue = value as? [Any] {
        result[key] = try convertToSendableHashableArray(array: arrayValue) as JSONValue
      } else  {
        if let dictValue = value as? [String: Any] {
          result[key] = try convertToSendableHashableValueDict(dict: dictValue) as JSONValue
        } else if value is any Hashable {
          // Conditional casts to compositions with the marker protocol `Sendable` are not allowed, so we verify `Hashable` conformance and force cast (matching `JSONSerializationFormat`).
          let hashableValue = value as! JSONValue
          result[key] = hashableValue
        } else {
          throw RootSelectionSetInitializeError.hasNonHashableValue
        }
      }
    }
    return result
  }

  /// Convert Any type Array type to (any Sendable & Hashable) type Array
  /// - Parameter array: Any type Array
  /// - Returns: (any Sendable & Hashable) type Array
  private static func convertToSendableHashableArray(array: [Any]) throws -> [JSONValue] {
    var result: [JSONValue] = []
    for value in array {
      if let array = value as? [Any] {
        result.append(try convertToSendableHashableArray(array: array) as JSONValue)
      } else if let dict = value as? [String: Any] {
        result.append(try convertToSendableHashableValueDict(dict: dict) as JSONValue)
      } else if value is any Hashable {
        // Conditional casts to compositions with the marker protocol `Sendable` are not allowed, so we verify `Hashable` conformance and force cast (matching `JSONSerializationFormat`).
        result.append(value as! JSONValue)
      } else {
        throw RootSelectionSetInitializeError.hasNonHashableValue
      }
    }
    return result
  }
}
