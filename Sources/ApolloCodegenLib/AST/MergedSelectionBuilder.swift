import Foundation
import OrderedCollections

protocol _ASTField {
  var name: String { get }
  var alias: String? { get }
  var type: GraphQLType { get }
}

struct LinkedList<T> { // copy on write

}

struct Trie<Key, Value> {

}

class AST {

  let compilationResult: CompilationResult
  let mergedSelectionsForFields: Trie<String, Entity.MergedSelectionTree>

  let rootField: EntityField

  enum Field {
    case scalar(ScalarField)
    case entity(EntityField)
  }

  class ScalarField {
    let name: String
    let alias: String?
    let type: GraphQLType
  }

  class EntityField {
    let name: String
    let alias: String?
    let type: GraphQLType

    let entity: Entity
    let selectionSet: SelectionSet
  }

  class Entity {
    let rootType: GraphQLCompositeType

    let mergedSelectionTree: MergedSelectionTree

    class MergedSelectionTree {
      var rootNode: EnclosingEntityNode

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

    // TODO: Do we even need this? Can MergedSelectionTree handle all of it?
//    let mergedSelectionBuilder: MergedSelectionBuilder
    // TODO: move the builder functionality into this Entity object?
  }

  class SelectionSet {
    typealias ChildTypeCaseDictionary = OrderedDictionary<String, SelectionSet>

    weak var entity: Entity?

    let type: GraphQLCompositeType
    let typeScope: TypeScopeDescriptor

    let responsePath: LinkedList<String>
    let enclosingEntityScope: LinkedList<TypeScope>

    var childTypeCases: ChildTypeCaseDictionary = [:]
    var selections: SortedSelections = SortedSelections()
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
