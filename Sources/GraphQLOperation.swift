public protocol GraphQLOperation: class {
  static var operationDefinition: String { get }
  static var queryDocument: String { get }
  
  var variables: GraphQLMap? { get }
  
  associatedtype Data: GraphQLMappable
}

public extension GraphQLOperation {
  static var queryDocument: String {
    return operationDefinition
  }
  
  var variables: GraphQLMap? {
    return nil
  }
}

public protocol GraphQLQuery: GraphQLOperation {}

public protocol GraphQLMutation: GraphQLOperation {}
