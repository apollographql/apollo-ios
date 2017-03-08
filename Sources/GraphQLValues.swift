public protocol GraphQLInputValue {
  func evaluate(with variables: [String: JSONEncodable]?) throws -> JSONValue
}

public struct Variable {
  let name: String
  
  public init(_ name: String) {
    self.name = name
  }
}

extension Variable: GraphQLInputValue {
  public func evaluate(with variables: [String: JSONEncodable]?) throws -> JSONValue {
    guard let value = variables?[name] else {
      throw GraphQLError("Variable \(name) was not provided.")
    }
    return value.jsonValue
  }
}

extension JSONEncodable {
  public func evaluate(with variables: [String: JSONEncodable]?) throws -> JSONValue {
    return jsonValue
  }
}

extension Dictionary: GraphQLInputValue {
  public func evaluate(with variables: [String: JSONEncodable]?) throws -> JSONValue {
    return try evaluate(with: variables)
  }
  
  public func evaluate(with variables: [String: JSONEncodable]?) throws -> JSONObject {
    var jsonObject = JSONObject(minimumCapacity: count)
    for (key, value) in self {
      if case let (key as String, value as GraphQLInputValue) = (key, value) {
        let evaluatedValue = try value.evaluate(with: variables)
        if !(evaluatedValue is NSNull) {
          jsonObject[key] = evaluatedValue
        }
      } else {
        fatalError("Dictionary is only GraphQLInputValue if Value is (and if Key is String)")
      }
    }
    return jsonObject
  }
}

public typealias GraphQLMap = [String: JSONEncodable]

public protocol GraphQLMapConvertible: JSONEncodable {
  var graphQLMap: GraphQLMap { get }
}

public extension GraphQLMapConvertible {
  var jsonValue: JSONValue {
    return graphQLMap.jsonValue
  }
}

public extension GraphQLMapConvertible {
  func evaluate(with variables: [String: JSONEncodable]?) throws -> JSONValue {
    return try graphQLMap.evaluate(with: variables)
  }
}

public typealias GraphQLID = String
