import ApolloUtils

extension IR {
  @dynamicMemberLookup
  class SelectionSet: Equatable, CustomDebugStringConvertible {
    class TypeInfo: Hashable, CustomDebugStringConvertible {
      /// The entity that the `selections` are being selected on.
      ///
      /// Multiple `SelectionSet`s may reference the same `Entity`
      let entity: Entity

      /// A list of the type scopes for the `SelectionSet` and its enclosing entities.
      ///
      /// The selection set's type scope is the last element in the list.
      let scopePath: LinkedList<ScopeDescriptor>

      /// Describes all of the types the selection set matches.
      /// Derived from all the selection set's parents.
      var scope: ScopeDescriptor { scopePath.last.value }

      var parentType: GraphQLCompositeType { scope.type }

      var inclusionConditions: InclusionConditions? { scope.scopePath.last.value.conditions }

      /// Indicates if the `SelectionSet` represents a root selection set.
      /// If `true`, the `SelectionSet` belongs to a field directly.
      /// If `false`, the `SelectionSet` belongs to a conditional selection set enclosed
      /// in a field's `SelectionSet`.
      var isEntityRoot: Bool { scope.scopePath.head.next == nil }

      init(
        entity: Entity,
        scopePath: LinkedList<ScopeDescriptor>
      ) {
        self.entity = entity
        self.scopePath = scopePath
      }

      static func == (lhs: TypeInfo, rhs: TypeInfo) -> Bool {
        lhs.entity === rhs.entity &&
        lhs.scopePath == rhs.scopePath
      }

      func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(entity))
        hasher.combine(scopePath)
      }

      var debugDescription: String {
        scopePath.debugDescription
      }
    }

    class Selections: CustomDebugStringConvertible {
      /// The selections that are directly selected by this selection set.
      let direct: DirectSelections?

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
      private(set) lazy var merged: MergedSelections = {
        let mergedSelections = MergedSelections(
          directSelections: self.direct?.readOnlyView,
          typeInfo: self.typeInfo
        )
        typeInfo.entity.selectionTree.addMergedSelections(into: mergedSelections)

        return mergedSelections
      }()

      private let typeInfo: TypeInfo

      fileprivate init(
        typeInfo: TypeInfo,
        directSelections: DirectSelections?
      ) {
        self.typeInfo = typeInfo
        self.direct = directSelections
      }

      var debugDescription: String {
        """
        direct: {
          \(indented: direct?.debugDescription ?? "nil")
        }
        merged: {
          \(indented: merged.debugDescription)
        }
        """
      }
    }

    // MARK:  - SelectionSet

    let typeInfo: TypeInfo
    let selections: Selections

    init(
      entity: Entity,
      scopePath: LinkedList<ScopeDescriptor>,
      mergedSelectionsOnly: Bool = false
    ) {
      self.typeInfo = TypeInfo(
        entity: entity,
        scopePath: scopePath
      )
      self.selections = Selections(
        typeInfo: self.typeInfo,
        directSelections: mergedSelectionsOnly ? nil : DirectSelections()
      )
    }

    init(
      entity: Entity,
      scopePath: LinkedList<ScopeDescriptor>,
      selections: DirectSelections
    ) {
      self.typeInfo = TypeInfo(
        entity: entity,
        scopePath: scopePath
      )
      self.selections = Selections(
        typeInfo: self.typeInfo,
        directSelections: selections
      )
    }

    var debugDescription: String {
      TemplateString("""
      SelectionSet on \(typeInfo.parentType.debugDescription) \(ifLet: typeInfo.inclusionConditions, { " \($0.debugDescription)"})  {
        \(self.selections.debugDescription)
      }
      """).description
    }

    static func ==(lhs: IR.SelectionSet, rhs: IR.SelectionSet) -> Bool {
      lhs.typeInfo.entity === rhs.typeInfo.entity &&
      lhs.typeInfo.scopePath == rhs.typeInfo.scopePath &&
      lhs.selections.direct == rhs.selections.direct
    }

    subscript<T>(dynamicMember keyPath: KeyPath<TypeInfo, T>) -> T {
      typeInfo[keyPath: keyPath]
    }

  }
}
