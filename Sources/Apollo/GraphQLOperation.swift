public protocol GraphQLOperation: class {
  static var operationString: String { get }
  static var requestString: String { get }
  
  var variables: GraphQLMap? { get }
  
  associatedtype Data: GraphQLSelectionSet
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

public protocol GraphQLFragment: GraphQLSelectionSet {}
