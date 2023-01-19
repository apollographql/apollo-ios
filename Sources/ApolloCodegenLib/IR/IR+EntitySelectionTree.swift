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
    let rootNode: EnclosingEntityNode

    init(rootTypePath: LinkedList<GraphQLCompositeType>) {
      self.rootTypePath = rootTypePath
      self.rootNode = EnclosingEntityNode(rootTypePath: rootTypePath)
    }

    // MARK: - Merge Selection Sets Into Tree
    
    func mergeIn(
      selections: DirectSelections.ReadOnly,
      with typeInfo: SelectionSet.TypeInfo
    ) {
      let source = MergedSelections.MergedSource(
        typeInfo: typeInfo,
        fragment: nil
      )
      mergeIn(selections: selections, from: source)
    }

    private func mergeIn(selections: DirectSelections.ReadOnly, from source: MergedSelections.MergedSource) {
      guard (!selections.fields.isEmpty || !selections.fragments.isEmpty) else {
        return
      }

      let targetNode = Self.findOrCreateNode(
        atEnclosingEntityScope: source.typeInfo.scopePath.head,
        withEntityScopePath: source.typeInfo.scopePath.head.value.scopePath.head,
        from: rootNode,
        withRootTypePath: rootTypePath.head
      )

      targetNode.mergeIn(selections, from: source)
    }

    fileprivate static func findOrCreateNode(
      atEnclosingEntityScope currentEntityScope: LinkedList<ScopeDescriptor>.Node,
      withEntityScopePath currentEntityConditionPath: LinkedList<ScopeCondition>.Node,
      from node: EnclosingEntityNode,
      withRootTypePath currentRootTypePathNode: LinkedList<GraphQLCompositeType>.Node
    ) -> EnclosingEntityNode {
      guard let nextEntityTypePath = currentRootTypePathNode.next else {
        // Advance to field node in current entity & type case
        return Self.findOrCreateNode(
          withConditionScopePath: currentEntityScope.value.scopePath.head,
          from: node
        )
      }

      guard let nextConditionPathForCurrentEntity = currentEntityConditionPath.next else {
        // Advance to next entity
        guard let nextEntityScope = currentEntityScope.next else { fatalError() }
        let nextEntityNode = node.childAsEnclosingEntityNode()

        return findOrCreateNode(
          atEnclosingEntityScope: nextEntityScope,
          withEntityScopePath: nextEntityScope.value.scopePath.head,
          from: nextEntityNode,
          withRootTypePath: nextEntityTypePath
        )
      }

      // Advance to next type case in current entity
      let nextCondition = nextConditionPathForCurrentEntity.value

      let nextNodeForCurrentEntity = node.scope != nextCondition
      ? node.scopeConditionNode(for: nextCondition) : node

      return findOrCreateNode(
        atEnclosingEntityScope: currentEntityScope,
        withEntityScopePath: nextConditionPathForCurrentEntity,
        from: nextNodeForCurrentEntity,
        withRootTypePath: currentRootTypePathNode
      )
    }

    private static func findOrCreateNode(
      withConditionScopePath selectionsScopePath: LinkedList<ScopeCondition>.Node,
      from node: EnclosingEntityNode
    ) -> EnclosingEntityNode {
      guard let nextConditionInScopePath = selectionsScopePath.next else {
        // Last condition in field scope path
        let selectionsCondition = selectionsScopePath.value

        return selectionsCondition == node.scope ?
        node : node.scopeConditionNode(for: selectionsCondition)
      }

      let nextCondition = nextConditionInScopePath.value
      let nextConditionNode = node.scopeConditionNode(for: nextCondition)

      return findOrCreateNode(
        withConditionScopePath: nextConditionInScopePath,
        from: nextConditionNode
      )
    }

    // MARK: - Calculate Merged Selections From Tree

    func addMergedSelections(into selections: IR.MergedSelections) {
      let rootTypePath = selections.typeInfo.scopePath.head
      rootNode.mergeSelections(matchingScopePath: rootTypePath, into: selections)
    }

    class EnclosingEntityNode {
      typealias Selections = OrderedDictionary<MergedSelections.MergedSource, EntityTreeScopeSelections>
      enum Child {
        case enclosingEntity(EnclosingEntityNode)
        case selections(Selections)
      }

      let rootTypePathNode: LinkedList<GraphQLCompositeType>.Node
      let type: GraphQLCompositeType
      let scope: ScopeCondition
      private(set) var child: Child?
      var scopeConditions: OrderedDictionary<ScopeCondition, EnclosingEntityNode>?

      fileprivate convenience init(rootTypePath: LinkedList<GraphQLCompositeType>) {
        self.init(typeNode: rootTypePath.head)
      }

      private init(typeNode: LinkedList<GraphQLCompositeType>.Node) {
        self.scope = .init(type: typeNode.value)
        self.type = typeNode.value
        self.rootTypePathNode = typeNode

        if let nextNode = typeNode.next {
          child = .enclosingEntity(EnclosingEntityNode(typeNode: nextNode))
        } else {
          child = .selections([:])
        }
      }

      private init(
        scope: IR.ScopeCondition,
        type: GraphQLCompositeType,
        rootTypePathNode: LinkedList<GraphQLCompositeType>.Node
      ) {
        self.scope = scope
        self.type = type
        self.rootTypePathNode = rootTypePathNode
      }

      fileprivate func mergeIn(
        _ selections: DirectSelections.ReadOnly,
        from source: IR.MergedSelections.MergedSource
      ) {
        updateSelections {
          $0.updateValue(forKey: source, default: EntityTreeScopeSelections()) {
            $0.mergeIn(selections)
          }
        }
      }

      fileprivate func mergeIn(
        _ selections: EntityTreeScopeSelections,
        from source: IR.MergedSelections.MergedSource
      ) {
        updateSelections {
          $0.updateValue(forKey: source, default: EntityTreeScopeSelections()) {
            $0.mergeIn(selections)
          }
        }
      }

      private func updateSelections(_ block: (inout Selections) -> Void) {
        var entitySelections: Selections

        switch child {
        case .enclosingEntity:
          fatalError(
            "Selection Merging Error. Please create an issue on Github to report this."
          )

        case let .selections(currentSelections):
          entitySelections = currentSelections

        case .none:
          entitySelections = Selections()
        }

        block(&entitySelections)
        self.child = .selections(entitySelections)
      }

      func mergeSelections(
        matchingScopePath scopePathNode: LinkedList<ScopeDescriptor>.Node,
        into targetSelections: IR.MergedSelections
      ) {
        switch child {
        case let .enclosingEntity(entityNode):
          guard let nextScopePathNode = scopePathNode.next else { return }
          entityNode.mergeSelections(matchingScopePath: nextScopePathNode, into: targetSelections)

        case let .selections(selections):
          for (source, scopeSelections) in selections {
            targetSelections.mergeIn(scopeSelections, from: source)
          }

          if let conditionalScopes = scopeConditions {
            for (condition, node) in conditionalScopes {
              if scopePathNode.value.matches(condition) {
                node.mergeSelections(matchingScopePath: scopePathNode, into: targetSelections)

              } else {
                targetSelections.addMergedInlineFragment(with: condition)
              }
            }
          }

        case .none: break
        }

        if let scopeConditions = scopeConditions {
          for (condition, node) in scopeConditions {
            if scopePathNode.value.matches(condition) {
              node.mergeSelections(matchingScopePath: scopePathNode, into: targetSelections)
            }
          }
        }
      }

      fileprivate func childAsEnclosingEntityNode() -> EnclosingEntityNode {
        switch child {
        case let .enclosingEntity(node):
          return node

        case .selections:
          fatalError(
            "Selection Merging Error. Please create an issue on Github to report this."
          )

        case .none:
          let node = EnclosingEntityNode(typeNode: self.rootTypePathNode.next!)
          self.child = .enclosingEntity(node)
          return node
        }
      }

//      fileprivate func childAsFieldScopeNode(scope: ScopeCondition) -> FieldScopeNode {
//        guard let child = child else {
//          let node = FieldScopeNode(scope: scope)
//          self.child = .fieldScope(node)
//          return node
//        }
//
//        guard case let .fieldScope(child) = child, child.scope == scope else {
//          fatalError()
//        }
//
//        return child
//      }

      fileprivate func scopeConditionNode(for condition: ScopeCondition) -> EnclosingEntityNode {
        let nodeCondition = ScopeCondition(
          type: condition.type == self.type ? nil : condition.type,
          conditions: condition.conditions
        )

        func createNode() -> EnclosingEntityNode {
          // When initializing as a conditional scope node, if the `scope` does not have a
          // type condition, we should inherit the parent node's type.
          let nodeType = nodeCondition.type ?? self.type

          return EnclosingEntityNode(
            scope: nodeCondition,
            type: nodeType,
            rootTypePathNode: self.rootTypePathNode
          )
        }

        guard var scopeConditions = scopeConditions else {
          let node = createNode()
          self.scopeConditions = [nodeCondition: node]
          return node
        }

        guard let node = scopeConditions[condition] else {
          let node = createNode()
          scopeConditions[nodeCondition] = node
          self.scopeConditions = scopeConditions
          return node
        }

        return node
      }
    }
  }

  class EntityTreeScopeSelections: Equatable {

    fileprivate(set) var fields: OrderedDictionary<String, Field> = [:]
    fileprivate(set) var fragments: OrderedDictionary<String, FragmentSpread> = [:]

    init() {}

    fileprivate init(
      fields: OrderedDictionary<String, Field>,
      fragments: OrderedDictionary<String, FragmentSpread>
    ) {
      self.fields = fields
      self.fragments = fragments
    }

    var isEmpty: Bool {
      fields.isEmpty && fragments.isEmpty
    }

    private func mergeIn(_ field: Field) {
      fields[field.hashForSelectionSetScope] = field
    }

    private func mergeIn<T: Sequence>(_ fields: T) where T.Element == Field {
      fields.forEach { mergeIn($0) }
    }

    private func mergeIn(_ fragment: FragmentSpread) {
      fragments[fragment.hashForSelectionSetScope] = fragment
    }

    private func mergeIn<T: Sequence>(_ fragments: T) where T.Element == FragmentSpread {
      fragments.forEach { mergeIn($0) }
    }

    func mergeIn(_ selections: DirectSelections.ReadOnly) {
      mergeIn(selections.fields.values)
      mergeIn(selections.fragments.values)
    }

    func mergeIn(_ selections: EntityTreeScopeSelections) {
      mergeIn(selections.fields.values)
      mergeIn(selections.fragments.values)
    }

    static func == (lhs: IR.EntityTreeScopeSelections, rhs: IR.EntityTreeScopeSelections) -> Bool {
      lhs.fields == rhs.fields &&
      lhs.fragments == rhs.fragments
    }
  }
}

