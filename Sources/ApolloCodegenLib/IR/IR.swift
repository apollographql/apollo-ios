import OrderedCollections
import ApolloUtils

#warning("TODO: finish or kill?")
protocol KeyedSetElement {
  associatedtype KeyedSetKey: Hashable
  var keyedSetKey: KeyedSetKey { get }
}

struct KeyedSet<Key: Hashable, Value> {

  private let keyResolver: (Value) -> Key
  private let _storage: Dictionary<Key, Value> = [:]

  init(keyResolver: @escaping (Value) -> Key) {
    self.keyResolver = keyResolver
  }
  
}

class IR {

  let compilationResult: CompilationResult

  let schema: Schema

  var builtFragments: [String: NamedFragment] = [:]

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
    let referencedFragments: OrderedSet<NamedFragment>

    init(
      definition: CompilationResult.OperationDefinition,
      rootField: EntityField,
      referencedFragments: OrderedSet<NamedFragment>
    ) {
      self.definition = definition
      self.rootField = rootField
      self.referencedFragments = referencedFragments
    }
  }

  class NamedFragment: Hashable, CustomDebugStringConvertible {
    let definition: CompilationResult.FragmentDefinition
    let rootField: EntityField

    /// All of the fragments that are referenced by this fragment's selection set.
    let referencedFragments: OrderedSet<NamedFragment>

    var name: String { definition.name }
    var type: GraphQLCompositeType { definition.type }

    init(
      definition: CompilationResult.FragmentDefinition,
      rootField: EntityField,
      referencedFragments: OrderedSet<NamedFragment>
    ) {
      self.definition = definition
      self.rootField = rootField
      self.referencedFragments = referencedFragments
    }

    static func == (lhs: IR.NamedFragment, rhs: IR.NamedFragment) -> Bool {
      lhs.definition == rhs.definition &&
      lhs.rootField === rhs.rootField
    }

    func hash(into hasher: inout Hasher) {
      hasher.combine(definition)
      hasher.combine(ObjectIdentifier(rootField))
    }

    var debugDescription: String {
      definition.debugDescription
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

    let fragment: NamedFragment

    #warning("TODO: Update Docs")
    /// The selection set for the fragment in the operation it has been "spread into".
    /// It's `typePath` and `entity` reference are scoped to the operation it belongs to.
    let typeInfo: SelectionSet.TypeInfo

    var inclusionConditions: AnyOf<InclusionConditions>?

    var definition: CompilationResult.FragmentDefinition { fragment.definition }

    init(
      fragment: NamedFragment,
      typeInfo: SelectionSet.TypeInfo,
      inclusionConditions: AnyOf<InclusionConditions>?
    ) {
      self.fragment = fragment
      self.typeInfo = typeInfo
      self.inclusionConditions = inclusionConditions
    }

    static func == (lhs: IR.FragmentSpread, rhs: IR.FragmentSpread) -> Bool {
      lhs.fragment === rhs.fragment &&
      lhs.typeInfo == rhs.typeInfo &&
      lhs.inclusionConditions == rhs.inclusionConditions
    }

    func hash(into hasher: inout Hasher) {
      hasher.combine(ObjectIdentifier(fragment))
      hasher.combine(typeInfo)
      hasher.combine(inclusionConditions)
    }

    var debugDescription: String {
      fragment.debugDescription
    }
  }
  
}
