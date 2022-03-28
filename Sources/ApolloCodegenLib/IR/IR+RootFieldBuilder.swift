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
      
      buildSortedSelections(
        forSelectionSet: rootIrSelectionSet,
        inFragmentSpread: nil,
        from: rootSelectionSet
      )

      return (
        EntityField(rootField, selectionSet: rootIrSelectionSet),
        referencedFragments
      )
    }

    private func buildSortedSelections(
      forSelectionSet selectionSet: SelectionSet,
      inFragmentSpread fragmentSpread: FragmentSpread?,
      from selections: [CompilationResult.Selection]
    ) {
      add(
        directSelections: selections,
        to: selectionSet,
        inFragmentSpread: fragmentSpread
      )

      selectionSet.typeInfo.entity.selectionTree.mergeIn(
        selectionSet: selectionSet,
        inFragmentSpread: fragmentSpread
      )
    }

    private func add(
      directSelections selections: [CompilationResult.Selection],
      to selectionSet: SelectionSet,
      inFragmentSpread containingFragmentSpread: FragmentSpread?
    ) {
      for selection in selections {
        switch selection {
        case let .field(field):
          if let irField = buildField(
            from: field,
            on: selectionSet,
            inFragmentSpread: containingFragmentSpread
          ) {
            selectionSet.selections.direct!.mergeIn(irField)
          }

        case let .inlineFragment(inlineFragment):
          let inlineSelectionSet = inlineFragment.selectionSet
          guard let scope = scopeCondition(for: inlineFragment, in: selectionSet) else {
            continue
          }

          if selectionSet.typeInfo.scope.matches(scope) {
            add(
              directSelections: inlineSelectionSet.selections,
              to: selectionSet,
              inFragmentSpread: containingFragmentSpread
            )

          } else {
            let irTypeCase = buildConditionalSelectionSet(
              from: inlineSelectionSet,
              with: scope,
              inFragmentSpread: containingFragmentSpread,
              onParent: selectionSet
            )
            selectionSet.selections.direct!.mergeIn(irTypeCase)
          }

        case let .fragmentSpread(fragmentSpread):
          guard let scope = scopeCondition(for: fragmentSpread, in: selectionSet) else {
            continue
          }
          let selectionSetScope = selectionSet.typeInfo.scope

          var matchesType: Bool {
            guard let typeCondition = scope.type else { return true }
            return selectionSetScope.matches(typeCondition)
          }

          if matchesType {
            let irFragmentSpread = buildFragmentSpread(
              fromFragment: fragmentSpread,
              with: scope,
              spreadIntoParent: selectionSet
            )
            selectionSet.selections.direct!.mergeIn(irFragmentSpread)

          } else {
            let irTypeCaseEnclosingFragment = buildConditionalSelectionSet(
              from: CompilationResult.SelectionSet(
                parentType: fragmentSpread.parentType,
                selections: [selection]
              ),
              with: scope,
              inFragmentSpread: containingFragmentSpread,
              onParent: selectionSet
            )

            selectionSet.selections.direct!.mergeIn(irTypeCaseEnclosingFragment)
          }
        }
      }
    }

    private func scopeCondition(
      for conditionalSelectionSet: ConditionallyIncludable,
      in parent: IR.SelectionSet
    ) -> ScopeCondition? {
      let inclusionResult = inclusionResult(for: conditionalSelectionSet.inclusionConditions)
      guard inclusionResult != .skipped else {
        return nil
      }

      let type = parent.parentType == conditionalSelectionSet.parentType ?
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
      on selectionSet: SelectionSet,
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
          on: selectionSet,
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
      on enclosingSelectionSet: SelectionSet,
      inFragmentSpread fragmentSpread: FragmentSpread?
    ) -> SelectionSet {
      guard let fieldSelectionSet = field.selectionSet else {
        fatalError("SelectionSet cannot be created for non-entity type field \(field).")
      }

      let entity = entity(for: field, on: enclosingSelectionSet.typeInfo.entity)

      let typeScope = ScopeDescriptor.descriptor(
        forType: fieldSelectionSet.parentType,
        inclusionConditions: inclusionConditions,
        givenAllTypesInSchema: schema.referencedTypes
      )
      let typePath = enclosingSelectionSet.typeInfo.scopePath.appending(typeScope)

      let irSelectionSet = SelectionSet(
        entity: entity,
        scopePath: typePath
      )
      buildSortedSelections(
        forSelectionSet: irSelectionSet,
        inFragmentSpread: fragmentSpread,
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
      inFragmentSpread fragmentSpread: FragmentSpread?,
      onParent parentSelectionSet: SelectionSet
    ) -> SelectionSet {
      let typePath = parentSelectionSet.typeInfo.scopePath.mutatingLast {
        $0.appending(scopeCondition)
      }

      let irSelectionSet = SelectionSet(
        entity: parentSelectionSet.typeInfo.entity,
        scopePath: typePath
      )

      if let selections = selectionSet?.selections {
        buildSortedSelections(
          forSelectionSet: irSelectionSet,
          inFragmentSpread: fragmentSpread,
          from: selections
        )
      }
      return irSelectionSet
    }

    private func buildFragmentSpread(
      fromFragment fragmentSpread: CompilationResult.FragmentSpread,
      with scopeCondition: ScopeCondition,
      spreadIntoParent parentSelectionSet: SelectionSet
    ) -> FragmentSpread {
      let fragment = fragmentSpread.fragment
      referencedFragments.append(fragment)

      let scopePath = scopeCondition.isEmpty ?
      parentSelectionSet.typeInfo.scopePath :
      parentSelectionSet.typeInfo.scopePath.mutatingLast {
        $0.appending(scopeCondition)
      }

      let irSelectionSet = SelectionSet(
        entity: parentSelectionSet.typeInfo.entity,        
        scopePath: scopePath
      )

      let fragmentSpread = FragmentSpread(
        fragmentSpread: fragmentSpread,
        selectionSet: irSelectionSet,
        inclusionConditions: AnyOf(scopeCondition.conditions)
      )
      buildSortedSelections(
        forSelectionSet: fragmentSpread.selectionSet,
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
