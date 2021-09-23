import Foundation

public enum GraphQLOperationType {
  case query
  case mutation
  case subscription
}

public protocol GraphQLOperation: AnyObject {
  typealias Variables = [String: GraphQLOperationVariableValue]

  var operationType: GraphQLOperationType { get }

  var operationDefinition: String { get }
  var operationIdentifier: String? { get }
  var operationName: String { get }

  var queryDocument: String { get }

  var variables: Variables? { get }

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

// MARK: - GraphQLOperationVariableValue

public protocol GraphQLOperationVariableValue {
  var jsonEncodableValue: JSONEncodable? { get }
}

extension Array: GraphQLOperationVariableValue where Element: GraphQLOperationVariableValue {}

extension Dictionary: GraphQLOperationVariableValue where Key == String, Value == GraphQLOperationVariableValue {
  public var jsonEncodableValue: JSONEncodable? { jsonEncodableObject }
  public var jsonEncodableObject: JSONEncodableDictionary {
    compactMapValues { $0.jsonEncodableValue }
  }
}

extension Nullable: GraphQLOperationVariableValue where Wrapped: JSONEncodable {
  public var jsonEncodableValue: JSONEncodable? {
    switch self {
    case .none: return nil
    case .null: return NSNull()
    case let .some(value): return value
    }
  }
}

extension JSONEncodable where Self: GraphQLOperationVariableValue {
  public var jsonEncodableValue: JSONEncodable? { self }
}
