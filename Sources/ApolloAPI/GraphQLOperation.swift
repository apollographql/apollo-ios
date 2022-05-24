import Foundation

public enum GraphQLOperationType {
  case query
  case mutation
  case subscription
}

/// The means of providing the operation document that includes the definition of the operation
/// over network transport.
///
/// This data represents the `Document` as defined in the GraphQL Spec.
/// - See: [GraphQLSpec - Document](https://spec.graphql.org/draft/#Document)
///
/// The Apollo Code Generation Engine will generate the `DocumentType` on each generated
/// `GraphQLOperation`. You can change the type of `DocumentType` generated in your
/// [code generation configuration](// TODO: ADD URL TO DOCUMENTATION HERE).
public enum DocumentType {
  /// The traditional way of providing the operation `Document`.
  /// The `Document` is sent with every operation request.
  case notPersisted(definition: OperationDefinition)

  /// Automatically persists your operations using Apollo Server's
  /// [APQs](https://www.apollographql.com/docs/apollo-server/performance/apq).
  ///
  /// This allow the operation definition to be persisted using an `operationIdentifier` instead of
  /// being sent with every operation request. If the server does not recognize the
  /// `operationIdentifier`, the network transport can send the provided definition to
  /// "automatically persist" the operation definition.
  case automaticallyPersisted(operationIdentifier: String, definition: OperationDefinition)

  /// Provides only the `operationIdentifier` for operations that have been previously persisted
  /// to an Apollo Server using
  /// [APQs](https://www.apollographql.com/docs/apollo-server/performance/apq).
  ///
  /// If the server does not recognize the `operationIdentifier`, the operation will fail. This
  /// method should only be used if you are manually persisting your queries to an Apollo Server.  
  case persistedOperationsOnly(operationIdentifier: String)
}

/// The definition of an operation to be provided over network transport.
///
/// This data represents the `Definition` for a `Document` as defined in the GraphQL Spec.
/// In the case of the Apollo client, the definition will always be an `ExecutableDefinition`.
/// - See: [GraphQLSpec - Document](https://spec.graphql.org/draft/#Document)
public struct OperationDefinition {
  let operationDefinition: String
  let fragments: [Fragment.Type]?

  public init(_ definition: String, fragments: [Fragment.Type]? = nil) {
    self.operationDefinition = definition
    self.fragments = fragments
  }

  public var queryDocument: String {
    var document = operationDefinition
    fragments?.forEach {
      document.append("\n" + $0.fragmentDefinition.description)
    }
    return document
  }
}

public protocol GraphQLOperation: AnyObject {
  typealias Variables = [String: GraphQLOperationVariableValue]

  var operationName: String { get }
  var operationType: GraphQLOperationType { get }
  var document: DocumentType { get }

  var variables: Variables? { get }

  associatedtype Data: RootSelectionSet
}

public extension GraphQLOperation {
  var variables: Variables? {
    return nil
  }

  var definition: OperationDefinition? {
    switch self.document {
    case let .automaticallyPersisted(_, definition),
      let .notPersisted(definition):
      return definition
    default: return nil
    }
  }
  
  var operationIdentifier: String? {
    switch self.document {
    case let .automaticallyPersisted(identifier, _),
      let .persistedOperationsOnly(identifier):
      return identifier
    default: return nil
    }
  }
}

public protocol GraphQLQuery: GraphQLOperation {}
public extension GraphQLQuery {
  @inlinable var operationType: GraphQLOperationType { return .query }
}

public protocol GraphQLMutation: GraphQLOperation {}
public extension GraphQLMutation {
  @inlinable var operationType: GraphQLOperationType { return .mutation }
}

public protocol GraphQLSubscription: GraphQLOperation {}
public extension GraphQLSubscription {
  @inlinable var operationType: GraphQLOperationType { return .subscription }
}

// MARK: - GraphQLOperationVariableValue

public protocol GraphQLOperationVariableValue {
  var jsonEncodableValue: JSONEncodable? { get }
}

extension Array: GraphQLOperationVariableValue where Element: GraphQLOperationVariableValue {}

extension Dictionary: GraphQLOperationVariableValue where Key == String, Value == GraphQLOperationVariableValue {
  @inlinable public var jsonEncodableValue: JSONEncodable? { jsonEncodableObject }
  @inlinable public var jsonEncodableObject: JSONEncodableDictionary {
    compactMapValues { $0.jsonEncodableValue }
  }
}

extension GraphQLNullable: GraphQLOperationVariableValue where Wrapped: GraphQLOperationVariableValue {
  @inlinable public var jsonEncodableValue: JSONEncodable? {
    switch self {
    case .none: return nil
    case .null: return NSNull()
    case let .some(value): return value.jsonEncodableValue
    }
  }
}

extension Optional: GraphQLOperationVariableValue where Wrapped: GraphQLOperationVariableValue {
  @inlinable public var jsonEncodableValue: JSONEncodable? {
    switch self {
    case .none: return nil    
    case let .some(value): return value.jsonEncodableValue
    }
  }
}

extension JSONEncodable where Self: GraphQLOperationVariableValue {
  @inlinable public var jsonEncodableValue: JSONEncodable? { self }
}
