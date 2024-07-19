import Foundation

public enum GraphQLOperationType: Hashable {
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
/// The Apollo Code Generation Engine will generate the ``OperationDocument`` on each generated
/// ``GraphQLOperation``. You can configure the the code generation engine to include the
/// ``OperationDefinition``, ``operationIdentifier``, or both using the `OperationDocumentFormat`
/// options in your `ApolloCodegenConfiguration`.
public struct OperationDocument: Sendable {
  public let operationIdentifier: String?
  public let definition: OperationDefinition?

  public init(
    operationIdentifier: String? = nil,
    definition: OperationDefinition? = nil
  ) {
    precondition(operationIdentifier != nil || definition != nil)
    self.operationIdentifier = operationIdentifier
    self.definition = definition
  }
}

/// The definition of an operation to be provided over network transport.
///
/// This data represents the `Definition` for a `Document` as defined in the GraphQL Spec.
/// In the case of the Apollo client, the definition will always be an `ExecutableDefinition`.
/// - See: [GraphQLSpec - Document](https://spec.graphql.org/draft/#Document)
public struct OperationDefinition: Sendable {
  let operationDefinition: String
  let fragments: [any Fragment.Type]?

  public init(_ definition: String, fragments: [any Fragment.Type]? = nil) {
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

/// A unique identifier used as a key to map a deferred selection set type to an incremental
/// response label and path.
public struct DeferredFragmentIdentifier: Hashable {
  let label: String
  let fieldPath: [String]

  public init(label: String, fieldPath: [String]) {
    self.label = label
    self.fieldPath = fieldPath
  }
}

// MARK: - GraphQLOperation

public protocol GraphQLOperation: AnyObject, Hashable {
  typealias Variables = [String: any GraphQLOperationVariableValue]

  static var operationName: String { get }
  static var operationType: GraphQLOperationType { get }
  static var operationDocument: OperationDocument { get }

  static var deferredFragments: [DeferredFragmentIdentifier: any SelectionSet.Type]? { get }

  var __variables: Variables? { get }

  associatedtype Data: RootSelectionSet
}

// MARK: Static Extensions

public extension GraphQLOperation {
  static var deferredFragments: [DeferredFragmentIdentifier: any SelectionSet.Type]? {
    return nil
  }

  static func deferredSelectionSetType<T: GraphQLOperation>(
    for operation: T.Type,
    withLabel label: String,
    atFieldPath fieldPath: [String]
  ) -> (any SelectionSet.Type)? {
    return T.deferredFragments?[DeferredFragmentIdentifier(label: label, fieldPath: fieldPath)]
  }

  static var hasDeferredFragments: Bool {
    return !(deferredFragments?.isEmpty ?? true)
  }

  static var definition: OperationDefinition? {
    operationDocument.definition
  }
  
  static var operationIdentifier: String? {
    operationDocument.operationIdentifier
  }

  static func ==(lhs: Self, rhs: Self) -> Bool {
    lhs.__variables?._jsonEncodableValue?._jsonValue == rhs.__variables?._jsonEncodableValue?._jsonValue
  }
}

// MARK: Instance Extensions

public extension GraphQLOperation {
  var __variables: Variables? {
    return nil
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(__variables?._jsonEncodableValue?._jsonValue)
  }
}

// MARK: - GraphQLQuery

public protocol GraphQLQuery: GraphQLOperation {}
public extension GraphQLQuery {
  @inlinable static var operationType: GraphQLOperationType { return .query }
}

// MARK: - GraphQLMutation

public protocol GraphQLMutation: GraphQLOperation {}
public extension GraphQLMutation {
  @inlinable static var operationType: GraphQLOperationType { return .mutation }
}

// MARK: - GraphQLSubscription

public protocol GraphQLSubscription: GraphQLOperation {}
public extension GraphQLSubscription {
  @inlinable static var operationType: GraphQLOperationType { return .subscription }
}

// MARK: - GraphQLOperationVariableValue

public protocol GraphQLOperationVariableValue {
  var _jsonEncodableValue: (any JSONEncodable)? { get }
}

extension Array: GraphQLOperationVariableValue
where Element: GraphQLOperationVariableValue & Hashable {}

extension Dictionary: GraphQLOperationVariableValue
where Key == String, Value == any GraphQLOperationVariableValue {
  @inlinable public var _jsonEncodableValue: (any JSONEncodable)? { _jsonEncodableObject }
  @inlinable public var _jsonEncodableObject: JSONEncodableDictionary {
    compactMapValues { $0._jsonEncodableValue }
  }
}

extension GraphQLNullable: GraphQLOperationVariableValue
where Wrapped: GraphQLOperationVariableValue {
  @inlinable public var _jsonEncodableValue: (any JSONEncodable)? {
    switch self {
    case .none: return nil
    case .null: return NSNull()
    case let .some(value): return value._jsonEncodableValue
    }
  }
}

extension Optional: GraphQLOperationVariableValue where Wrapped: GraphQLOperationVariableValue {
  @inlinable public var _jsonEncodableValue: (any JSONEncodable)? {
    switch self {
    case .none: return nil    
    case let .some(value): return value._jsonEncodableValue
    }
  }
}

extension JSONEncodable where Self: GraphQLOperationVariableValue {
  @inlinable public var _jsonEncodableValue: (any JSONEncodable)? { self }
}

// MARK: - Deprecations

@available(*, deprecated, renamed: "OperationDocument")
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

extension GraphQLOperation {
  @available(*, deprecated, renamed: "operationDocument")
  static public var document: DocumentType {
    switch (operationDocument.definition, operationDocument.operationIdentifier) {
    case let (definition?, id?):
      return .automaticallyPersisted(operationIdentifier: id, definition: definition)
    case let (definition?, .none):
      return .notPersisted(definition: definition)
    case let (.none, id?):
      return .persistedOperationsOnly(operationIdentifier: id)
    default:
      preconditionFailure("operationDocument must have either a definition or an identifier.")
    }
  }
}
