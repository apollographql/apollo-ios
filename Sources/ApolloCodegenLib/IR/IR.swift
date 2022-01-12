import OrderedCollections
import ApolloUtils

class IR {

  let compilationResult: CompilationResult

  let schema: Schema

  init(schemaName: String, compilationResult: CompilationResult) {
    self.compilationResult = compilationResult
    self.schema = Schema(
      name: schemaName,
      referencedTypes: .init(compilationResult.referencedTypes)
    )
  }

  class Operation {
    let definition: CompilationResult.OperationDefinition

    /// The root field of the operation. This field must be the root query, mutation, or
    /// subscription field of the schema.
    let rootField: EntityField

    /// All of the fragments that are referenced by this operation's selection set.
    let referencedFragments: OrderedSet<CompilationResult.FragmentDefinition>

    init(
      definition: CompilationResult.OperationDefinition,
      rootField: EntityField,
      referencedFragments: OrderedSet<CompilationResult.FragmentDefinition>
    ) {
      self.definition = definition
      self.rootField = rootField
      self.referencedFragments = referencedFragments
    }
  }

  class NamedFragment {
    let definition: CompilationResult.FragmentDefinition
    let rootField: EntityField

    var name: String { definition.name }

    init(
      definition: CompilationResult.FragmentDefinition,
      rootField: EntityField
    ) {
      self.definition = definition
      self.rootField = rootField
    }
  }

  /// Represents a concrete entity in an operation that fields are selected upon.
  ///
  /// Multiple `SelectionSet`s may select fields on the same `Entity`. All `SelectionSet`s that will
  /// be selected on the same object share the same `Entity`.
  class Entity: Equatable {
    /// The selections that are selected for the entity across all type scopes in the operation.
    /// Represented as a tree.
    let mergedSelectionTree: MergedSelectionTree

    /// A list of path components indicating the path to the field containing the `Entity` in
    /// an operation.
    let fieldPath: ResponsePath

    var rootTypePath: LinkedList<GraphQLCompositeType> { mergedSelectionTree.rootTypePath }

    var rootType: GraphQLCompositeType { rootTypePath.last.value }

    init(
      rootTypePath: LinkedList<GraphQLCompositeType>,
      fieldPath: ResponsePath
    ) {
      self.mergedSelectionTree = MergedSelectionTree(rootTypePath: rootTypePath)
      self.fieldPath = fieldPath
    }

    static func == (lhs: IR.Entity, rhs: IR.Entity) -> Bool {
      lhs.mergedSelectionTree === rhs.mergedSelectionTree
    }
  }

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
    var selections: SortedSelections = SortedSelections()

    /// The selections that are available to be accessed by this selection set.
    ///
    /// Includes the direct `selections`, along with all selections from other related
    /// `SelectionSet`s on the same entity that match the selection set's type scope.
    ///
    /// Selections in the `mergedSelections` are guarunteed to be selected if this `SelectionSet`'s
    /// `selections` are selected. This means they can be merged into the generated object
    /// representing this `SelectionSet` as field accessors.
    lazy var mergedSelections: MergedSelections = entity.mergedSelectionTree
      .mergedSelections(forSelectionSet: self)

    init(
      entity: Entity,
      parentType: GraphQLCompositeType,
      typePath: LinkedList<TypeScopeDescriptor>
    ) {
      self.entity = entity
      self.parentType = parentType
      self.typePath = typePath
    }

    var debugDescription: String {
      "SelectionSet on \(parentType)"
    }

    static func ==(lhs: IR.SelectionSet, rhs: IR.SelectionSet) -> Bool {
      lhs.entity == rhs.entity &&
      lhs.parentType == rhs.parentType &&
      lhs.typePath == rhs.typePath &&
      lhs.selections == rhs.selections
    }

  }

  /// Represents a Fragment that has been "spread into" another SelectionSet using the
  /// spread operator (`...`).
  ///
  /// While a `NamedFragment` can be shared between operations, a `FragmentSpread` represents a
  /// `NamedFragment` included in a specific operation.
  class FragmentSpread: Equatable {
    let definition: CompilationResult.FragmentDefinition
    /// The selection set for the fragment in the operation it has been "spread into".
    /// It's `typePath` and `entity` reference are scoped to the operation it belongs to.
    let selectionSet: SelectionSet

    init(
      definition: CompilationResult.FragmentDefinition,
      selectionSet: SelectionSet
    ) {
      self.definition = definition
      self.selectionSet = selectionSet
    }

    static func == (lhs: IR.FragmentSpread, rhs: IR.FragmentSpread) -> Bool {
      lhs.definition == rhs.definition &&
      lhs.selectionSet == rhs.selectionSet
    }
  }
  
}
