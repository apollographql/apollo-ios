import Foundation
import OrderedCollections

extension IR {

  class RootFieldEntityStorage {
    private(set) var entitiesForFields: [Entity.Location: IR.Entity] = [:]

    init(rootEntity: Entity) {
      entitiesForFields[rootEntity.location] = rootEntity
    }

    func entity(
      for field: CompilationResult.Field,
      on enclosingEntity: Entity
    ) -> Entity {
      let location = enclosingEntity
        .location
        .appending(.init(name: field.responseKey, type: field.type))

      var rootTypePath: LinkedList<GraphQLCompositeType> {
        guard let fieldType = field.selectionSet?.parentType else {
          fatalError("Entity cannot be created for non-entity type field \(field).")
        }
        return enclosingEntity.rootTypePath.appending(fieldType)
      }

      return entitiesForFields[location] ??
      createEntity(location: location, rootTypePath: rootTypePath)
    }

    func entity(
      for entityInFragment: IR.Entity,
      inFragmentSpreadAtTypePath fragmentSpreadTypeInfo: SelectionSet.TypeInfo
    ) -> Entity {
      var location = fragmentSpreadTypeInfo.entity.location
      if let pathInFragment = entityInFragment.location.fieldPath {
        location = location.appending(pathInFragment)
      }

      var rootTypePath: LinkedList<GraphQLCompositeType> {
        let otherRootTypePath = entityInFragment.rootTypePath.dropFirst()
        return fragmentSpreadTypeInfo.entity.rootTypePath.appending(otherRootTypePath)
      }

      return entitiesForFields[location] ??
      createEntity(location: location, rootTypePath: rootTypePath)
    }

    private func createEntity(
      location: Entity.Location,
      rootTypePath: LinkedList<GraphQLCompositeType>
    ) -> Entity {
      let entity = Entity(location: location, rootTypePath: rootTypePath)
      entitiesForFields[location] = entity
      return entity
    }

    fileprivate func mergeAllSelectionsIntoEntitySelectionTrees(from fragmentSpread: FragmentSpread) {
      for (_, fragmentEntity) in fragmentSpread.fragment.entities {
        let entity = entity(for: fragmentEntity, inFragmentSpreadAtTypePath: fragmentSpread.typeInfo)
        entity.selectionTree.mergeIn(fragmentEntity.selectionTree, from: fragmentSpread, using: self)
      }
    }
  }

  class RootFieldBuilder {
    struct Result {
      let rootField: IR.EntityField
      let referencedFragments: ReferencedFragments
      let entities: [Entity.Location: IR.Entity]
    }

    typealias ReferencedFragments = OrderedSet<NamedFragment>

    static func buildRootEntityField(
      forRootField rootField: CompilationResult.Field,
      onRootEntity rootEntity: Entity,
      inIR ir: IR
    ) -> Result {
      return RootFieldBuilder(ir: ir, rootEntity: rootEntity)
        .build(rootField: rootField)
    }

    private let ir: IR
    private let rootEntity: Entity
    private let entityStorage: RootFieldEntityStorage
    private var referencedFragments: ReferencedFragments = []

    private var schema: Schema { ir.schema }

    private init(ir: IR, rootEntity: Entity) {
      self.ir = ir
      self.rootEntity = rootEntity
      self.entityStorage = RootFieldEntityStorage(rootEntity: rootEntity)
    }

    private func build(
      rootField: CompilationResult.Field
    ) -> Result {
      guard let rootSelectionSet = rootField.selectionSet else {
        fatalError("Root field must have a selection set.")
      }

      let rootTypePath = ScopeDescriptor.descriptor(
        forType: rootEntity.rootType,
        inclusionConditions: nil,
        givenAllTypesInSchema: schema.referencedTypes
      )

      let rootIrSelectionSet = SelectionSet(
        entity: rootEntity,
        scopePath: LinkedList(rootTypePath)
      )

      buildDirectSelections(
        into: rootIrSelectionSet.selections.direct.unsafelyUnwrapped,
        atTypePath: rootIrSelectionSet.typeInfo,
        from: rootSelectionSet
      )

      return Result(
        rootField: EntityField(rootField, selectionSet: rootIrSelectionSet),
        referencedFragments: referencedFragments,
        entities: entityStorage.entitiesForFields
      )
    }

