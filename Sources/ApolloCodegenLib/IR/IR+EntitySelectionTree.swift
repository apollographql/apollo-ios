import ApolloUtils
import Darwin
import OrderedCollections

fileprivate protocol EntitySelectionTreeNode {
  func mergeSelections(
    matchingTypePath typePath: LinkedList<TypeScopeDescriptor>.Node,
    into selections: IR.MergedSelections
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
  /// to the `EntitySelectionTree`, the tree can be quickly traversed to collect the selections
  /// that will be selected for a given `SelectionSet`'s type scope.
  class EntitySelectionTree {
    let rootTypePath: LinkedList<GraphQLCompositeType>
    lazy var rootNode = EnclosingEntityNode()

    init(rootTypePath: LinkedList<GraphQLCompositeType>) {
      self.rootTypePath = rootTypePath
    }

    // MARK: - Merge Selection Sets Into Tree
    
    func mergeIn(selectionSet: SelectionSet) {
      guard let directSelections = selectionSet.selections.direct else { return }
      let source = MergedSelections.MergedSource(typePath: selectionSet.typeInfo, fragment: nil)
      mergeIn(
        selections: directSelections,
        from: source,
        atEnclosingEntityScope: selectionSet.typeInfo.typePath.head,
        withEntityTypePath: selectionSet.typeInfo.typePath.head.value.typePath.head,
        to: rootNode,
        ofType: rootTypePath.head.value,
        withRootTypePath: rootTypePath.head
      )
    }

    private func mergeIn(
      selections: DirectSelections,
      from source: MergedSelections.MergedSource,
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
          from: source,
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
          from: source,
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
        from: source,
        atEnclosingEntityScope: currentEntityScope,
        withEntityTypePath: nextTypePathForCurrentEntity,
        to: nextNodeForCurrentEntity,
        ofType: nextTypeForCurrentEntity,
        withRootTypePath: currentNodeRootTypePath
      )
    }

    private func mergeIn(
      selections: DirectSelections,
      from source: IR.MergedSelections.MergedSource,
      withTypeScope currentSelectionScopeTypeCase: LinkedList<GraphQLCompositeType>.Node,
      toFieldNode node: FieldScopeNode,
      ofType fieldNodeType: GraphQLCompositeType
    ) {
      guard let nextTypeCaseInScope = currentSelectionScopeTypeCase.next else {
        let typeForSelections = currentSelectionScopeTypeCase.value

        if fieldNodeType == typeForSelections {
          node.mergeIn(selections, from: source)
          return

        } else {
          let fieldTypeCaseNode = node.typeCaseNode(forType: typeForSelections)
          fieldTypeCaseNode.mergeIn(selections, from: source)
          return
        }
      }

      let nextNodeForField = fieldNodeType != nextTypeCaseInScope.value
      ? node.typeCaseNode(forType: nextTypeCaseInScope.value) : node

      mergeIn(
        selections: selections,
        from: source,
        withTypeScope: nextTypeCaseInScope,
        toFieldNode: nextNodeForField,
        ofType: nextTypeCaseInScope.value
      )
    }

    // MARK: - Calculate Merged Selections From Tree

    func addMergedSelections(into selections: IR.MergedSelections) {
      let rootTypePath = selections.typeInfo.typePath.head
      rootNode.mergeSelections(matchingTypePath: rootTypePath, into: selections)
    }

    class EnclosingEntityNode: EntitySelectionTreeNode {
      enum Child: EntitySelectionTreeNode {
        case enclosingEntity(EnclosingEntityNode)
        case fieldScope(FieldScopeNode)

        func mergeSelections(
          matchingTypePath typePath: LinkedList<TypeScopeDescriptor>.Node,
          into selections: IR.MergedSelections
        ) {
          switch self {
          case let .enclosingEntity(node as EntitySelectionTreeNode),
            let .fieldScope(node as EntitySelectionTreeNode):
            node.mergeSelections(matchingTypePath: typePath, into: selections)
          }
        }
      }

      var child: Child?
      var typeCases: OrderedDictionary<GraphQLCompositeType, EnclosingEntityNode>?

      func mergeSelections(
        matchingTypePath typePath: LinkedList<TypeScopeDescriptor>.Node,
        into selections: IR.MergedSelections
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

    class FieldScopeNode: EntitySelectionTreeNode {
      var selections: EntityTreeScopeSelections?
      var typeCases: OrderedDictionary<GraphQLCompositeType, FieldScopeNode>?

      fileprivate func mergeIn(
        _ selections: DirectSelections,
        from source: IR.MergedSelections.MergedSource
      ) {
        var fieldSelections = self.selections ?? EntityTreeScopeSelections()
        fieldSelections.mergeIn(selections, from: source)
        self.selections = fieldSelections
      }

      func mergeSelections(
        matchingTypePath typePath: LinkedList<TypeScopeDescriptor>.Node,
        into selections: IR.MergedSelections
      ) {
        if let scopeSelections = self.selections {
          selections.mergeIn(scopeSelections)
        }

        if let typeCases = typeCases {
          for (typeCase, node) in typeCases {
            if typePath.value.matches(typeCase) {
              node.mergeSelections(matchingTypePath: typePath, into: selections)

            } else {
              selections.addMergedTypeCase(withType: typeCase)
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

  struct EntityTreeScopeSelections: Equatable, CustomDebugStringConvertible
  {
    typealias Field = IR.Field
    typealias Fragment = IR.FragmentSpread

    fileprivate(set) var fields: OrderedDictionary<String, Field> = [:]
    fileprivate(set) var fragments: OrderedDictionary<String, Fragment> = [:]
    fileprivate(set) var mergedSources: MergedSelections.MergedSources = []

    init() {}

    var isEmpty: Bool {
      fields.isEmpty && fragments.isEmpty
    }

    private mutating func mergeIn(_ field: Field) {
      fields[field.hashForSelectionSetScope] = field
    }

    private mutating func mergeIn<T: Sequence>(_ fields: T) where T.Element == Field {
      fields.forEach { mergeIn($0) }
    }

    private mutating func mergeIn(_ fragment: Fragment) {
      fragments[fragment.hashForSelectionSetScope] = fragment
    }

    private mutating func mergeIn<T: Sequence>(_ fragments: T) where T.Element == Fragment {
      fragments.forEach { mergeIn($0) }
    }

    mutating func mergeIn(
      _ selections: DirectSelections,
      from source: IR.MergedSelections.MergedSource
    ) {
      mergedSources.insert(source)
      mergeIn(selections.fields.values)
      mergeIn(selections.fragments.values)
    }

    var debugDescription: String {
      """
      Fields: \(fields.values.elements)
      Fragments: \(fragments.values.elements.map(\.definition.name))
      """
    }
  }
}

extension IR.EntitySelectionTree: CustomDebugStringConvertible {
  var debugDescription: String {
    """
    rootTypePath: \(rootTypePath.debugDescription)
    \(rootNode.debugDescription)
    """
  }
}

extension IR.EntitySelectionTree.EnclosingEntityNode: CustomDebugStringConvertible {
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

extension IR.EntitySelectionTree.FieldScopeNode: CustomDebugStringConvertible {
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

extension IR.EntitySelectionTree.EnclosingEntityNode.Child: CustomDebugStringConvertible {
  var debugDescription: String {
    switch self {
    case let .enclosingEntity(node): return node.debugDescription
    case let .fieldScope(node): return node.debugDescription
    }
  }
}
