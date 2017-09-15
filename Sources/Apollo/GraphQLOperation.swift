public protocol GraphQLOperation: class {
  static var rootCacheKey: String { get }
  
  static var operationString: String { get }
  static var requestString: String { get }
  static var operationIdentifier: String? { get }
  
  var variables: GraphQLMap? { get }
  
  associatedtype Data: GraphQLSelectionSet
}

public extension GraphQLOperation {
  static var requestString: String {
    return operationString
  }

  static var operationIdentifier: String? {
    return nil
  }

  var variables: GraphQLMap? {
    return nil
  }
}

public protocol GraphQLQuery: GraphQLOperation {}
public extension GraphQLQuery {
  static var rootCacheKey: String { return "QUERY_ROOT" }
}

public protocol GraphQLMutation: GraphQLOperation {}
public extension GraphQLMutation {
  static var rootCacheKey: String { return "MUTATION_ROOT" }
}

public protocol GraphQLFragment: GraphQLSelectionSet {
  static var possibleTypes: [String] { get }
}