// MARK: - Merge In Other Entity Trees

extension IR.EntitySelectionTree {

  /// Merges an `EntitySelectionTree` from a matching `Entity` in the given `FragmentSpread`
  /// into the receiver.
  ///
  /// - Precondition: This function assumes that the `EntitySelectionTree` being merged in
  /// represents the same entity in the response. Passing a non-matching entity is a serious
  /// programming error and will result in undefined behavior.
  func mergeIn(
    _ otherTree: IR.EntitySelectionTree,
    from fragment: IR.FragmentSpread,
    using entityStorage: IR.RootFieldEntityStorage
  ) {
    let otherTreeCount = otherTree.rootTypePath.count
    let diffToRoot = rootTypePath.count - otherTreeCount

    precondition(diffToRoot >= 0, "Cannot merge in tree shallower than current tree.")

    var rootEntityToStartMerge: EnclosingEntityNode = rootNode

    for _ in 0..<diffToRoot {
      rootEntityToStartMerge = rootEntityToStartMerge.childAsEnclosingEntityNode()
    }

    rootEntityToStartMerge.mergeIn(
      otherTree,
      from: fragment,
      with: fragment.inclusionConditions,
      withNodeRootType: rootEntityToStartMerge.type,
      using: entityStorage
    )    
  }

}

