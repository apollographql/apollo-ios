/// Enumeration of the possible GraphQL operations that can be executed against an API endpoint.
public enum GraphQLOperationType {
  case query
  case mutation
  case subscription

  var cacheKey: String {
    switch self {
    case .query: return "QUERY_ROOT"
    case .mutation: return "MUTATION_ROOT"
    case .subscription: return "SUBSCRIPTION_ROOT"
    }
  }
}

public protocol GraphQLOperation: AnyObject {
  var operationType: GraphQLOperationType { get }

  var operationDefinition: String { get }
  var operationIdentifier: String? { get }
  var operationName: String { get }

  var queryDocument: String { get }

  var variables: GraphQLMap? { get }

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
}

// - MARK: Conformances

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
