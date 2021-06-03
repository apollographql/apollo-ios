public typealias GraphQLMap = [String: JSONEncodable?]

fileprivate extension Dictionary where Key == String, Value == JSONEncodable? {
  var withNilValuesRemoved: Dictionary<String, JSONEncodable> {
    filter { $0.value != nil }
  }
}

public protocol GraphQLMapConvertible: JSONEncodable {
  var graphQLMap: GraphQLMap { get }
}

public extension GraphQLMapConvertible {
  var jsonValue: JSONValue {
    return graphQLMap.withNilValuesRemoved.jsonValue
  }
}

public typealias GraphQLID = String