    private func buildDirectSelections(
      into target: DirectSelections,
      atTypePath typeInfo: SelectionSet.TypeInfo,
      from selectionSet: CompilationResult.SelectionSet
    ) {
      addSelections(from: selectionSet, to: target, atTypePath: typeInfo)

      typeInfo.entity.selectionTree.mergeIn(
        selections: target.readOnlyView,
        with: typeInfo
      )
    }

    private func addSelections(
      from selectionSet: CompilationResult.SelectionSet,
      to target: DirectSelections,
      atTypePath typeInfo: SelectionSet.TypeInfo
    ) {
      for selection in selectionSet.selections {
        add(selection, to: target, atTypePath: typeInfo)
      }

      ir.fieldCollector.collectFields(from: selectionSet)
    }

    private func add(
      _ selection: CompilationResult.Selection,
      to target: DirectSelections,
      atTypePath typeInfo: SelectionSet.TypeInfo
    ) {
      switch selection {
      case let .field(field):
        if let irField = buildField(
          from: field,
          atTypePath: typeInfo
        ) {
          target.mergeIn(irField)
        }

      case let .inlineFragment(inlineFragment):
        let inlineSelectionSet = inlineFragment.selectionSet
        guard let scope = scopeCondition(for: inlineFragment, in: typeInfo) else {
          return
        }

        if typeInfo.scope.matches(scope) {
          addSelections(
            from: inlineSelectionSet,
            to: target,
            atTypePath: typeInfo
          )

        } else {
          let irTypeCase = buildConditionalSelectionSet(
            from: inlineSelectionSet,
            with: scope,
            inParentTypePath: typeInfo
          )
          target.mergeIn(irTypeCase)
        }

      case let .fragmentSpread(fragmentSpread):
        guard let scope = scopeCondition(for: fragmentSpread, in: typeInfo) else {
          return
        }
        let selectionSetScope = typeInfo.scope

        var matchesType: Bool {
          guard let typeCondition = scope.type else { return true }
          return selectionSetScope.matches(typeCondition)
        }
        let matchesScope = selectionSetScope.matches(scope)

        if matchesScope {
          let irFragmentSpread = buildFragmentSpread(
            fromFragment: fragmentSpread,
            with: scope,
            spreadIntoParentWithTypePath: typeInfo
          )
          target.mergeIn(irFragmentSpread)

        } else {
          let irTypeCaseEnclosingFragment = buildConditionalSelectionSet(
            from: CompilationResult.SelectionSet(
              parentType: fragmentSpread.parentType,
              selections: [selection]
            ),
            with: scope,
            inParentTypePath: typeInfo
          )

          target.mergeIn(irTypeCaseEnclosingFragment)

          if matchesType {
            typeInfo.entity.selectionTree.mergeIn(
              selections: irTypeCaseEnclosingFragment.selections.direct.unsafelyUnwrapped.readOnlyView,
              with: typeInfo
            )
          }
        }
      }
    }

    private func scopeCondition(
      for conditionalSelectionSet: ConditionallyIncludable,
      in parentTypePath: SelectionSet.TypeInfo
    ) -> ScopeCondition? {
      let inclusionResult = inclusionResult(for: conditionalSelectionSet.inclusionConditions)
      guard inclusionResult != .skipped else {
        return nil
      }

      let type = parentTypePath.parentType == conditionalSelectionSet.parentType ?
      nil : conditionalSelectionSet.parentType

      return ScopeCondition(type: type, conditions: inclusionResult.conditions)
    }

    private func inclusionResult(
      for conditions: [CompilationResult.InclusionCondition]?
    ) -> InclusionConditions.Result {
      guard let conditions = conditions else {
        return .included
      }

      return InclusionConditions.allOf(conditions)
    }