extension IR.EntitySelectionTree.EnclosingEntityNode {

  private func findOrCreate(
    fromFragmentScopeNode fragmentNode: LinkedList<IR.ScopeCondition>.Node,
    from rootNode: IR.EntitySelectionTree.EnclosingEntityNode
  ) -> IR.EntitySelectionTree.EnclosingEntityNode {
    guard let nextFragmentNode = fragmentNode.next else {
      return rootNode
    }
    let nextNode = rootNode.scopeConditionNode(for: nextFragmentNode.value)
    return findOrCreate(fromFragmentScopeNode: nextFragmentNode, from: nextNode)
  }

  fileprivate func mergeIn(
    _ fragmentTree: IR.EntitySelectionTree,
    from fragment: IR.FragmentSpread,
    with inclusionConditions: AnyOf<IR.InclusionConditions>?,
    withNodeRootType nodeRootType: GraphQLCompositeType, // TODO: Remove this param?
    using entityStorage: IR.RootFieldEntityStorage
  ) {
    let rootNodeToStartMerge = findOrCreate(
      fromFragmentScopeNode: fragment.typeInfo.scopePath.last.value.scopePath.head,
      from: self
    )

    let fragmentType = fragment.typeInfo.parentType
    let rootTypesMatch = rootNodeToStartMerge.type == fragmentType

    if let inclusionConditions {
      for conditionGroup in inclusionConditions.elements {
        let scope = IR.ScopeCondition(
          type: rootTypesMatch ? nil : fragmentType,
          conditions: conditionGroup
        )
        let nextNode = rootNodeToStartMerge.scopeConditionNode(for: scope)

        nextNode.mergeIn(
          fragmentTree.rootNode,
          from: fragment,
          using: entityStorage
        )
      }

    } else {
      let nextNode = rootTypesMatch ?
      rootNodeToStartMerge :
      rootNodeToStartMerge.scopeConditionNode(for: IR.ScopeCondition(type: fragmentType))

      nextNode.mergeIn(
        fragmentTree.rootNode,
        from: fragment,
        using: entityStorage
      )
    }

//    default:
//      self.mergeIn(
//        fragmentTree,
//        from: fragment,
//        withNodeRootType: nodeRootType,
//        using: entityStorage
//      )
//    }
  }
//
//  fileprivate func mergeIn(
//    _ otherTree: IR.EntitySelectionTree,
//    from fragment: IR.FragmentSpread,
//    withNodeRootType nodeRootType: GraphQLCompositeType,
//    using entityStorage: IR.RootFieldEntityStorage
//  ) {
//    let rootNode = otherTree.rootNode
//    self.mergeIn(
//      rootNode: rootNode,
//      from: fragment,
//      withNodeRootType: nodeRootType,
//      using: entityStorage
//    )
//  }

//  fileprivate func mergeIn(
//    rootNode: IR.EntitySelectionTree.EnclosingEntityNode,
//    from fragment: IR.FragmentSpread,
//    withNodeRootType nodeRootType: GraphQLCompositeType,
//    using entityStorage: IR.RootFieldEntityStorage
//  ) {
//    let fragmentType = fragment.typeInfo.parentType
//    let rootTypesMatch = nodeRootType == fragmentType
//    let nextEntityNode = rootTypesMatch ?
//    self : self.scopeConditionNode(for: IR.ScopeCondition(type: fragmentType))
//
//    switch rootNode.child {
//    case let .enclosingEntity(otherNextNode):
//      let nextNode = nextEntityNode.childAsEnclosingEntityNode()
//
//      nextNode.mergeIn(
//        otherNextNode,
//        from: fragment,
//        using: entityStorage
//      )
//
//    case let .selections(treeSelections):
//      let fieldNode = nextEntityNode.childAsFieldScopeNode(scope: IR.ScopeCondition(type: nodeRootType))
//
//      fieldNode.mergeIn(
//        fragmentRootFieldNode: otherNextNode,
//        from: fragment,
//        withScopePath: fragment.typeInfo.scopePath.last.value.scopePath.head,
//        using: entityStorage
//      )
//
//    case .none:
//      break
//    }
//
//    if let otherConditions = rootNode.scopeConditions {
//      for (otherCondition, otherNode) in otherConditions {
//        let conditionNode = nextEntityNode.scopeConditionNode(for: otherCondition)
//        conditionNode.mergeIn(otherNode, from: fragment, using: entityStorage)
//      }
//    }
//  }

