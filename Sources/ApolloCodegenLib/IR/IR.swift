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
  class Entity {
    /// The selections that are selected for the entity across all type scopes in the operation.
    /// Represented as a tree.
    let selectionTree: EntitySelectionTree

    /// A list of path components indicating the path to the field containing the `Entity` in
    /// an operation.
    let fieldPath: ResponsePath

    var rootTypePath: LinkedList<GraphQLCompositeType> { selectionTree.rootTypePath }

    var rootType: GraphQLCompositeType { rootTypePath.last.value }

    init(
      rootTypePath: LinkedList<GraphQLCompositeType>,
      fieldPath: ResponsePath
    ) {
      self.selectionTree = EntitySelectionTree(rootTypePath: rootTypePath)
      self.fieldPath = fieldPath
    }
  }

  /// Represents a Fragment that has been "spread into" another SelectionSet using the
  /// spread operator (`...`).
  ///
  /// While a `NamedFragment` can be shared between operations, a `FragmentSpread` represents a
  /// `NamedFragment` included in a specific operation.
  class FragmentSpread: Hashable, CustomDebugStringConvertible {

    let underlyingFragmentSpread: CompilationResult.FragmentSpread

    #warning("TODO: Update Docs")
    /// The selection set for the fragment in the operation it has been "spread into".
    /// It's `typePath` and `entity` reference are scoped to the operation it belongs to.
    let typeInfo: SelectionSet.TypeInfo

    let selections = DirectSelections()

    var inclusionConditions: AnyOf<InclusionConditions>?

    var definition: CompilationResult.FragmentDefinition { underlyingFragmentSpread.fragment }

    init(
      fragmentSpread: CompilationResult.FragmentSpread,
      typeInfo: SelectionSet.TypeInfo,
      inclusionConditions: AnyOf<InclusionConditions>?
    ) {
      self.underlyingFragmentSpread = fragmentSpread
      self.typeInfo = typeInfo
      self.inclusionConditions = inclusionConditions
    }

    static func == (lhs: IR.FragmentSpread, rhs: IR.FragmentSpread) -> Bool {
      lhs.underlyingFragmentSpread == rhs.underlyingFragmentSpread &&
      lhs.inclusionConditions == rhs.inclusionConditions &&
      lhs.typeInfo == rhs.typeInfo &&
      lhs.selections == rhs.selections
    }

    func hash(into hasher: inout Hasher) {
      hasher.combine(underlyingFragmentSpread)
      hasher.combine(inclusionConditions)
      hasher.combine(typeInfo)
      hasher.combine(ObjectIdentifier(selections))
    }

    var debugDescription: String {
      definition.name
    }
  }
  
}
