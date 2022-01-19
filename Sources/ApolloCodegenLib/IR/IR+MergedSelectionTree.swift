import ApolloUtils
import Darwin
import OrderedCollections

fileprivate protocol MergedSelectionTreeNode {
  func mergeSelections(
    matchingTypePath typePath: LinkedList<TypeScopeDescriptor>.Node,
    into selections: IR.SelectionSet.Selections
  )
}

extension IR {

  /// Represents the selections for an entity at different nested type scopes in a tree.
  ///
  /// This data structure is used to memoize the selections for an `Entity` to quickly compute
  /// the `mergedSelections` for `SelectionSet`s.
  ///
  /// During the creation of `SelectionSet`s, their `selections` are added to their entities
  /// mergedSelectionTree at the appropriate type scope. After all `SelectionSet`s have been added
  /// to the `MergedSelectionTree`, the tree can be quickly traversed to collect the selections
  /// that will be selected for a given `SelectionSet`'s type scope.
  class MergedSelectionTree {
    let rootTypePath: LinkedList<GraphQLCompositeType>
    lazy var rootNode = EnclosingEntityNode()

    init(rootTypePath: LinkedList<GraphQLCompositeType>) {
      self.rootTypePath = rootTypePath
    }

    // MARK: - Merge Selection Sets Into Tree
    
    func mergeIn(selectionSet: SelectionSet) {
      guard let directSelections = selectionSet.selections.directSelections else { return }
      mergeIn(
        selections: directSelections,
        atEnclosingEntityScope: selectionSet.typeInfo.typePath.head,
        withEntityTypePath: selectionSet.typeInfo.typePath.head.value.typePath.head,
        to: rootNode,
        ofType: rootTypePath.head.value,
        withRootTypePath: rootTypePath.head
      )
    }

    private func mergeIn(
      selections: IR.SortedSelections,
      atEnclosingEntityScope currentEntityScope: LinkedList<TypeScopeDescriptor>.Node,
      withEntityTypePath currentEntityTypePath: LinkedList<GraphQLCompositeType>.Node,
      to node: EnclosingEntityNode,
      ofType currentNodeType: GraphQLCompositeType,
      withRootTypePath currentNodeRootTypePath: LinkedList<GraphQLCompositeType>.Node
    ) {
      guard let nextEntityTypePath = currentNodeRootTypePath.next else {
        // Advance to field node in current entity & type case
        let fieldNode = node.childAsFieldScopeNode()
        mergeIn(
          selections: selections,
          withTypeScope: currentEntityScope.value.typePath.head,
          toFieldNode: fieldNode,
          ofType: currentNodeRootTypePath.value
        )
        return
      }

      guard let nextTypePathForCurrentEntity = currentEntityTypePath.next else {
        // Advance to next entity
        guard let nextEntityScope = currentEntityScope.next else { fatalError() }
        let nextEntityNode = node.childAsEnclosingEntityNode()

        mergeIn(
          selections: selections,
          atEnclosingEntityScope: nextEntityScope,
          withEntityTypePath: nextEntityScope.value.typePath.head,
          to: nextEntityNode,
          ofType: nextEntityTypePath.value,
          withRootTypePath: nextEntityTypePath
        )
        return
      }

      // Advance to next type case in current entity
      let nextTypeForCurrentEntity = nextTypePathForCurrentEntity.value
      let nextNodeForCurrentEntity = currentNodeType != nextTypeForCurrentEntity
      ? node.typeCaseNode(forType: nextTypeForCurrentEntity) : node

      mergeIn(
        selections: selections,
        atEnclosingEntityScope: currentEntityScope,
        withEntityTypePath: nextTypePathForCurrentEntity,
        to: nextNodeForCurrentEntity,
        ofType: nextTypeForCurrentEntity,
        withRootTypePath: currentNodeRootTypePath
      )
    }

    private func mergeIn(
      selections: IR.SortedSelections,
      withTypeScope currentSelectionScopeTypeCase: LinkedList<GraphQLCompositeType>.Node,
      toFieldNode node: FieldScopeNode,
      ofType fieldNodeType: GraphQLCompositeType
    ) {
      guard let nextTypeCaseInScope = currentSelectionScopeTypeCase.next else {
        let typeForSelections = currentSelectionScopeTypeCase.value

        if fieldNodeType == typeForSelections {
          node.mergeIn(selections)
          return

        } else {
          let fieldTypeCaseNode = node.typeCaseNode(forType: typeForSelections)
          fieldTypeCaseNode.mergeIn(selections)
          return
        }
      }

      let nextNodeForField = fieldNodeType != nextTypeCaseInScope.value
      ? node.typeCaseNode(forType: nextTypeCaseInScope.value) : node

      mergeIn(
        selections: selections,
        withTypeScope: nextTypeCaseInScope,
        toFieldNode: nextNodeForField,
        ofType: nextTypeCaseInScope.value
      )
    }

    // MARK: - Calculate Merged Selections From Tree

