import Foundation
import OrderedCollections
import ApolloUtils

extension IR {
  class RootFieldBuilder {
    typealias ReferencedFragments = OrderedSet<CompilationResult.FragmentDefinition>

    static func buildRootEntityField(
      forRootField rootField: CompilationResult.Field,
      onRootEntity rootEntity: Entity,
      inSchema schema: Schema
    ) -> (IR.EntityField, referencedFragments: ReferencedFragments) {
      return RootFieldBuilder(schema: schema)
        .build(rootField: rootField, rootEntity: rootEntity, schema: schema)
    }

    private let schema: Schema
    private var entitiesForFields: OrderedDictionary<ResponsePath, IR.Entity> = [:]
    private var referencedFragments: ReferencedFragments = []

    private init(schema: Schema) {
      self.schema = schema
    }

    private func build(
      rootField: CompilationResult.Field,
      rootEntity: Entity,
      schema: Schema
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

    private func merge(
      _ fragment: NamedFragment,
      intoEntitySelectionTreesAtTypePath typeInfo: SelectionSet.TypeInfo
    ) {
//      let directRootSelections = fragment.rootField.selectionSet.selections.direct.unsafelyUnwrapped
//      typeInfo.entity.selectionTree.mergeIn(
//        selections: directRootSelections,
//        with: typeInfo,
//        inFragmentSpread: nil // TODO
//      )
      for selection in fragment.rootField.selectionSet.selections.direct.unsafelyUnwrapped {
        switch selection {

        }
      }
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
      guard let scope = scopeCondition(for: fragmentSpread, in: typeInfo) else {
        continue
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

    private func entity(
      for field: CompilationResult.Field,
      on enclosingEntity: Entity
    ) -> Entity {
      let responsePath = enclosingEntity
        .fieldPath
        .appending(field.responseKey)

      if let entity = entitiesForFields[responsePath] {
        return entity
      }

      guard let fieldType = field.selectionSet?.parentType else {
        fatalError("Entity cannot be created for non-entity type field \(field).")
      }

      let rootTypePath = enclosingEntity.rootTypePath.appending(fieldType)
      let entity = Entity(rootTypePath: rootTypePath, fieldPath: responsePath)

      entitiesForFields[responsePath] = entity

      return entity
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
      let fragment = fragmentSpread.fragment
      referencedFragments.append(fragment)

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
        fragmentSpread: fragmentSpread,
        typeInfo: typeInfo,
        inclusionConditions: AnyOf(scopeCondition.conditions)
      )
      buildDirectSelections(
        into: fragmentSpread.selections,
        atTypePath: typeInfo,
        inFragmentSpread: fragmentSpread,
        from: fragment.selectionSet.selections
      )

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
