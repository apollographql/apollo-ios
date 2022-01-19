import ApolloUtils

extension IR {
  class SelectionSet: Equatable, CustomDebugStringConvertible {
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

    /// The selections that are directly selected by this selection set.
    let directSelections: SortedSelections?

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
    private(set) lazy var mergedSelections: ShallowSelections = {
      entity.mergedSelectionTree.calculateMergedSelections(forSelectionSet: self)
      return _mergedSelections
    }()
    private var _mergedSelections: ShallowSelections = ShallowSelections()

    init(
      entity: Entity,
      parentType: GraphQLCompositeType,
      typePath: LinkedList<TypeScopeDescriptor>,
      mergedSelectionsOnly: Bool = false
    ) {
      self.entity = entity
      self.parentType = parentType
      self.typePath = typePath
      self.directSelections = mergedSelectionsOnly ? nil : SortedSelections()
    }

    private func mergeIn(_ field: IR.Field) {
      if let directSelections = directSelections,
          directSelections.fields.keys.contains(field.hashForSelectionSetScope) {
        return
      }

      if let entityField = field as? EntityField {
        _mergedSelections.mergeIn(createShallowlyMergedNestedEntityField(from: entityField))

      } else {
        _mergedSelections.mergeIn(field)
      }
    }

    private func createShallowlyMergedNestedEntityField(from field: IR.EntityField) -> IR.EntityField {
      let newSelectionSet = SelectionSet(
        entity: field.entity,
        parentType: field.selectionSet.parentType,
        typePath: self.typePath.appending(field.selectionSet.typeScope),
        mergedSelectionsOnly: true
      )
      return IR.EntityField(field.underlyingField, selectionSet: newSelectionSet)
    }

    private func mergeIn(_ fragment: IR.FragmentSpread) {
      if let directSelections = directSelections,
          directSelections.fragments.keys.contains(fragment.hashForSelectionSetScope) {
        return
      }

      _mergedSelections.mergeIn(fragment)
    }

    func mergeIn(_ selections: IR.ShallowSelections) {
      selections.fields.values.forEach { self.mergeIn($0) }
      selections.fragments.values.forEach { self.mergeIn($0) }
    }

    var debugDescription: String {
      "SelectionSet on \(parentType)"
    }

    static func ==(lhs: IR.SelectionSet, rhs: IR.SelectionSet) -> Bool {
      lhs.entity == rhs.entity &&
      lhs.parentType == rhs.parentType &&
      lhs.typePath == rhs.typePath &&
      lhs.directSelections == rhs.directSelections
    }

  }
}
