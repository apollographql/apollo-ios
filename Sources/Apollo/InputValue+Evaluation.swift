#if !COCOAPODS
import ApolloAPI
#endif
import Foundation

extension Selection.Field {
  public func cacheKey(with variables: GraphQLOperation.Variables?) throws -> String {
    if let arguments = arguments,
       case let argumentValues = try InputValue.evaluate(arguments, with: variables),
       !argumentValues.isEmpty {
      let argumentsKey = orderIndependentKey(for: argumentValues)
      return "\(name)(\(argumentsKey))"
    } else {
      return name
    }
  }

  private func orderIndependentKey(for object: JSONObject) -> String {
    return object.sorted { $0.key < $1.key }.map {
      switch $0.value {
      case let object as JSONObject:
        return "[\($0.key):\(orderIndependentKey(for: object))]"
      case let array as [JSONObject]:
        return "\($0.key):[\(array.map { orderIndependentKey(for: $0) }.joined(separator: ","))]"
      case let array as [JSONValue]:
        return "\($0.key):[\(array.map { String(describing: $0.base) }.joined(separator: ", "))]"
      case is NSNull:
        return "\($0.key):null"
      default:
        return "\($0.key):\($0.value.base)"
      }
    }.joined(separator: ",")
  }
}

extension InputValue {
  private func evaluate(with variables: GraphQLOperation.Variables?) throws -> JSONValue? {
    switch self {
    case let .variable(name):
      guard let value = variables?[name] else {
        throw GraphQLError("Variable \"\(name)\" was not provided.")
      }
      return value.jsonEncodableValue?.jsonValue

    case let .scalar(value):
      return value.jsonValue

    case let .list(array):
      return try InputValue.evaluate(array, with: variables)

    case let .object(dictionary):
      return try InputValue.evaluate(dictionary, with: variables)

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
