import Foundation

/// For backwards compatibility with legacy codegen.
/// The `GraphQLVariable` class has been replaced by `InputValue.variable`
public func GraphQLVariable(_ name: String) -> InputValue {
  return .variable(name)
}

public indirect enum InputValue {
  case scalar(JSONEncodable)
  case variable(String)
  case list([InputValue])
  case object([String: InputValue])
  case none

  public func evaluate(with variables: [String: JSONEncodable]?) throws -> JSONValue {
    switch self {
    case .scalar(let scalar):
      return scalar.jsonValue

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
}

extension InputValue: ExpressibleByNilLiteral {
  @inlinable public init(nilLiteral: ()) {
    self = .none
  }
}

extension InputValue: ExpressibleByStringLiteral {
  @inlinable public init(stringLiteral value: StringLiteralType) {
    self = .scalar(value)
  }
}

extension InputValue: ExpressibleByIntegerLiteral {
  @inlinable public init(integerLiteral value: IntegerLiteralType) {
    self = .scalar(value)
  }
}

extension InputValue: ExpressibleByFloatLiteral {
  @inlinable public init(floatLiteral value: FloatLiteralType) {
    self = .scalar(value)
  }
}

extension InputValue: ExpressibleByBooleanLiteral {
  @inlinable public init(booleanLiteral value: BooleanLiteralType) {
    self = .scalar(value)
  }
}

extension InputValue: ExpressibleByArrayLiteral {
  @inlinable public init(arrayLiteral elements: InputValue...) {
    self = .list(Array(elements))
  }

  public func evaluate(values: [InputValue], with variables: [String: JSONEncodable]?) throws -> JSONValue {
    return try evaluate(values: values, with: variables) as [JSONValue]
  }

  public func evaluate(values: [InputValue], with variables: [String: JSONEncodable]?) throws -> [JSONValue] {
    try values.map { try $0.evaluate(with: variables) }
  }
}

extension InputValue: ExpressibleByDictionaryLiteral {
  public init(dictionaryLiteral elements: (String, InputValue)...) {
    self = .object(Dictionary(elements))
  }

  public func evaluate(values: [String: InputValue], with variables: [String: JSONEncodable]?) throws -> JSONValue {
    return try evaluate(values: values, with: variables) as JSONObject
  }

  public func evaluate(values: [String: InputValue], with variables: [String: JSONEncodable]?) throws -> JSONObject {
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
