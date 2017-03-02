public protocol GraphQLOperation: class {
  static var operationString: String { get }
  static var requestString: String { get }
  
  static var selectionSet: [Selection] { get }
  
  var variables: GraphQLMap? { get }
  
  associatedtype Data: GraphQLMappable
}

public extension GraphQLOperation {
  static var requestString: String {
    return operationString
  }
  
  var variables: GraphQLMap? {
    return nil
  }
}

public protocol GraphQLQuery: GraphQLOperation {}

public protocol GraphQLMutation: GraphQLOperation {}

public protocol GraphQLFragment: GraphQLMappable {
  static var possibleTypes: [String] { get }
  static var selectionSet: [Selection] { get }
}
