public typealias GraphQLID = String

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

extension GraphQLError: GraphQLMapDecodable {
  public init(map: GraphQLMap) throws {
    message = try map.value(forKey: "message")
  }
}

public typealias GraphQLOperationResponseHandler<Operation: GraphQLOperation> = (GraphQLResult<Operation.Data>?, Error?) -> Void

public protocol GraphQLOperation {
  static var operationDefinition: String { get }
  static var queryDocument: String { get }
  var variables: GraphQLMap? { get }

  associatedtype Data: GraphQLMapDecodable
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

public protocol GraphQLConditionalFragment: GraphQLMapDecodable {
  static var possibleTypes: [String] { get }

  init?(map: GraphQLMap, ifTypeMatches typeName: String) throws
}

public extension GraphQLConditionalFragment {
  init?(map: GraphQLMap, ifTypeMatches typeName: String) throws {
    if !Self.possibleTypes.contains(typeName) { return nil }

    try self.init(map: map)
  }
}

public protocol GraphQLNamedFragment: GraphQLConditionalFragment {
  static var fragmentDefinition: String { get }
}
