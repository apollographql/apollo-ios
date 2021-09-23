#if !COCOAPODS
import ApolloAPI
#endif
import Foundation

extension Selection.Field {
  func cacheKey(with variables: GraphQLOperation.Variables?) throws -> String {
    if let arguments = arguments,
       case let argumentValues = try InputValue.evaluate(arguments, with: variables),
       argumentValues.apollo.isNotEmpty {
      let argumentsKey = orderIndependentKey(for: argumentValues)
      return "\(name)(\(argumentsKey))"
    } else {
      return name
    }
  }

  private func orderIndependentKey(for object: JSONObject) -> String {
    return object.sorted { $0.key < $1.key }.map {
      if let object = $0.value as? JSONObject {
        return "[\($0.key):\(orderIndependentKey(for: object))]"
      } else if let array = $0.value as? [JSONObject] {
        return "\($0.key):[\(array.map { orderIndependentKey(for: $0) }.joined(separator: ","))]"
      } else {
        return "\($0.key):\($0.value)"
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
      return value

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
    var jsonObject = JSONObject(minimumCapacity: values.count)
    for (key, value) in values {
      let evaluatedValue = try value.evaluate(with: variables)
      if !(evaluatedValue is NSNull) {
        jsonObject[key] = evaluatedValue
      }
    }
    return jsonObject
  }
}
