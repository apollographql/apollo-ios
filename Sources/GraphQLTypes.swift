public typealias GraphQLInputValue = JSONEncodable

public typealias GraphQLMap = [String: GraphQLInputValue]

public protocol GraphQLMapConvertible: JSONEncodable {
  var graphQLMap: GraphQLMap { get }
}

extension GraphQLMapConvertible {
  public var jsonValue: JSONValue {
    return graphQLMap.jsonValue
  }
}

public typealias GraphQLID = String

public protocol GraphQLMappable {
  init(reader: GraphQLResultReader) throws
}
