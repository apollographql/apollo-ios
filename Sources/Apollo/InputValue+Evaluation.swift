#if !COCOAPODS
import ApolloAPI
#endif
import Foundation

extension InputValue {
  func evaluate(with variables: [String: JSONEncodable]?) throws -> JSONValue {
    switch self {
    case .scalar(let scalar as JSONEncodable):
      return scalar.jsonValue

    case .scalar(let scalar):
      throw GraphQLError("Scalar value \(scalar) is not JSONEncodable.")

    case .variable(let name):
      guard let value = variables?[name] else {
        throw GraphQLError("Variable \(name) was not provided.")
      }
      return value.jsonValue

    case .list(let array):
      return try evaluate(values: array, with: variables)

    case .object(let dictionary):
      return try evaluate(values: dictionary, with: variables)

    case .none:
      return NSNull()
    }
  }

  private func evaluate(values: [InputValue], with variables: [String: JSONEncodable]?) throws -> JSONValue {
    return try evaluate(values: values, with: variables) as [JSONValue]
  }

  private func evaluate(values: [InputValue], with variables: [String: JSONEncodable]?) throws -> [JSONValue] {
    try values.map { try $0.evaluate(with: variables) }
  }

  private func evaluate(values: [String: InputValue], with variables: [String: JSONEncodable]?) throws -> JSONValue {
    return try evaluate(values: values, with: variables) as JSONObject
  }

  private func evaluate(values: [String: InputValue], with variables: [String: JSONEncodable]?) throws -> JSONObject {
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
