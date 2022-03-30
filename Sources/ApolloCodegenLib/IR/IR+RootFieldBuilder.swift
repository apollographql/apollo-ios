import Foundation
import OrderedCollections
import ApolloUtils

extension IR {
  class RootFieldBuilder {
    typealias ReferencedFragments = OrderedSet<NamedFragment>

    static func buildRootEntityField(
      forRootField rootField: CompilationResult.Field,
      onRootEntity rootEntity: Entity,
      inIR ir: IR
    ) -> (IR.EntityField, referencedFragments: ReferencedFragments) {
      return RootFieldBuilder(ir: ir)
        .build(rootField: rootField, rootEntity: rootEntity)
    }

    private let ir: IR
    private var entitiesForFields: OrderedDictionary<ResponsePath, IR.Entity> = [:]
    private var referencedFragments: ReferencedFragments = []

    private var schema: Schema { ir.schema }

    private init(ir: IR) {
      self.ir = ir
    }

    private func build(
      rootField: CompilationResult.Field,
      rootEntity: Entity
    ) -> (IR.EntityField, referencedFragments: ReferencedFragments) {
      guard let rootSelectionSet = rootField.selectionSet?.selections else {
        fatalError("Root field must have a selection set.")
      }

      entitiesForFields[rootEntity.fieldPath] = rootEntity

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
        inFragmentSpread: nil,
        from: rootSelectionSet
      )

      return (
        EntityField(rootField, selectionSet: rootIrSelectionSet),
        referencedFragments
      )
    }

    private func buildDirectSelections(
      into target: DirectSelections,
      atTypePath typeInfo: SelectionSet.TypeInfo,
      inFragmentSpread fragmentSpread: FragmentSpread?,
      from selections: [CompilationResult.Selection]
    ) {
      add(
        selections,
        to: target,
        atTypePath: typeInfo,
        inFragmentSpread: fragmentSpread
      )

      typeInfo.entity.selectionTree.mergeIn(
        selections: target,
        with: typeInfo,
        inFragmentSpread: fragmentSpread
      )
    }

