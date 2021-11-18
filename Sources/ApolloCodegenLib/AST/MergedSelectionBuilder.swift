import Foundation
import OrderedCollections
import ApolloUtils
import ApolloAPI

class IR {
  let compilationResult: CompilationResult

  class Operation {
    let definition: CompilationResult.OperationDefinition
    let rootField: Field

    init(
      definition: CompilationResult.OperationDefinition,
      rootField: Field
    ) {
      self.definition = definition
      self.rootField = rootField
    }
  }

  class Entity: Equatable {
    let rootType: GraphQLCompositeType
    let responsePath: ResponsePath
    let mergedSelectionTree: MergedSelectionTree

    init(
      rootType: GraphQLCompositeType,
      responsePath: ResponsePath,
      mergedSelectionTree: MergedSelectionTree
    ) {
      self.rootType = rootType
      self.responsePath = responsePath
      self.mergedSelectionTree = mergedSelectionTree
    }

    static func == (lhs: IR.Entity, rhs: IR.Entity) -> Bool {
      lhs.rootType == rhs.rootType &&
      lhs.responsePath == rhs.responsePath &&
      lhs.mergedSelectionTree === rhs.mergedSelectionTree
    }
  }

  class MergedSelectionTree {
    var rootNode: EnclosingEntityNode

    init() {
      self.rootNode = EnclosingEntityNode()
    }

    init(rootNode: EnclosingEntityNode) {
      self.rootNode = rootNode
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
    typealias ChildTypeCaseDictionary = OrderedDictionary<GraphQLCompositeType, SelectionSet>

    var entity: Entity

    let parentType: GraphQLCompositeType
    let typeScope: TypeScopeDescriptor

    let enclosingEntityScope: LinkedList<TypeScope>

    var childTypeCases: ChildTypeCaseDictionary = [:]
    var selections: SortedSelections = SortedSelections()

    static func == (lhs: IR.SelectionSet, rhs: IR.SelectionSet) -> Bool {
      lhs.entity == rhs.entity &&
      lhs.parentType == rhs.parentType &&
      lhs.typeScope == rhs.typeScope &&
      lhs.enclosingEntityScope == rhs.enclosingEntityScope &&
      lhs.childTypeCases == rhs.childTypeCases &&
      lhs.selections == rhs.selections
    }
  }
}

/// An object that collects the selections for the type scopes for a tree of `ASTSelectionSet`s and
/// computes the merged selections for each `ASTSelectionSet` in the tree.
///
/// A single `MergedSelectionBuilder` should be shared between a parent `ASTSelectionSet` and all
/// of its children (all selection sets that represent the same entity).
///
/// Conversely, a `MergedSelectionBuilder` should **not** be shared with `ASTSelectionSet`s
/// representing a different entity. Each new root parent `ASTSelectionSet` should create a new
/// `MergedSelectionBuilder` for its child tree.
class MergedSelectionBuilder {
  private(set) var selectionsForScopes: OrderedDictionary<TypeScope, SortedSelections> = [:]
  private(set) var fieldSelectionMergedScopes: [String: MergedSelectionBuilder] = [:]




  func computeSelectionsAndChildren(
    from selections: [CompilationResult.Selection],
    for selectionSet: ASTSelectionSet
  ) -> (
    selections: SortedSelections,
    children: OrderedDictionary<String, ASTSelectionSet>
  ) {
    var computedChildSelectionSets: OrderedDictionary<String, CompilationResult.SelectionSet> = [:]
    var computedSelections = SortedSelections()

    func appendOrMergeIntoChildren(_ selectionSet: CompilationResult.SelectionSet) {
      let keyInScope = selectionSet.hashForSelectionSetScope
      if let existingValue = computedChildSelectionSets[keyInScope] {
        computedChildSelectionSets[keyInScope] = existingValue.merging(selectionSet)

      } else {
        computedChildSelectionSets[keyInScope] = selectionSet
      }
    }

    for selection in selections {
      switch selection {
      case let .field(field) where field.type.namedType is GraphQLCompositeType:
        let builderForField = enclosingEntityMergedSelectionBuilder(for: field)
        //        builderForField.add(<#T##selections: SortedSelections##SortedSelections#>, forScope: <#T##TypeScope#>)
        let astField = ASTField(field, enclosingEntityMergedSelectionBuilder: builderForField)
        computedSelections.mergeIn(astField)

      case let .field(field):
        computedSelections.mergeIn(ASTField(field))

      case let .inlineFragment(typeCaseSelectionSet):
        if selectionSet.scopeDescriptor.matches(typeCaseSelectionSet.parentType) {
          computedSelections.mergeIn(typeCaseSelectionSet.selections)

        } else {
          computedSelections.mergeIn(typeCase: typeCaseSelectionSet)
          appendOrMergeIntoChildren(typeCaseSelectionSet)
        }

      case let .fragmentSpread(fragment):
        func shouldMergeFragmentDirectly() -> Bool {
#warning("TODO: Might be able to change this to use TypeScopeDescriptor.matches()?")
          if fragment.type == selectionSet.type { return true }

          if let implementingType = selectionSet.type as? GraphQLInterfaceImplementingType,
             let fragmentInterface = fragment.type as? GraphQLInterfaceType,
             implementingType.implements(fragmentInterface) {
            return true
          }

          return false
        }

        if shouldMergeFragmentDirectly() {
          computedSelections.mergeIn(fragment)

        } else {
          let typeCaseForFragment = CompilationResult.SelectionSet(
            parentType: fragment.type,
            selections: [selection]
          )

          computedSelections.mergeIn(typeCase: typeCaseForFragment)
          appendOrMergeIntoChildren(typeCaseForFragment)
        }
      }
    }

    self.add(computedSelections, forScope: selectionSet.scopeDescriptor.scope)

    let children = computedChildSelectionSets.mapValues {
      ASTSelectionSet(selectionSet: $0, parent: selectionSet)
    }
    return (computedSelections, children)
  }

  private func enclosingEntityMergedSelectionBuilder(
    for field: CompilationResult.Field
  ) -> MergedSelectionBuilder {
    guard let fieldScopeBuilder = fieldSelectionMergedScopes["height"] else {
      let fieldScopeBuilder = MergedSelectionBuilder()
      fieldSelectionMergedScopes["height"] = fieldScopeBuilder
      return fieldScopeBuilder
    }
    return fieldScopeBuilder
  }

  private func add(_ selections: SortedSelections, forScope typeScope: TypeScope) {
    if var existingSelections = selectionsForScopes[typeScope] {
      existingSelections.mergeIn(selections)
      selectionsForScopes[typeScope] = existingSelections

    } else {
      selectionsForScopes.updateValue(selections, forKey: typeScope, insertingAt: 0)
    }
  }

  func mergedSelections(for selectionSet: ASTSelectionSet) -> SortedSelections {
    let targetScope = selectionSet.scopeDescriptor
    var mergedSelections = selectionSet.selections.unsafelyUnwrapped
    for (scope, selections) in selectionsForScopes {
      if targetScope.matches(scope) {
        merge(selections, into: &mergedSelections)
      }
    }
    return mergedSelections
  }

  /// Does not merge in type cases, since we do not merge type cases across scopes.
  private func merge(_ selections: SortedSelections, into mergedSelections: inout SortedSelections) {
    mergedSelections.mergeIn(selections.fields)
    for fragment in selections.fragments.values {
      mergedSelections.mergeIn(fragment)
      mergedSelections.mergeIn(fragment.selectionSet.selections)
    }
  }

}
