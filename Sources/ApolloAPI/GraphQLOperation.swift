public enum GraphQLOperationType {
  case query
  case mutation
  case subscription
}

public protocol GraphQLOperation: AnyObject {
  var operationType: GraphQLOperationType { get }

  var operationDefinition: String { get }
  var operationIdentifier: String? { get }
  var operationName: String { get }

  var queryDocument: String { get }

#warning("TODO: We need to support setting a null value AND a nil value. Considering just going back to using GraphQLMap, or else this should be [String: GraphQLOptional<InputValue>].")
  var variables: [String: InputValue]? { get }

  associatedtype Data: RootSelectionSet
}

public extension GraphQLOperation {
  var queryDocument: String {
    return operationDefinition
  }

  var operationIdentifier: String? {
    return nil
  }

  var variables: [String: InputValue]? {
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