    private func buildField(
      from field: CompilationResult.Field,
      atTypePath enclosingTypeInfo: SelectionSet.TypeInfo
    ) -> Field? {
      let inclusionResult = inclusionResult(for: field.inclusionConditions)
      guard inclusionResult != .skipped else {
        return nil
      }

      let inclusionConditions = inclusionResult.conditions

      if field.type.namedType is GraphQLCompositeType {
        let irSelectionSet = buildSelectionSet(
          forField: field,
          with: inclusionConditions,
          atTypePath: enclosingTypeInfo
        )

        return EntityField(
          field,
          inclusionConditions: AnyOf(inclusionConditions),
          selectionSet: irSelectionSet
        )

      } else {
        return ScalarField(field, inclusionConditions: AnyOf(inclusionConditions))
      }
    }

    private func buildSelectionSet(
      forField field: CompilationResult.Field,
      with inclusionConditions: InclusionConditions?,
      atTypePath enclosingTypeInfo: SelectionSet.TypeInfo
    ) -> SelectionSet {
      guard let fieldSelectionSet = field.selectionSet else {
        preconditionFailure("SelectionSet cannot be created for non-entity type field \(field).")
      }

      let entity = entityStorage.entity(for: field, on: enclosingTypeInfo.entity)

      let typeScope = ScopeDescriptor.descriptor(
        forType: fieldSelectionSet.parentType,
        inclusionConditions: inclusionConditions,
        givenAllTypesInSchema: schema.referencedTypes
      )
      let typePath = enclosingTypeInfo.scopePath.appending(typeScope)

      let irSelectionSet = SelectionSet(
        entity: entity,
        scopePath: typePath
      )
      buildDirectSelections(
        into: irSelectionSet.selections.direct.unsafelyUnwrapped,
        atTypePath: irSelectionSet.typeInfo,
        from: fieldSelectionSet
      )
      return irSelectionSet
    }

    private func buildConditionalSelectionSet(
      from selectionSet: CompilationResult.SelectionSet?,
      with scopeCondition: ScopeCondition,
      inParentTypePath enclosingTypeInfo: SelectionSet.TypeInfo
    ) -> SelectionSet {
      let typePath = enclosingTypeInfo.scopePath.mutatingLast {
        $0.appending(scopeCondition)
      }

      let irSelectionSet = SelectionSet(
        entity: enclosingTypeInfo.entity,
        scopePath: typePath
      )

      if let selectionSet = selectionSet {
        buildDirectSelections(
          into: irSelectionSet.selections.direct.unsafelyUnwrapped,
          atTypePath: irSelectionSet.typeInfo,
          from: selectionSet
        )
      }
      return irSelectionSet
    }

    private func buildFragmentSpread(
      fromFragment fragmentSpread: CompilationResult.FragmentSpread,
      with scopeCondition: ScopeCondition,
      spreadIntoParentWithTypePath parentTypeInfo: SelectionSet.TypeInfo
    ) -> FragmentSpread {
      let fragment = ir.build(fragment: fragmentSpread.fragment)
      referencedFragments.append(fragment)
      referencedFragments.append(contentsOf: fragment.referencedFragments)

      let scopePath = scopeCondition.isEmpty ?
      parentTypeInfo.scopePath :
      parentTypeInfo.scopePath.mutatingLast {
        $0.appending(scopeCondition)
      }

      let typeInfo = SelectionSet.TypeInfo(
        entity: parentTypeInfo.entity,
        scopePath: scopePath
      )

      let fragmentSpread = FragmentSpread(
        fragment: fragment,
        typeInfo: typeInfo,
        inclusionConditions: AnyOf(scopeCondition.conditions)
      )

      entityStorage.mergeAllSelectionsIntoEntitySelectionTrees(from: fragmentSpread)
      
      return fragmentSpread
    }
    
  }
}

// MARK: - Helpers

fileprivate protocol ConditionallyIncludable {
  var parentType: GraphQLCompositeType { get }
  var inclusionConditions: [CompilationResult.InclusionCondition]? { get }
}

extension CompilationResult.InlineFragment: ConditionallyIncludable {
  var parentType: GraphQLCompositeType { selectionSet.parentType }
}
extension CompilationResult.FragmentSpread: ConditionallyIncludable {}
