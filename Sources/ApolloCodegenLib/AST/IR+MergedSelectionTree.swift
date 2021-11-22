import ApolloUtils

extension IR {
  class MergedSelectionTree {
    let rootTypePath: LinkedList<TypeScopeDescriptor>
    lazy var rootNode = EnclosingEntityNode()

    init(rootTypePath: LinkedList<TypeScopeDescriptor>) {
      self.rootTypePath = rootTypePath
    }

    func mergeIn(selectionSet: SelectionSet) {
      var currentRootScope: LinkedList<TypeScopeDescriptor>.Node? = rootTypePath.last
      var currentSelectionScope: LinkedList<TypeScopeDescriptor>.Node? = selectionSet.typePath.last
      var currentNode = rootNode

      func advanceToNextScope() {
        currentRootScope = currentRootScope?.next
        currentSelectionScope = currentSelectionScope?.next
      }

      while let currentRootScope = currentRootScope {
        func isEndOfTree() -> Bool { currentRootScope.next == nil }
        func selectionSetTypeMatchesRootType() -> Bool {
          currentRootScope.value.type == currentSelectionScope?.value.type
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
          continue
        }
      }
    }

    func mergedSelections(forSelectionSet selectionSet: SelectionSet) -> SortedSelections {
      return SortedSelections()
    }

    class EnclosingEntityNode {
      enum Child {
        case enclosingEntity(EnclosingEntityNode)
        case fieldScope(FieldScopeNode)
      }

      var child: Child?
      var typeCases: [GraphQLCompositeType: EnclosingEntityNode]?

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

    class FieldScopeNode {
      var selections: SortedSelections?
      var typeCases: [GraphQLCompositeType: FieldScopeNode]?

      fileprivate func mergeIn(_ selections: SortedSelections) {
        var fieldSelections = self.selections ?? SortedSelections()
        fieldSelections.mergeIn(selections)
        self.selections = fieldSelections
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
