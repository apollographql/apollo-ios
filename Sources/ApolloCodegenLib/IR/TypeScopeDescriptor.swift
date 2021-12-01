import Foundation
import ApolloUtils

typealias TypeScope = Set<GraphQLCompositeType>

/// Defines the scope for an `IR.SelectionSet`. The "scope" indicates where in the operation the
/// selection set is located and what types the `SelectionSet` implements.
struct TypeScopeDescriptor: Equatable {
  /// A list of the parent types for the selection set and it's parents on the same entity.
  ///
  /// The last element in the list is equal to the parent type for the `SelectionSet`
  ///
  /// For example, given the set of nested selections sets:
  /// ```
  /// object {
  ///  ... on A {
  ///   ... on B {
  ///     ... on C {
  ///       fieldOnABC
  ///     }
  ///   }
  /// }
  /// ```
  /// The typePath for the `SelectionSet` that includes field `fieldOnABC` would be:
  /// `[A, B, C]`.
  ///
  /// - Note: While the `fieldPath` indicates the path of different entities to the `SelectionSet`,
  /// `typePath` indicates the type cases of the `SelectionSet` on the same entity. The `fieldPath`
  /// for `SelectionSet`s on the same entity will be the same, while the `typePath` will differ
  /// across type cases.
  let typePath: LinkedList<GraphQLCompositeType>

  /// A list of path components indicating the path to the field containing the `SelectionSet` in
  /// an operation.
  ///
  /// For example, given the set of nested selections sets:
  /// ```
  /// object {
  ///  a {
  ///   b {
  ///     c {
  ///       fieldOnC
  ///     }
  ///   }
  /// }
  /// ```
  /// The fieldPath for the `SelectionSet` that includes field `fieldOnC` would be:
  /// `[object, a, b, c]`.
  ///
  /// - Note: While `typePath` indicates the type cases of the `SelectionSet` on the same entity, the
  /// `fieldPath` indicates the path of different entities to the `SelectionSet`. The `fieldPath`
  /// for `SelectionSet`s on the same entity will be the same, while the `typePath` will differ
  /// across type cases.
  let fieldPath: ResponsePath

  /// All of the types that the `SelectionSet` implements. That is, all of the types in the
  /// `typePath`, all of those types implemented interfaces, and all unions that include
  /// those types.
  let matchingTypes: TypeScope

  /// The parentType of the `SelectionSet`. Computed as the last value of the `typePath`.
  var type: GraphQLCompositeType { typePath.last.value }

  private let allTypesInSchema: CompilationResult.ReferencedTypes

  private init(
    typePath: LinkedList<GraphQLCompositeType>,
    fieldPath: ResponsePath,
    matchingTypes: TypeScope,
    allTypesInSchema: CompilationResult.ReferencedTypes
  ) {
    self.typePath = typePath
    self.fieldPath = fieldPath
    self.matchingTypes = matchingTypes
    self.allTypesInSchema = allTypesInSchema
  }

  /// Creates a `TypeScopeDescriptor` for a root `SelectionSet`.
  ///
  /// This should only be used to create a `TypeScopeDescriptor` for a root `SelectionSet`.
  /// Nested type cases should be created by calling `appending(_:)` on the
  /// parent `SelectionSet`'s `typeScope`.
  ///
  /// - Parameters:
  ///   - forType: The parentType for the entity.
  ///   - fieldPath: The path of fields to the entity in the operation.
  ///   - givenAllTypesInSchema: The `ReferencedTypes` object that provides information on all of
  ///                            the types in the schema.
  static func descriptor(
    forType type: GraphQLCompositeType,
    fieldPath: ResponsePath,
    givenAllTypesInSchema allTypes: CompilationResult.ReferencedTypes
  ) -> TypeScopeDescriptor {
    let scope = Self.typeScope(addingType: type, to: nil, givenAllTypes: allTypes)
    return TypeScopeDescriptor(typePath: LinkedList(type), fieldPath: fieldPath, matchingTypes: scope, allTypesInSchema: allTypes)
  }

  private static func typeScope(
    addingType newType: GraphQLCompositeType,
    to scope: TypeScope?,
    givenAllTypes allTypes: CompilationResult.ReferencedTypes
  ) -> TypeScope {
    if let scope = scope, scope.contains(newType) { return scope }

    var newScope = scope ?? []
    newScope.insert(newType)

    if let newType = newType as? GraphQLInterfaceImplementingType {
      newScope.formUnion(newType.interfaces)
      #warning("Do we need to recursively form union with each interfaces other interfaces? Test this.")
    }

    if let newType = newType as? GraphQLObjectType {
      newScope.formUnion(allTypes.unions(including: newType))
    }

    return newScope
  }

  /// Returns a new `TypeScopeDescriptor` appending the new type to the `typePath` and
  /// `matchingTypes`.
  ///
  /// This should be used to create a `TypeScopeDescriptor` for a type case `SelectionSet` inside
  /// of an entity, by appending the type case's type to the parent `SelectionSet`'s `typeScope`.
  func appending(_ newType: GraphQLCompositeType) -> TypeScopeDescriptor {
    let scope = Self.typeScope(addingType: newType,
                               to: self.matchingTypes,
                               givenAllTypes: self.allTypesInSchema)
    return TypeScopeDescriptor(
      typePath: typePath.appending(newType),
      fieldPath: fieldPath,
      matchingTypes: scope,
      allTypesInSchema: self.allTypesInSchema
    )
  }

  /// Indicates if the receiver is all of the types in the given `TypeScope`.
  /// If the receiver matches a `TypeScope`, then selections for a `SelectionSet` of that
  /// type scope can be merged in to the receiver's `SelectionSet`.
  func matches(_ otherScope: TypeScope) -> Bool {
    otherScope.isSubset(of: self.matchingTypes)
  }

  /// Indicates if the receiver is of the given type. If the receiver matches a given type,
  /// then selections for a `SelectionSet` of that type can be merged in to the receiver's
  /// `SelectionSet`.
  func matches(_ otherType: GraphQLCompositeType) -> Bool {
    self.matchingTypes.contains(otherType)
  }

  static func == (lhs: TypeScopeDescriptor, rhs: TypeScopeDescriptor) -> Bool {
    lhs.typePath == rhs.typePath &&
    lhs.fieldPath == rhs.fieldPath &&
    lhs.matchingTypes == rhs.matchingTypes
  }

}

extension TypeScopeDescriptor: CustomDebugStringConvertible {
  var debugDescription: String {
    typePath.debugDescription
  }
}
