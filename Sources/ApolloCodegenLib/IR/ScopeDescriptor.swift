import Foundation
import OrderedCollections
import ApolloUtils

extension IR {

  struct ScopeCondition: Hashable, CustomDebugStringConvertible {
    let type: GraphQLCompositeType?
    let conditions: InclusionConditions?

    init(type: GraphQLCompositeType? = nil, conditions: InclusionConditions? = nil) {
      self.type = type
      self.conditions = conditions
    }

    var debugDescription: String {
      [type?.debugDescription, conditions?.debugDescription]
        .compactMap { $0 }
        .joined(separator: " ")
    }

    var isEmpty: Bool {
      type == nil && (conditions?.isEmpty ?? true)
    }
  }

  typealias TypeScope = Set<GraphQLCompositeType>

  /// Defines the scope for an `IR.SelectionSet`. The "scope" indicates where in the entity the
  /// selection set is located, what types the `SelectionSet` implements, and what inclusion
  /// conditions it requires.
  struct ScopeDescriptor: Hashable {

    /// The parentType of the `SelectionSet`.
    ///
    /// Should always be equivalent to the last "type" value of the `scopePath`.
    let type: GraphQLCompositeType

    /// A list of the parent types/conditions for the selection set and it's parents
    /// on the same entity.
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
    let scopePath: LinkedList<ScopeCondition>

    /// All of the types that the `SelectionSet` implements. That is, all of the types in the
    /// `typePath`, all of those types implemented interfaces, and all unions that include
    /// those types.
    let matchingTypes: TypeScope

    /// All of the inclusion conditions on the entity that must be included for the `SelectionSet`
    /// to be included.
    let matchingConditions: InclusionConditions?

    let allTypesInSchema: IR.Schema.ReferencedTypes

    private init(
      typePath: LinkedList<ScopeCondition>,
      type: GraphQLCompositeType,
      matchingTypes: TypeScope,
      matchingConditions: InclusionConditions?,
      allTypesInSchema: IR.Schema.ReferencedTypes
    ) {
      self.scopePath = typePath
      self.type = type
      self.matchingTypes = matchingTypes
      self.matchingConditions = matchingConditions
      self.allTypesInSchema = allTypesInSchema
    }

    /// Creates a `ScopeDescriptor` for a root `SelectionSet`.
    ///
    /// This should only be used to create a `ScopeDescriptor` for a root `SelectionSet`.
    /// Nested type cases should be created by calling `appending(_:)` on the
    /// parent `SelectionSet`'s `typeScope`.
    ///
    /// - Parameters:
    ///   - forType: The parentType for the entity.
    ///   - inclusionConditions: The `InclusionConditions` for the `SelectionSet` to be included.
    ///   - givenAllTypesInSchema: The `ReferencedTypes` object that provides information on all of
    ///                            the types in the schema.
    static func descriptor(
      forType type: GraphQLCompositeType,
      inclusionConditions: InclusionConditions?,
      givenAllTypesInSchema allTypes: IR.Schema.ReferencedTypes
    ) -> ScopeDescriptor {
      let scope = Self.typeScope(addingType: type, to: nil, givenAllTypes: allTypes)
      return ScopeDescriptor(
        typePath: LinkedList(.init(type: type, conditions: inclusionConditions)),
        type: type,
        matchingTypes: scope,
        matchingConditions: inclusionConditions,
        allTypesInSchema: allTypes
      )
    }

    private static func typeScope(
      addingType newType: GraphQLCompositeType,
      to scope: TypeScope?,
      givenAllTypes allTypes: IR.Schema.ReferencedTypes
    ) -> TypeScope {
      if let scope = scope, scope.contains(newType) { return scope }

      var newScope = scope ?? []
      newScope.insert(newType)

      if let newType = newType as? GraphQLInterfaceImplementingType {
        newScope.formUnion(newType.interfaces)
      }

      if let newType = newType as? GraphQLObjectType {
        newScope.formUnion(allTypes.unions(including: newType))
      }

      return newScope
    }

