import OrderedCollections
import CryptoKit

class IR {

  let compilationResult: CompilationResult

  let schema: Schema

  let fieldCollector = FieldCollector()

  var builtFragments: [String: NamedFragment] = [:]

  init(compilationResult: CompilationResult) {
    self.compilationResult = compilationResult
    self.schema = Schema(
      referencedTypes: .init(compilationResult.referencedTypes),
      documentation: compilationResult.schemaDocumentation
    )
    self.processRootTypes()
  }
  
  private func processRootTypes() {
    let rootTypes = compilationResult.rootTypes
    let typeList = [rootTypes.queryType.name, rootTypes.mutationType?.name, rootTypes.subscriptionType?.name].compactMap { $0 }
    
    compilationResult.operations.forEach { op in
      op.rootType.isRootFieldType = typeList.contains(op.rootType.name)
    }
    
    compilationResult.fragments.forEach { fragment in
      fragment.type.isRootFieldType = typeList.contains(fragment.type.name)
    }
  }

  /// A top level GraphQL definition, which can be an operation or a named fragment.
  enum Definition {
    case operation(IR.Operation)
    case namedFragment(IR.NamedFragment)

    var name: String {
      switch self {
      case  let .operation(operation):
        return operation.definition.name
      case let .namedFragment(fragment):
        return fragment.definition.name
      }
    }

    var rootField: IR.EntityField {
      switch self {
      case  let .operation(operation):
        return operation.rootField
      case let .namedFragment(fragment):
        return fragment.rootField
      }
    }
  }

  /// Represents a concrete entity in an operation or fragment that fields are selected upon.
  ///
  /// Multiple `SelectionSet`s may select fields on the same `Entity`. All `SelectionSet`s that will
  /// be selected on the same object share the same `Entity`.
  class Entity {
    struct Location: Hashable {
      enum SourceDefinition: Hashable {
        case operation(CompilationResult.OperationDefinition)
        case namedFragment(CompilationResult.FragmentDefinition)
      }

      struct FieldComponent: Hashable {
        let name: String
        let type: GraphQLType
      }

      typealias FieldPath = LinkedList<FieldComponent>

      /// The operation or fragment definition that the entity belongs to.
      let source: SourceDefinition
      let fieldPath: FieldPath?

      func appending(_ fieldComponent: FieldComponent) -> Location {
        let fieldPath = self.fieldPath?.appending(fieldComponent) ?? LinkedList(fieldComponent)
        return Location(source: self.source, fieldPath: fieldPath)
      }

      func appending<C: Collection<FieldComponent>>(_ fieldComponents: C) -> Location {
        let fieldPath = self.fieldPath?.appending(fieldComponents) ?? LinkedList(fieldComponents)
        return Location(source: self.source, fieldPath: fieldPath)
      }

      static func +(lhs: IR.Entity.Location, rhs: FieldComponent) -> Location {
        lhs.appending(rhs)
      }
    }

    /// The selections that are selected for the entity across all type scopes in the operation.
    /// Represented as a tree.
    let selectionTree: EntitySelectionTree

    #warning("TODO: udpate docs")
    /// A list of path components indicating the path to the field containing the `Entity` in
    /// an operation or fragment.
    let location: Location

    var rootTypePath: LinkedList<GraphQLCompositeType> { selectionTree.rootTypePath }

    var rootType: GraphQLCompositeType { rootTypePath.last.value }

#warning("TODO: infer rootTypePath and remove param")
    init(
      source: Location.SourceDefinition,
      rootTypePath: LinkedList<GraphQLCompositeType>
//      fieldPath: FieldPath?
    ) {
      self.location = .init(source: source, fieldPath: nil)
      self.selectionTree = EntitySelectionTree(rootTypePath: rootTypePath)
//      self.fieldPath = fieldPath
    }

    init(
      location: Location,
      rootTypePath: LinkedList<GraphQLCompositeType>
    ) {
      self.location = location
      self.selectionTree = EntitySelectionTree(rootTypePath: rootTypePath)
    }
  }

  class Operation {
    let definition: CompilationResult.OperationDefinition

    /// The root field of the operation. This field must be the root query, mutation, or
    /// subscription field of the schema.
    let rootField: EntityField

    /// All of the fragments that are referenced by this operation's selection set.
    let referencedFragments: OrderedSet<NamedFragment>

    lazy var operationIdentifier: String = {
      if #available(macOS 10.15, *) {
        var hasher = SHA256()
        func updateHash(with source: inout String) {
          source.withUTF8({ buffer in
            hasher.update(bufferPointer: UnsafeRawBufferPointer(buffer))
          })
        }
        updateHash(with: &definition.source)

        var newline: String
        for fragment in referencedFragments {
          newline = "\n"
          updateHash(with: &newline)
          updateHash(with: &fragment.definition.source)
        }

        let digest = hasher.finalize()
        return digest.compactMap { String(format: "%02x", $0) }.joined()

      } else {
        fatalError("Code Generation must be run on macOS 10.15+.")
      }
    }()

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

    /// All of the Entities that exist in the fragment's selection set,
    /// keyed by their relative location (ie. path) within the fragment.
    ///
    /// - Note: The FieldPath for an entity within a fragment will begin with a path component
    /// with the fragment's name and type.
    let entities: [IR.Entity.Location: IR.Entity]

    var name: String { definition.name }
    var type: GraphQLCompositeType { definition.type }

    init(
      definition: CompilationResult.FragmentDefinition,
      rootField: EntityField,
      referencedFragments: OrderedSet<NamedFragment>,
      entities: [IR.Entity.Location: IR.Entity]
    ) {
      self.definition = definition
      self.rootField = rootField
      self.referencedFragments = referencedFragments
      self.entities = entities
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

  /// Represents a Fragment that has been "spread into" another SelectionSet using the
  /// spread operator (`...`).
  ///
  /// While a `NamedFragment` can be shared between operations, a `FragmentSpread` represents a
  /// `NamedFragment` included in a specific operation.
  class FragmentSpread: Hashable, CustomDebugStringConvertible {

    /// The `NamedFragment` that this fragment refers to.
    ///
    /// This is a fragment that has already been built. To "spread" the fragment in, it's entity
    /// selection trees are merged into the entity selection trees of the operation/fragment it is
    /// being spread into. This allows merged field calculations to include the fields merged in
    /// from the fragment.
    let fragment: NamedFragment
    
    /// Indicates the location where the fragment has been "spread into" its enclosing
    /// operation/fragment. It's `scopePath` and `entity` reference are scoped to the operation it
    /// belongs to.
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
      var description = fragment.debugDescription
      if let inclusionConditions = inclusionConditions {
        description += " \(inclusionConditions.debugDescription)"
      }
      return description
    }
  }
  
}
