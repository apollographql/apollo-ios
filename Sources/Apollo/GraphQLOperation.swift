public enum GraphQLOperationType {
  case query
  case mutation
  case subscription
}

public protocol GraphQLOperation: class {
  var operationType: GraphQLOperationType { get }
  
  var operationDefinition: String { get }
  var operationIdentifier: String? { get }
  
  var queryDocument: String { get }
  
  var variables: GraphQLMap? { get }

  ///Used for multi-part form uploading
  var map: GraphQLMap? { get }

  ///Used for multi-part form uploading
  var uploads: [GraphQLUpload]? { get }
  
  associatedtype Data: GraphQLSelectionSet
}

public extension GraphQLOperation {
  var queryDocument: String {
    return operationDefinition
  }

  var operationIdentifier: String? {
    return nil
  }

  var variables: GraphQLMap? {
    return nil
  }

  ///Used for multi-part form uploading
  var map: GraphQLMap? {
    return nil
  }

  ///Used for multi-part form uploading
  var uploads: [GraphQLUpload]? {
    return nil
  }
}

public protocol GraphQLQuery: GraphQLOperation {}
public extension GraphQLQuery {
  var operationType: GraphQLOperationType { return .query }
}

public protocol GraphQLMutation: GraphQLOperation {}
public extension GraphQLMutation {
  var operationType: GraphQLOperationType { return .mutation }
}

public protocol GraphQLSubscription: GraphQLOperation {}
public extension GraphQLSubscription {
  var operationType: GraphQLOperationType { return .subscription }
}

public protocol GraphQLFragment: GraphQLSelectionSet {
  static var fragmentDefinition: String { get }
  static var possibleTypes: [String] { get }
}
