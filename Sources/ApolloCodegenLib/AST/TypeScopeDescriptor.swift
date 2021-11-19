import Foundation

typealias TypeScope = Set<GraphQLCompositeType>

/// Defines the scope for an `ASTSelectionSet`. The scope is derived from the scope and all of its
/// parent scopes.
struct TypeScopeDescriptor: Equatable {
  let scope: TypeScope!

  private init() {
    self.scope = nil
  }

  private init(scope: TypeScope) {
    self.scope = scope
  }

  static func descriptor(
    for type: GraphQLCompositeType,
    givenAllTypes allTypes: CompilationResult.ReferencedTypes
  ) -> TypeScopeDescriptor {
    TypeScopeDescriptor().appending(type, givenAllTypes: allTypes)
  }

  static func descriptor(for selectionSet: ASTSelectionSet) -> TypeScopeDescriptor {
    let allTypes = selectionSet.compilationResult.referencedTypes
    let parentDescriptor = selectionSet.parent?.scopeDescriptor ?? TypeScopeDescriptor()
    return parentDescriptor.appending(selectionSet.type, givenAllTypes: allTypes)
  }

  func matches(_ otherScope: TypeScope) -> Bool {
    otherScope.isSubset(of: self.scope)
  }

  func matches(_ otherType: GraphQLCompositeType) -> Bool {
    self.scope.contains(otherType)
  }

  func appending(
    _ newType: GraphQLCompositeType,
    givenAllTypes allTypes: CompilationResult.ReferencedTypes
  ) -> TypeScopeDescriptor {
    if let scope = scope, scope.contains(newType) { return self }

    var newScope = self.scope ?? []
    newScope.insert(newType)
    if let newType = newType as? GraphQLInterfaceImplementingType {
      newScope.formUnion(newType.interfaces)
      #warning("Do we need to recursively form union with each interfaces other interfaces? Test this.")
    }

    if let newType = newType as? GraphQLObjectType {
      newScope.formUnion(allTypes.unions(including: newType))
    }

    return TypeScopeDescriptor(scope: newScope)
  }
}
