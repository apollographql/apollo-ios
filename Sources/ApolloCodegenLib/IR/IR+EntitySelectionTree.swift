import ApolloUtils
import Darwin
import OrderedCollections

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
    
    func mergeIn(
      selectionSet: SelectionSet,
      inFragmentSpread fragmentSpread: FragmentSpread? = nil
    ) {
      let source = MergedSelections.MergedSource(
        typeInfo: selectionSet.typeInfo,
        fragment: fragmentSpread
      )
      mergeIn(selectionSet: selectionSet, from: source)
    }

    private func mergeIn(selectionSet: SelectionSet, from source: MergedSelections.MergedSource) {
      guard let directSelections = selectionSet.selections.direct,
            (!directSelections.fields.isEmpty || !directSelections.fragments.isEmpty) else {
              return
            }

      mergeIn(
        selections: directSelections,
        from: source,
        atEnclosingEntityScope: selectionSet.typeInfo.scopePath.head,
        withEntityScopePath: selectionSet.typeInfo.scopePath.head.value.scopePath.head,
        to: rootNode,
        withCondition: ScopeCondition(type: rootTypePath.head.value),
        withRootTypePath: rootTypePath.head
      )
    }

    private func mergeIn(
      selections: DirectSelections,
      from source: MergedSelections.MergedSource,
      atEnclosingEntityScope currentEntityScope: LinkedList<ScopeDescriptor>.Node,
      withEntityScopePath currentEntityConditionPath: LinkedList<ScopeCondition>.Node,
      to node: EnclosingEntityNode,
      withCondition currentNodeCondition: ScopeCondition,
      withRootTypePath currentNodeRootTypePath: LinkedList<GraphQLCompositeType>.Node
    ) {
      guard let nextEntityTypePath = currentNodeRootTypePath.next else {
        // Advance to field node in current entity & type case
        let fieldNode = node.childAsFieldScopeNode()
        mergeIn(
          selections: selections,
          from: source,
          withConditionScopePath: currentEntityScope.value.scopePath.head,
          toFieldNode: fieldNode,
          withCondition: ScopeCondition(type: currentNodeRootTypePath.value)
        )
        return
      }

      guard let nextConditionPathForCurrentEntity = currentEntityConditionPath.next else {
        // Advance to next entity
        guard let nextEntityScope = currentEntityScope.next else { fatalError() }
        let nextEntityNode = node.childAsEnclosingEntityNode()

        mergeIn(
          selections: selections,
          from: source,
          atEnclosingEntityScope: nextEntityScope,
          withEntityScopePath: nextEntityScope.value.scopePath.head,
          to: nextEntityNode,
          withCondition: ScopeCondition(type: nextEntityTypePath.value),
          withRootTypePath: nextEntityTypePath
        )
        return
      }

      // Advance to next type case in current entity
      let nextCondition = nextConditionPathForCurrentEntity.value

      let nextNodeForCurrentEntity = currentNodeCondition != nextCondition
      ? node.scopeConditionNode(for: nextCondition) : node

      mergeIn(
        selections: selections,
        from: source,
        atEnclosingEntityScope: currentEntityScope,
        withEntityScopePath: nextConditionPathForCurrentEntity,
        to: nextNodeForCurrentEntity,
        withCondition: nextCondition,
        withRootTypePath: currentNodeRootTypePath
      )
    }

    private func mergeIn(
      selections: DirectSelections,
      from source: IR.MergedSelections.MergedSource,
      withConditionScopePath selectionsScopePath: LinkedList<ScopeCondition>.Node,
      toFieldNode node: FieldScopeNode,
      withCondition fieldNodeCondition: ScopeCondition
    ) {
      guard let nextConditionInScopePath = selectionsScopePath.next else {
        // Last condition in field scope path
        let selectionsCondition = selectionsScopePath.value
        if fieldNodeCondition == selectionsCondition {
          node.mergeIn(selections, from: source)
          return

        } else {
          let fieldTypeCaseNode = node.scopeConditionNode(for: selectionsCondition)
          fieldTypeCaseNode.mergeIn(selections, from: source)
          return
        }
      }

      let nextCondition = nextConditionInScopePath.value
      let nextNodeForField = fieldNodeCondition != nextCondition
      ? node.scopeConditionNode(for: nextCondition) : node

      mergeIn(
        selections: selections,
        from: source,
        withConditionScopePath: nextConditionInScopePath,
        toFieldNode: nextNodeForField,
        withCondition: nextCondition
      )
    }

    // MARK: - Calculate Merged Selections From Tree

    func addMergedSelections(into selections: IR.MergedSelections) {
      let rootTypePath = selections.typeInfo.scopePath.head
      rootNode.mergeSelections(matchingScopePath: rootTypePath, into: selections)
    }

    class EnclosingEntityNode {
      enum Child {
        case enclosingEntity(EnclosingEntityNode)
        case fieldScope(FieldScopeNode)

        func mergeSelections(
          matchingScopePath typePath: LinkedList<ScopeDescriptor>.Node,
          into selections: IR.MergedSelections
        ) {
          switch self {
          case let .enclosingEntity(node):
            node.mergeSelections(matchingScopePath: typePath, into: selections)
          case let .fieldScope(node):
            node.mergeSelections(matchingScopePath: typePath, into: selections)
          }
        }
      }

      var child: Child?
      var scopeConditions: OrderedDictionary<ScopeCondition, EnclosingEntityNode>?

      func mergeSelections(
        matchingScopePath typePath: LinkedList<ScopeDescriptor>.Node,
        into selections: IR.MergedSelections
      ) {
        guard let nextTypePathNode = typePath.next else {
          guard case let .fieldScope(node) = child else { fatalError() }
          node.mergeSelections(matchingScopePath: typePath, into: selections)
          return
        }

        if let child = child {
          child.mergeSelections(matchingScopePath: nextTypePathNode, into: selections)
        }

        if let typeCases = scopeConditions {
          for (typeCase, node) in typeCases {
            if typePath.value.matches(typeCase) {
              node.mergeSelections(matchingScopePath: typePath, into: selections)
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

      fileprivate func scopeConditionNode(for condition: ScopeCondition) -> EnclosingEntityNode {
        guard var scopeConditions = scopeConditions else {
          let node = EnclosingEntityNode()
          self.scopeConditions = [condition: node]
          return node
        }

        guard let node = scopeConditions[condition] else {
          let node = EnclosingEntityNode()
          scopeConditions[condition] = node
          self.scopeConditions = scopeConditions
          return node
        }

        return node
      }
    }

    class FieldScopeNode {
      var selections: OrderedDictionary<MergedSelections.MergedSource, EntityTreeScopeSelections> = [:]
      var scopeConditions: OrderedDictionary<ScopeCondition, FieldScopeNode>?

      fileprivate func mergeIn(
        _ selections: DirectSelections,
        from source: IR.MergedSelections.MergedSource
      ) {
        var selectionsFromSource = self.selections[source] ?? EntityTreeScopeSelections()
        selectionsFromSource.mergeIn(selections)
        self.selections[source] = selectionsFromSource
      }

      func mergeSelections(
        matchingScopePath typePathNode: LinkedList<ScopeDescriptor>.Node,
        into selections: IR.MergedSelections
      ) {
        for (source, scopeSelections) in self.selections {
          selections.mergeIn(scopeSelections, from: source)
        }

        if let conditionalScopes = scopeConditions {
          for (condition, node) in conditionalScopes {
            if typePathNode.value.matches(condition) {
              node.mergeSelections(matchingScopePath: typePathNode, into: selections)

            } else {
              selections.addMergedConditionalSelectionSet(with: condition)
            }
          }
        }
      }

      fileprivate func scopeConditionNode(for condition: ScopeCondition) -> FieldScopeNode {
        guard var scopeConditions = scopeConditions else {
          let node = FieldScopeNode()
          self.scopeConditions = [condition: node]
          return node
        }

        guard let node = scopeConditions[condition] else {
          let node = FieldScopeNode()
          scopeConditions[condition] = node
          self.scopeConditions = scopeConditions
          return node
        }

        return node
      }
    }
  }

  struct EntityTreeScopeSelections: Equatable, CustomDebugStringConvertible {
    fileprivate(set) var fields: OrderedDictionary<String, Field> = [:]
    fileprivate(set) var fragments: OrderedDictionary<String, FragmentSpread> = [:]

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

    private mutating func mergeIn(_ fragment: FragmentSpread) {
      fragments[fragment.hashForSelectionSetScope] = fragment
    }

    private mutating func mergeIn<T: Sequence>(_ fragments: T) where T.Element == FragmentSpread {
      fragments.forEach { mergeIn($0) }
    }

    mutating func mergeIn(_ selections: DirectSelections) {
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
      conditionalScopes:
        \(indented: scopeConditions?.debugDescription ?? "[]")
    }
    """
  }
}

extension IR.EntitySelectionTree.FieldScopeNode: CustomDebugStringConvertible {
  var debugDescription: String {
    """
    {
      selections:
        \(indented: selections.debugDescription)
      conditionalScopes:
        \(indented: scopeConditions?.debugDescription ?? "[]")
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