    private func add(
      _ selections: [CompilationResult.Selection],
      to target: DirectSelections,
      atTypePath typeInfo: SelectionSet.TypeInfo,
      inFragmentSpread enclosingFragmentSpread: FragmentSpread?
    ) {
      for selection in selections {
        switch selection {
        case let .field(field):
          if let irField = buildField(
            from: field,
            atTypePath: typeInfo,
            inFragmentSpread: enclosingFragmentSpread
          ) {
            target.mergeIn(irField)
          }

        case let .inlineFragment(inlineFragment):
          let inlineSelectionSet = inlineFragment.selectionSet
          guard let scope = scopeCondition(for: inlineFragment, in: typeInfo) else {
            continue
          }

          if typeInfo.scope.matches(scope) {
            add(
              inlineSelectionSet.selections,
              to: target,
              atTypePath: typeInfo,
              inFragmentSpread: enclosingFragmentSpread
            )

          } else {
            let irTypeCase = buildConditionalSelectionSet(
              from: inlineSelectionSet,
              with: scope,
              inParentTypePath: typeInfo,
              inFragmentSpread: enclosingFragmentSpread
            )
            target.mergeIn(irTypeCase)
          }

        case let .fragmentSpread(fragmentSpread):
          if let existingFragmentSpread =
              target.fragments[fragmentSpread.hashForSelectionSetScope] {
            merge(fragmentSpread, into: existingFragmentSpread)

          } else {

            guard let scope = scopeCondition(for: fragmentSpread, in: typeInfo) else {
              continue
            }
            let selectionSetScope = typeInfo.scope

            var matchesType: Bool {
              guard let typeCondition = scope.type else { return true }
              return selectionSetScope.matches(typeCondition)
            }

            if matchesType {
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
                inParentTypePath: typeInfo,
                inFragmentSpread: enclosingFragmentSpread
              )

              target.mergeIn(irTypeCaseEnclosingFragment)
            }
          }
        }
      }
    }

    private func merge(
      _ fragmentSpread: CompilationResult.FragmentSpread,
      into existingFragmentSpread: IR.FragmentSpread
    ) {
//      guard let scope = scopeCondition(for: fragmentSpread, in: typeInfo) else {
//        continue
//      }
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
      atTypePath enclosingTypeInfo: SelectionSet.TypeInfo,
      inFragmentSpread fragmentSpread: FragmentSpread?
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
          atTypePath: enclosingTypeInfo,
          inFragmentSpread: fragmentSpread
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
      atTypePath enclosingTypeInfo: SelectionSet.TypeInfo,
      inFragmentSpread enclosingFragmentSpread: FragmentSpread?
    ) -> SelectionSet {
      guard let fieldSelectionSet = field.selectionSet else {
        fatalError("SelectionSet cannot be created for non-entity type field \(field).")
      }

      let entity = entity(for: field, on: enclosingTypeInfo.entity)

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
        inFragmentSpread: enclosingFragmentSpread,
        from: fieldSelectionSet.selections
      )
      return irSelectionSet
    }

    private func buildConditionalSelectionSet(
      from selectionSet: CompilationResult.SelectionSet?,
      with scopeCondition: ScopeCondition,
      inParentTypePath enclosingTypeInfo: SelectionSet.TypeInfo,
      inFragmentSpread enclosingFragmentSpread: FragmentSpread?
    ) -> SelectionSet {
      let typePath = enclosingTypeInfo.scopePath.mutatingLast {
        $0.appending(scopeCondition)
      }

      let irSelectionSet = SelectionSet(
        entity: enclosingTypeInfo.entity,
        scopePath: typePath
      )

      if let selections = selectionSet?.selections {
        buildDirectSelections(
          into: irSelectionSet.selections.direct.unsafelyUnwrapped,
          atTypePath: irSelectionSet.typeInfo,
          inFragmentSpread: enclosingFragmentSpread,
          from: selections
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

      mergeAllSelectionsIntoEntitySelectionTrees(from: fragmentSpread)
      
      return fragmentSpread
    }

    private func mergeAllSelectionsIntoEntitySelectionTrees(from fragmentSpread: FragmentSpread) {
      #warning("TODO: get entities from fragment spread")
      let entitiesInFragment: [ResponsePath: IR.Entity] = [:]

      for (_, fragmentEntity) in entitiesInFragment {
        let entity = entity(for: fragmentEntity, inFragmentSpreadAtTypePath: fragmentSpread.typeInfo)
        entity.selectionTree.mergeIn(fragmentEntity.selectionTree, in: fragmentSpread)
      }
    }

    // MARK: - Entity Creation Helpers

    private func entity(
      for field: CompilationResult.Field,
      on enclosingEntity: Entity
    ) -> Entity {
      let fieldPath = enclosingEntity
        .fieldPath
        .appending(field.responseKey)

      var rootTypePath: LinkedList<GraphQLCompositeType> {
        guard let fieldType = field.selectionSet?.parentType else {
          fatalError("Entity cannot be created for non-entity type field \(field).")
        }
        return enclosingEntity.rootTypePath.appending(fieldType)
      }

      return entitiesForFields[fieldPath] ??
      createEntity(fieldPath: fieldPath, rootTypePath: rootTypePath)
    }

    private func createEntity(
      fieldPath: ResponsePath,
      rootTypePath: LinkedList<GraphQLCompositeType>
    ) -> Entity {
      let entity = Entity(rootTypePath: rootTypePath, fieldPath: fieldPath)
      entitiesForFields[fieldPath] = entity
      return entity
    }

    private func entity(
      for otherEntity: IR.Entity,
      inFragmentSpreadAtTypePath fragmentSpreadTypeInfo: SelectionSet.TypeInfo
    ) -> Entity {
      let fieldPath = fragmentSpreadTypeInfo.entity.fieldPath +
      otherEntity.fieldPath.toArray().dropFirst()

      var rootTypePath: LinkedList<GraphQLCompositeType> {
        let otherRootTypePath = otherEntity.rootTypePath.dropFirst()
        return fragmentSpreadTypeInfo.entity.rootTypePath.appending(otherRootTypePath)
      }

      return entitiesForFields[fieldPath] ??
      createEntity(fieldPath: fieldPath, rootTypePath: rootTypePath)
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
