import Foundation
import OrderedCollections
import ApolloUtils
import ApolloAPI

class IR {
  let compilationResult: CompilationResult

  init(compilationResult: CompilationResult) {
    self.compilationResult = compilationResult
  }

  class Operation {
    let definition: CompilationResult.OperationDefinition
    let rootField: EntityField

    init(
      definition: CompilationResult.OperationDefinition,
      rootField: EntityField
    ) {
      self.definition = definition
      self.rootField = rootField
    }
  }

  class Entity: Equatable {
    let mergedSelectionTree: MergedSelectionTree

    var rootTypePath: LinkedList<TypeScopeDescriptor> { mergedSelectionTree.rootTypePath }
    var responsePath: ResponsePath { rootTypePath.last.value.fieldPath }
    var rootType: GraphQLCompositeType { rootTypePath.last.value.type }

    init(rootTypePath: LinkedList<TypeScopeDescriptor>) {
      self.mergedSelectionTree = MergedSelectionTree(rootTypePath: rootTypePath)
    }

    static func == (lhs: IR.Entity, rhs: IR.Entity) -> Bool {
      lhs.mergedSelectionTree === rhs.mergedSelectionTree
    }
  }

  class MergedSelectionTree {
    let rootTypePath: LinkedList<TypeScopeDescriptor>
    var rootNode: EnclosingEntityNode

    init(rootTypePath: LinkedList<TypeScopeDescriptor>) {
      self.rootTypePath = rootTypePath
      self.rootNode = EnclosingEntityNode()
    }

    func mergeIn(selectionSet: SelectionSet) {

    }

    class EnclosingEntityNode {
      enum Child {
        case enclosingEntity(EnclosingEntityNode)
        case fieldScope(FieldScopeNode)
      }

      var child: Child?
      var typeCases: [GraphQLCompositeType: EnclosingEntityNode]?
    }

    class FieldScopeNode {
      var selections: SortedSelections?
      var typeCases: [GraphQLCompositeType: FieldScopeNode]?
    }
  }

  class SelectionSet: Equatable {
    let entity: Entity
    let parentType: GraphQLCompositeType
    let typePath: LinkedList<TypeScopeDescriptor>
    var typeScope: TypeScopeDescriptor { typePath.last.value }

    var selections: SortedSelections = SortedSelections()

    init(
      entity: Entity,
      parentType: GraphQLCompositeType,
      typePath: LinkedList<TypeScopeDescriptor>
    ) {
      self.entity = entity
      self.parentType = parentType
      self.typePath = typePath
    }

    static func == (lhs: IR.SelectionSet, rhs: IR.SelectionSet) -> Bool {
      lhs.entity == rhs.entity &&
      lhs.parentType == rhs.parentType &&
      lhs.typePath == rhs.typePath &&
      lhs.selections == rhs.selections
    }
  }

  class FragmentSpread: Equatable {
    let definition: CompilationResult.FragmentDefinition
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
