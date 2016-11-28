public typealias GraphQLInputValue = JSONEncodable

public typealias GraphQLMap = [String: GraphQLInputValue]

public typealias GraphQLID = String

public protocol GraphQLMapConvertible: JSONEncodable {
  var graphQLMap: GraphQLMap { get }
}

extension GraphQLMapConvertible {
  public var jsonValue: JSONValue {
    return graphQLMap.jsonValue
  }
}

public protocol GraphQLMappable {
  init(reader: GraphQLResultReader) throws
}

public struct GraphQLResult<Data> {
  public let data: Data?
  public let errors: [GraphQLError]?
  
  init(data: Data?, errors: [GraphQLError]?) {
    self.data = data
    self.errors = errors
  }
}

public struct GraphQLError: Error {
  let message: String
}

extension GraphQLError: GraphQLMappable {
  public init(reader: GraphQLResultReader) throws {
    message = try reader.value(for: Field(responseName: "message"))
  }
}

public protocol GraphQLOperation {
  static var operationDefinition: String { get }
  static var queryDocument: String { get }
  var variables: GraphQLMap? { get }
  
  associatedtype Data: GraphQLMappable
}

public extension GraphQLOperation {
  var variables: GraphQLMap? {
    return nil
  }
  
  static var queryDocument: String {
    return operationDefinition
  }
}

public protocol GraphQLQuery: GraphQLOperation {}

public protocol GraphQLMutation: GraphQLOperation {}

public protocol GraphQLConditionalFragment: GraphQLMappable {
  static var possibleTypes: [String] { get }
  
  init?(reader: GraphQLResultReader, ifTypeMatches typeName: String) throws
}

public extension GraphQLConditionalFragment {
  init?(reader: GraphQLResultReader, ifTypeMatches typeName: String) throws {
    if !Self.possibleTypes.contains(typeName) { return nil }
    
    try self.init(reader: reader)
  }
}

public protocol GraphQLNamedFragment: GraphQLConditionalFragment {
  static var fragmentDefinition: String { get }
}

public struct Field {
  let responseName: String
  let fieldName: String
  let arguments: GraphQLMap?
  
  public init(responseName: String, fieldName: String? = nil, arguments: GraphQLMap? = nil) {
    self.responseName = responseName
    self.fieldName = fieldName ?? responseName
    self.arguments = arguments
  }
}

public typealias GraphQLResolver = (_ field: Field, _ object: JSONObject?, _ info: GraphQLResolveInfo) -> JSONValue?

public final class GraphQLResolveInfo {
  var path: [String] = []
}
