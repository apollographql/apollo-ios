import Foundation
import ApolloUtils

typealias TypeScope = Set<GraphQLCompositeType>

/// Defines the scope for an `IR.SelectionSet`. The scope is derived from the scope and all of its
/// parent scopes.
struct TypeScopeDescriptor: Equatable {
  let typePath: LinkedList<GraphQLCompositeType>
  let fieldPath: ResponsePath
  let scope: TypeScope
  private let allTypes: CompilationResult.ReferencedTypes

  var type: GraphQLCompositeType { typePath.last.value }

  private init(
    typePath: LinkedList<GraphQLCompositeType>,
    fieldPath: ResponsePath,
    scope: TypeScope,
    allTypes: CompilationResult.ReferencedTypes
  ) {
    self.typePath = typePath
    self.fieldPath = fieldPath
    self.scope = scope
    self.allTypes = allTypes
  }

  static func descriptor(
    forType type: GraphQLCompositeType,
    fieldPath: ResponsePath,
    givenAllTypes allTypes: CompilationResult.ReferencedTypes
  ) -> TypeScopeDescriptor {
    let scope = Self.typeScope(addingType: type, to: nil, givenAllTypes: allTypes)
    return TypeScopeDescriptor(typePath: LinkedList(type), fieldPath: fieldPath, scope: scope, allTypes: allTypes)
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

  func matches(_ otherScope: TypeScope) -> Bool {
    otherScope.isSubset(of: self.scope)
  }

  func matches(_ otherType: GraphQLCompositeType) -> Bool {
    self.scope.contains(otherType)
  }

  func appending(_ newType: GraphQLCompositeType) -> TypeScopeDescriptor {
    let scope = Self.typeScope(addingType: newType,
                               to: self.scope,
                               givenAllTypes: self.allTypes)
    return TypeScopeDescriptor(
      typePath: typePath.appending(newType),
      fieldPath: fieldPath,
      scope: scope,
      allTypes: self.allTypes
    )
  }

  static func == (lhs: TypeScopeDescriptor, rhs: TypeScopeDescriptor) -> Bool {
    lhs.typePath == rhs.typePath &&
    lhs.fieldPath == rhs.fieldPath &&
    lhs.scope == rhs.scope
  }

}

extension TypeScopeDescriptor: CustomDebugStringConvertible {
  var debugDescription: String {
    typePath.debugDescription
  }
}
