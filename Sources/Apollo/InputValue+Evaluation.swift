#if !COCOAPODS
import ApolloAPI
#endif
import Foundation

extension Selection.Field {
  func cacheKey(with variables: [String: InputValue]?) throws -> String {
    if
      let argumentValues = try arguments?.evaluate(with: variables),
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

extension Selection.Field.Arguments {

  func evaluate(with variables: [String: InputValue]?) throws -> JSONObject {
    /// `Selection.Field.Arguments` can only ever hold arguments of `.object` type. Which will
    /// always resolve to an `.object` value. So force casting to `JSONObject` is safe.
    return try arguments.evaluate(with: variables) as! JSONObject
  }
}

extension InputValue {
  func evaluate(with variables: [String: InputValue]?) throws -> JSONValue {
    switch self {
    case let .scalar(value):
      return value

    case let .variable(name):
      guard let value = variables?[name] else {
        throw GraphQLError("Variable \"\(name)\" was not provided.")
      }

      switch value {
      case let .variable(nestedName) where name == nestedName:
        throw GraphQLError("Variable \"\(name)\" is infinitely recursive.")
      default:
        return try value.evaluate(with: variables)
      }

    case let .list(array):
      return try evaluate(values: array, with: variables)

    case let .object(dictionary):
      return try evaluate(values: dictionary, with: variables)

    case .none:
      return NSNull()
    }
  }

  private func evaluate(values: [InputValue], with variables: [String: InputValue]?) throws -> [JSONValue] {
    try values.map { try $0.evaluate(with: variables) }
  }

  private func evaluate(values: [String: InputValue], with variables: [String: InputValue]?) throws -> JSONObject {
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