  fileprivate func mergeIn(
    _ otherNode: IR.EntitySelectionTree.EnclosingEntityNode,
    from fragment: IR.FragmentSpread,
    using entityStorage: IR.RootFieldEntityStorage
  ) {
    switch otherNode.child {
    case let .enclosingEntity(otherNextNode):
      let nextNode = self.childAsEnclosingEntityNode()
      nextNode.mergeIn(
        otherNextNode,
        from: fragment,
        using: entityStorage
      )

    case let .selections(otherNodeSelections):
//      let nextNode = self.childAsFieldScopeNode(scope: otherNode.scope)

      self.mergeIn(
        otherNodeSelections,
        from: fragment,
        using: entityStorage
      )

    case .none:
      break
    }

    if let otherConditions = otherNode.scopeConditions {
      for (otherCondition, otherNode) in otherConditions {
        let conditionNode = self.scopeConditionNode(for: otherCondition)
        conditionNode.mergeIn(
          otherNode,
          from: fragment,
          using: entityStorage
        )
      }
    }
  }

  fileprivate func mergeIn(
    _ selections: Selections,
    from fragment: IR.FragmentSpread,
    using entityStorage: IR.RootFieldEntityStorage
  ) {
    for (source, selections) in selections {
      let newSource = source.fragment != nil ?
      source :
      IR.MergedSelections.MergedSource(
        typeInfo: source.typeInfo, fragment: fragment.fragment
      )

      let fields = selections.fields.mapValues { oldField -> IR.Field in
        if let oldField = oldField as? IR.EntityField {
          let entity = entityStorage.entity(
            for: oldField.entity,
            inFragmentSpreadAtTypePath: fragment.typeInfo
          )

          return IR.EntityField(
            oldField.underlyingField,
            inclusionConditions: oldField.inclusionConditions,
            selectionSet: IR.SelectionSet(
              entity: entity,
              scopePath: oldField.selectionSet.scopePath,
              mergedSelectionsOnly: true)
          )

        } else {
          return oldField
        }
      }

      let fragments = selections.fragments.mapValues { oldFragment -> IR.FragmentSpread in
        let entity = entityStorage.entity(
          for: oldFragment.typeInfo.entity,
          inFragmentSpreadAtTypePath: fragment.typeInfo
        )
        return IR.FragmentSpread(
          fragment: oldFragment.fragment,
          typeInfo: IR.SelectionSet.TypeInfo(
            entity: entity,
            scopePath: oldFragment.typeInfo.scopePath
          ),
          inclusionConditions: oldFragment.inclusionConditions
        )
      }

      self.mergeIn(
        IR.EntityTreeScopeSelections(fields: fields, fragments: fragments),
        from: newSource
      )
    }

//    if let otherConditions = otherNode.scopeConditions {
//      for (otherCondition, otherNode) in otherConditions {
//        let conditionNode = self.scopeConditionNode(for: otherCondition)
//        conditionNode.mergeIn(otherNode, from: fragment, using: entityStorage)
//      }
//    }
  }

}

