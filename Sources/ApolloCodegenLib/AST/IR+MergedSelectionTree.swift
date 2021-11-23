import ApolloUtils
import Darwin

fileprivate protocol MergedSelectionTreeNode {
  func mergeSelections(
    matchingTypePath typePath: LinkedList<TypeScopeDescriptor>.Node,
    into selections: inout IR.SortedSelections
  )
}

extension IR {
  class MergedSelectionTree {
    let rootTypePath: LinkedList<TypeScopeDescriptor>
    lazy var rootNode = EnclosingEntityNode()

    init(rootTypePath: LinkedList<TypeScopeDescriptor>) {
      self.rootTypePath = rootTypePath
    }

    func mergeIn(selectionSet: SelectionSet) {
      var currentRootScope: LinkedList<TypeScopeDescriptor>.Node? = rootTypePath.head
      var currentSelectionScope: LinkedList<TypeScopeDescriptor>.Node? = selectionSet.typePath.head
      var currentNode = rootNode
      var currentNodeType = currentRootScope?.value.type

      func advanceToNextScope() {
        currentRootScope = currentRootScope?.next
        currentSelectionScope = currentSelectionScope?.next
        currentNodeType = currentRootScope?.value.type
      }

      while let currentRootScope = currentRootScope {
        func isEndOfTree() -> Bool { currentRootScope.next == nil }
        func selectionSetTypeMatchesRootType() -> Bool {
          currentNodeType == currentSelectionScope?.value.type
        }

        switch (selectionSetTypeMatchesRootType(), isEndOfTree()) {
        case (true, true):
          // Add selections to field node for root type
          let fieldNode = currentNode.childAsFieldScopeNode()
          fieldNode.mergeIn(selectionSet.selections)
          return

        case (true, false):
          // Advance to next node in root type
          currentNode = currentNode.childAsEnclosingEntityNode()
          advanceToNextScope()
          continue

        case (false, true):
          // Add selections to field node as type case
          guard let selectionScopeType = currentSelectionScope?.value.type else { fatalError() }
          let fieldNode = currentNode.childAsFieldScopeNode()
          let typeCaseNode = fieldNode.typeCaseNode(forType: selectionScopeType)
          typeCaseNode.mergeIn(selectionSet.selections)
          return

        case (false, false):
          // Advance to next node in type case
          guard let selectionScopeType = currentSelectionScope?.value.type else { fatalError() }
          currentNode = currentNode.typeCaseNode(forType: selectionScopeType)
          currentNodeType = selectionScopeType
          continue
        }
      }
    }

    func mergedSelections(forSelectionSet selectionSet: SelectionSet) -> SortedSelections {
      var selections = selectionSet.selections
      rootNode.mergeSelections(matchingTypePath: selectionSet.typePath.head, into: &selections)
      return selections
    }

    class EnclosingEntityNode: MergedSelectionTreeNode {
      enum Child: MergedSelectionTreeNode {
        case enclosingEntity(EnclosingEntityNode)
        case fieldScope(FieldScopeNode)

        func mergeSelections(
          matchingTypePath typePath: LinkedList<TypeScopeDescriptor>.Node,
          into selections: inout IR.SortedSelections
        ) {
          switch self {
          case let .enclosingEntity(node as MergedSelectionTreeNode),
            let .fieldScope(node as MergedSelectionTreeNode):
            node.mergeSelections(matchingTypePath: typePath, into: &selections)
          }
        }
      }

      var child: Child?
      var typeCases: [GraphQLCompositeType: EnclosingEntityNode]?

      func mergeSelections(
        matchingTypePath typePath: LinkedList<TypeScopeDescriptor>.Node,
        into selections: inout IR.SortedSelections
      ) {
        guard let nextTypePathNode = typePath.next else {
          guard case let .fieldScope(node) = child else { fatalError() }
          node.mergeSelections(matchingTypePath: typePath, into: &selections)
          return
        }

        if let child = child {
          child.mergeSelections(matchingTypePath: nextTypePathNode, into: &selections)
        }

        if let typeCases = typeCases {
          for (typeCase, node) in typeCases {
            if typePath.value.matches(typeCase) {
              node.mergeSelections(matchingTypePath: typePath, into: &selections)
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
      var selections: SortedSelections?
      var typeCases: [GraphQLCompositeType: FieldScopeNode]?

      fileprivate func mergeIn(_ selections: SortedSelections) {
        var fieldSelections = self.selections ?? SortedSelections()
        fieldSelections.mergeIn(selections)
        self.selections = fieldSelections
      }

      func mergeSelections(
        matchingTypePath typePath: LinkedList<TypeScopeDescriptor>.Node,
        into selections: inout IR.SortedSelections
      ) {
        if let scopeSelections = self.selections {
          selections.mergeIn(scopeSelections)
        }

        if let typeCases = typeCases {
          for (typeCase, node) in typeCases {
            if typePath.value.matches(typeCase) {
              node.mergeSelections(matchingTypePath: typePath, into: &selections)
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
    child:
      \(indented: child?.debugDescription ?? "nil")
    typeCases: \(typeCases?.debugDescription ?? "[]")\n
    """
  }
}

extension IR.MergedSelectionTree.FieldScopeNode: CustomDebugStringConvertible {
  var debugDescription: String {
    """
    selections:
      \(indented: selections?.debugDescription ?? "[]")
    typeCases: \(typeCases?.debugDescription ?? "[]")\n
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