    /// Returns a new `ScopeDescriptor` appending the new `ScopeCondition` to the `scopePath`.
    /// Any new types are added to the `matchingTypes`, and any new conditions are added to the
    /// `matchingConditions`.
    ///
    /// This should be used to create a `ScopeDescriptor` for a conditional `SelectionSet` inside
    /// of an entity, by appending the conditions to the parent `SelectionSet`'s `ScopeDescriptor`.
    func appending(_ scopeCondition: ScopeCondition) -> ScopeDescriptor {
      let matchingTypes: TypeScope
      if let newType = scopeCondition.type {
        matchingTypes = Self.typeScope(
          addingType: newType,
          to: self.matchingTypes,
          givenAllTypes: self.allTypesInSchema
        )
      } else {
        matchingTypes = self.matchingTypes
      }

      var matchingConditions = self.matchingConditions
      if let newConditions = scopeCondition.conditions {
        matchingConditions = matchingConditions?.appending(newConditions) ?? newConditions
      }

      return ScopeDescriptor(
        typePath: scopePath.appending(scopeCondition),
        type: scopeCondition.type ?? self.type,
        matchingTypes: matchingTypes,
        matchingConditions: matchingConditions,
        allTypesInSchema: self.allTypesInSchema
      )
    }

    /// Returns a new `ScopeDescriptor` appending the new type to the `scopePath` and
    /// `matchingConditions`.
    ///
    /// This should be used to create a `ScopeDescriptor` for a conditional `SelectionSet` inside
    /// of an entity, by appending the conditions to the parent `SelectionSet`'s `ScopeDescriptor`.
    func appending(_ newType: GraphQLCompositeType) -> ScopeDescriptor {
      self.appending(.init(type: newType))
    }

    /// Returns a new `ScopeDescriptor` appending the new conditions to the `scopePath` and
    /// `matchingTypes`.
    ///
    /// This should be used to create a `ScopeDescriptor` for a conditional `SelectionSet` inside
    /// of an entity, by appending the conditions to the parent `SelectionSet`'s `ScopeDescriptor`.
    func appending(_ conditions: InclusionConditions) -> ScopeDescriptor {
      self.appending(.init(conditions: conditions))
    }

    /// Indicates if the receiver is all of the types in the given `TypeScope`.
    /// If the receiver matches a `TypeScope`, then selections for a `SelectionSet` of that
    /// type scope can be merged in to the receiver's `SelectionSet`.
    func matches(_ otherScope: TypeScope) -> Bool {
      otherScope.isSubset(of: self.matchingTypes)
    }

    func matches(_ otherType: GraphQLCompositeType) -> Bool {
      self.matchingTypes.contains(otherType)
    }

    func matches(_ otherConditions: InclusionConditions) -> Bool {
      otherConditions.isSubset(of: self.matchingConditions)
    }

    /// Indicates if the receiver is of the given type. If the receiver matches a given type,
    /// then selections for a `SelectionSet` of that type can be merged in to the receiver's
    /// `SelectionSet`.
    func matches(_ condition: ScopeCondition) -> Bool {
      if let type = condition.type, !self.matches(type) {
        return false
      }

      if let inclusionConditions = condition.conditions, !self.matches(inclusionConditions) {
        return false
      }

      return true
    }

    static func == (lhs: ScopeDescriptor, rhs: ScopeDescriptor) -> Bool {
      lhs.scopePath == rhs.scopePath &&
      lhs.matchingTypes == rhs.matchingTypes
    }

    func hash(into hasher: inout Hasher) {
      hasher.combine(scopePath)
      hasher.combine(matchingTypes)
    }

  }
}

extension IR.ScopeDescriptor: CustomDebugStringConvertible {
  var debugDescription: String {
    scopePath.debugDescription
  }
}

