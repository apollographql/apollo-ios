#if !COCOAPODS
import ApolloAPI
#endif
import Foundation

/// A global function that formats the the cache key for a field on an object.
///
/// `CacheKeyForField` represents the *key for a single field on an object* in a ``NormalizedCache``.
/// **This is not the cache key that represents an individual entity in the cache.**
///
/// - Parameters:
///   - fieldName: The name of the field to return a cache key for.
///   - arguments: The list of arguments used to compute the cache key.
/// - Returns: A formatted `String` to be used as the key for the field on an object in a
///            ``NormalizedCache``.
func CacheKeyForField(named fieldName: String, arguments: JSONObject) -> String {
  let argumentsKey = orderIndependentKey(for: arguments)
  return argumentsKey.isEmpty ? fieldName : "\(fieldName)(\(argumentsKey))"
}

fileprivate func orderIndependentKey(for object: JSONObject) -> String {
  return object.sorted { $0.key < $1.key }.map {
    switch $0.value {
    case let object as JSONObject:
      return "[\($0.key):\(orderIndependentKey(for: object))]"
    case let array as [JSONObject]:
      return "\($0.key):[\(array.map { orderIndependentKey(for: $0) }.joined(separator: ","))]"
    case let array as [JSONValue]:
      return "\($0.key):[\(array.map { String(describing: $0) }.joined(separator: ", "))]"
    case is NSNull:
      return "\($0.key):null"
    default:
      return "\($0.key):\($0.value)"
    }
  }.joined(separator: ",")
}

extension Selection.Field {
  public func cacheKey(with variables: GraphQLOperation.Variables?) throws -> String {
    if let arguments = arguments {
      let argumentValues = try InputValue.evaluate(arguments, with: variables)
      return CacheKeyForField(named: name, arguments: argumentValues)
    } else {
      return name
    }
  }
}

extension InputValue {
  private func evaluate(with variables: GraphQLOperation.Variables?) throws -> JSONValue? {
    switch self {
    case let .variable(name):
      guard let value = variables?[name] else {
        throw GraphQLError("Variable \"\(name)\" was not provided.")
      }
      return value._jsonEncodableValue?._jsonValue

    case let .scalar(value):
      return value._jsonValue

    case let .list(array):
      return try InputValue.evaluate(array, with: variables) as JSONValue

    case let .object(dictionary):
      return try InputValue.evaluate(dictionary, with: variables) as JSONValue

    case .null:
      return NSNull()
    }
  }

  fileprivate static func evaluate(
    _ values: [InputValue],
    with variables: GraphQLOperation.Variables?
  ) throws -> [JSONValue] {
    try values.compactMap { try $0.evaluate(with: variables) }
  }

  fileprivate static func evaluate(
    _ values: [String: InputValue],
    with variables: GraphQLOperation.Variables?
  ) throws -> JSONObject {
    try values.compactMapValues { try $0.evaluate(with: variables) }
  }
}