//extension IR.EntitySelectionTree.FieldScopeNode {
//
//  fileprivate func mergeIn(
//    fragmentRootFieldNode otherNode: IR.EntitySelectionTree.FieldScopeNode,
//    from fragment: IR.FragmentSpread,
//    withScopePath fragmentScopePath: LinkedList<IR.ScopeCondition>.Node,
//    using entityStorage: IR.RootFieldEntityStorage
//  ) {
//    guard let nextFragmentScope = fragmentScopePath.next else {
//      // Merge fragment entity tree in at current scope.
//      mergeIn(
//        otherNode,
//        from: fragment,
//        using: entityStorage
//      )
//      return
//    }
//
//    let nextFieldNode = self.scopeConditionNode(for: nextFragmentScope.value)
//    nextFieldNode.mergeIn(
//      fragmentRootFieldNode: otherNode,
//      from: fragment,
//      withScopePath: nextFragmentScope,
//      using: entityStorage
//    )
//  }
//
//  fileprivate func mergeIn(
//    _ otherNode: IR.EntitySelectionTree.FieldScopeNode,
//    from fragment: IR.FragmentSpread,
//    using entityStorage: IR.RootFieldEntityStorage
//  ) {
//    for (source, selections) in otherNode.selections {
//      let newSource = source.fragment != nil ?
//      source :
//      IR.MergedSelections.MergedSource(
//        typeInfo: source.typeInfo, fragment: fragment.fragment
//      )
//
//      let fields = selections.fields.mapValues { oldField -> IR.Field in
//        if let oldField = oldField as? IR.EntityField {
//          let entity = entityStorage.entity(
//            for: oldField.entity,
//            inFragmentSpreadAtTypePath: fragment.typeInfo
//          )
//
//          return IR.EntityField(
//            oldField.underlyingField,
//            inclusionConditions: oldField.inclusionConditions,
//            selectionSet: IR.SelectionSet(
//              entity: entity,
//              scopePath: oldField.selectionSet.scopePath,
//              mergedSelectionsOnly: true)
//          )
//
//        } else {
//          return oldField
//        }
//      }
//
//      let fragments = selections.fragments.mapValues { oldFragment -> IR.FragmentSpread in
//        let entity = entityStorage.entity(
//          for: oldFragment.typeInfo.entity,
//          inFragmentSpreadAtTypePath: fragment.typeInfo
//        )
//        return IR.FragmentSpread(
//          fragment: oldFragment.fragment,
//          typeInfo: IR.SelectionSet.TypeInfo(
//            entity: entity,
//            scopePath: oldFragment.typeInfo.scopePath
//          ),
//          inclusionConditions: oldFragment.inclusionConditions
//        )
//      }
//      self.selections[newSource] = IR.EntityTreeScopeSelections(fields: fields, fragments: fragments)
//    }
//
//    if let otherConditions = otherNode.scopeConditions {
//      for (otherCondition, otherNode) in otherConditions {
//        let conditionNode = self.scopeConditionNode(for: otherCondition)
//        conditionNode.mergeIn(otherNode, from: fragment, using: entityStorage)
//      }
//    }
//  }
//
//}

// MARK: - CustomDebugStringConvertible

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
    TemplateString("""
    \(scope.debugDescription) {
      \(child?.debugDescription ?? "nil")
      conditionalScopes: [\(list: scopeConditions?.values.elements ?? [])]
    }
    """).description
  }
}

extension IR.EntitySelectionTree.EnclosingEntityNode.Child: CustomDebugStringConvertible {
  var debugDescription: String {
    func debugDescription(for selections: IR.EntitySelectionTree.EnclosingEntityNode.Selections) -> String {
      TemplateString("""
      [
      \(selections.map {
        TemplateString("""
          Source: \($0.key.debugDescription)
            \($0.value.debugDescription)
        """)
      })
      ]
      """).description
    }

    switch self {
    case let .enclosingEntity(node):
      return "child: \(node.debugDescription)"

    case let .selections(selections):
      return TemplateString("selections: \(debugDescription(for: selections))").description
    }
  }

}

extension IR.EntityTreeScopeSelections: CustomDebugStringConvertible {
  var debugDescription: String {
    """
    Fields: \(fields.values.elements)
    Fragments: \(fragments.values.elements.description)
    """
  }
}