    func addMergedSelections(
      matchingTypePath typePath: LinkedList<TypeScopeDescriptor>,
      into selections: SelectionSet.Selections
    ) {
      rootNode.mergeSelections(matchingTypePath: typePath.head, into: selections)
    }

    class EnclosingEntityNode: MergedSelectionTreeNode {
      enum Child: MergedSelectionTreeNode {
        case enclosingEntity(EnclosingEntityNode)
        case fieldScope(FieldScopeNode)

        func mergeSelections(
          matchingTypePath typePath: LinkedList<TypeScopeDescriptor>.Node,
          into selections: IR.SelectionSet.Selections
        ) {
          switch self {
          case let .enclosingEntity(node as MergedSelectionTreeNode),
            let .fieldScope(node as MergedSelectionTreeNode):
            node.mergeSelections(matchingTypePath: typePath, into: selections)
          }
        }
      }

      var child: Child?
      var typeCases: OrderedDictionary<GraphQLCompositeType, EnclosingEntityNode>?

      func mergeSelections(
        matchingTypePath typePath: LinkedList<TypeScopeDescriptor>.Node,
        into selections: IR.SelectionSet.Selections
      ) {
        guard let nextTypePathNode = typePath.next else {
          guard case let .fieldScope(node) = child else { fatalError() }
          node.mergeSelections(matchingTypePath: typePath, into: selections)
          return
        }

        if let child = child {
          child.mergeSelections(matchingTypePath: nextTypePathNode, into: selections)
        }

        if let typeCases = typeCases {
          for (typeCase, node) in typeCases {
            if typePath.value.matches(typeCase) {
              node.mergeSelections(matchingTypePath: typePath, into: selections)
            }
          }
        }
      }

      fileprivate func childAsEnclosingEntityNode() -> EnclosingEntityNode {
        guard let child = child else {
          let node = EnclosingEntityNode()
          self.child = .enclosingEntity(node)
          return node
        }

        guard case let .enclosingEntity(child) = child else {
          fatalError()
        }

        return child
      }

      fileprivate func childAsFieldScopeNode() -> FieldScopeNode {
        guard let child = child else {
          let node = FieldScopeNode()
          self.child = .fieldScope(node)
          return node
        }

        guard case let .fieldScope(child) = child else {
          fatalError()
        }

        return child
      }

      fileprivate func typeCaseNode(forType type: GraphQLCompositeType) -> EnclosingEntityNode {
        guard var typeCases = typeCases else {
          let node = EnclosingEntityNode()
          self.typeCases = [type: node]
          return node
        }

        guard let node = typeCases[type] else {
          let node = EnclosingEntityNode()
          typeCases[type] = node
          self.typeCases = typeCases
          return node
        }

        return node
      }
    }

    class FieldScopeNode: MergedSelectionTreeNode {
      var selections: ShallowSelections?
      var typeCases: OrderedDictionary<GraphQLCompositeType, FieldScopeNode>?

      fileprivate func mergeIn(_ selections: SortedSelections) {
        var fieldSelections = self.selections ?? ShallowSelections()
        fieldSelections.mergeIn(selections)
        self.selections = fieldSelections
      }

      func mergeSelections(
        matchingTypePath typePath: LinkedList<TypeScopeDescriptor>.Node,
        into selections: IR.SelectionSet.Selections
      ) {
        if let scopeSelections = self.selections {
          selections.addMergedSelections(scopeSelections)
        }

        if let typeCases = typeCases {
          for (typeCase, node) in typeCases {
            if typePath.value.matches(typeCase) {
              node.mergeSelections(matchingTypePath: typePath, into: selections)
            }
          }
        }
      }

      fileprivate func typeCaseNode(forType type: GraphQLCompositeType) -> FieldScopeNode {
        guard var typeCases = typeCases else {
          let node = FieldScopeNode()
          self.typeCases = [type: node]
          return node
        }

        guard let node = typeCases[type] else {
          let node = FieldScopeNode()
          typeCases[type] = node
          self.typeCases = typeCases
          return node
        }

        return node
      }
    }
  }
}

extension IR.MergedSelectionTree: CustomDebugStringConvertible {
  var debugDescription: String {
    """
    rootTypePath: \(rootTypePath.debugDescription)
    \(rootNode.debugDescription)
    """
  }
}

extension IR.MergedSelectionTree.EnclosingEntityNode: CustomDebugStringConvertible {
  var debugDescription: String {
    """
    {
      child:
        \(indented: child?.debugDescription ?? "nil")
      typeCases:
        \(indented: typeCases?.debugDescription ?? "[]")
    }
    """
  }
}

extension IR.MergedSelectionTree.FieldScopeNode: CustomDebugStringConvertible {
  var debugDescription: String {
    """
    {
      selections:
        \(indented: selections?.debugDescription ?? "[]")
      typeCases:
        \(indented: typeCases?.debugDescription ?? "[]")
    }
    """
  }
}

extension IR.MergedSelectionTree.EnclosingEntityNode.Child: CustomDebugStringConvertible {
  var debugDescription: String {
    switch self {
    case let .enclosingEntity(node): return node.debugDescription
    case let .fieldScope(node): return node.debugDescription
    }
  }
}
