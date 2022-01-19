import ApolloUtils

extension IR {
  @dynamicMemberLookup
  class SelectionSet: Equatable, CustomDebugStringConvertible {
    class TypeInfo {
      /// The entity that the `selections` are being selected on.
      ///
      /// Multiple `SelectionSet`s may reference the same `Entity`
      let entity: Entity

      let parentType: GraphQLCompositeType

      /// A list of the type scopes for the selection set and its enclosing entities.
      ///
      /// The selection set's type scope is the last element in the list.
      let typePath: LinkedList<TypeScopeDescriptor>

      /// Describes all of the types the selection set matches.
      /// Derived from all the selection set's parents.
      var typeScope: TypeScopeDescriptor { typePath.last.value }

      init(
        entity: Entity,
        parentType: GraphQLCompositeType,
        typePath: LinkedList<TypeScopeDescriptor>
      ) {
        self.entity = entity
        self.parentType = parentType
        self.typePath = typePath
      }
    }

    class Selections {
      /// The selections that are directly selected by this selection set.
      let directSelections: DirectSelections?

      /// The selections that are available to be accessed by this selection set.
      ///
      /// Includes the direct `selections`, along with all selections from other related
      /// `SelectionSet`s on the same entity that match the selection set's type scope.
      ///
      /// Selections in the `mergedSelections` are guarunteed to be selected if this `SelectionSet`'s
      /// `selections` are selected. This means they can be merged into the generated object
      /// representing this `SelectionSet` as field accessors.
      ///
      /// - Precondition: The `directSelections` for all `SelectionSet`s in the operation must be
      /// completed prior to first access of `mergedSelections`. Otherwise, the merged selections
      /// will be incomplete.
      private(set) lazy var mergedSelections: MergedSelections = {
        let mergedSelections = MergedSelections(
          directSelections: self.directSelections?.readOnlyView,
          typeInfo: self.typeInfo
        )
        typeInfo.entity.mergedSelectionTree.addMergedSelections(into: mergedSelections)

        return mergedSelections
      }()

      private let typeInfo: TypeInfo

      fileprivate init(
        typeInfo: TypeInfo,
        mergedSelectionsOnly: Bool = false
      ) {
        self.typeInfo = typeInfo
        self.directSelections = mergedSelectionsOnly ? nil : DirectSelections()
      }
    }

    let typeInfo: TypeInfo
    let selections: Selections

    init(
      entity: Entity,
      parentType: GraphQLCompositeType,
      typePath: LinkedList<TypeScopeDescriptor>,
      mergedSelectionsOnly: Bool = false
    ) {
      self.typeInfo = TypeInfo(
        entity: entity,
        parentType: parentType,
        typePath: typePath
      )
      self.selections = Selections(
        typeInfo: self.typeInfo,
        mergedSelectionsOnly: mergedSelectionsOnly
      )
    }

    var debugDescription: String {
      "SelectionSet on \(typeInfo.parentType)"
    }

    static func ==(lhs: IR.SelectionSet, rhs: IR.SelectionSet) -> Bool {
      lhs.typeInfo.entity == rhs.typeInfo.entity &&
      lhs.typeInfo.parentType == rhs.typeInfo.parentType &&
      lhs.typeInfo.typePath == rhs.typeInfo.typePath &&
      lhs.selections.directSelections == rhs.selections.directSelections
    }

    subscript<T>(dynamicMember keyPath: KeyPath<TypeInfo, T>) -> T {
      typeInfo[keyPath: keyPath]
    }

  }
}
