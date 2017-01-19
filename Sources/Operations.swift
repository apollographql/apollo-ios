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
