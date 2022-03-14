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
        givenAllTypesInSchema: schema.referencedTypes
      )

      let rootIrSelectionSet = SelectionSet(
        entity: rootEntity,
        parentType: rootEntity.rootType,
        typePath: LinkedList(rootTypePath)
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
      buildDirectSelections(
        forSelectionSet: selectionSet,
        inFragmentSpread: fragmentSpread,
        from: selections
      )

      selectionSet.typeInfo.entity.selectionTree.mergeIn(
        selectionSet: selectionSet,
        inFragmentSpread: fragmentSpread
      )
    }

    private func buildDirectSelections(
      forSelectionSet selectionSet: SelectionSet,
      inFragmentSpread containingFragmentSpread: FragmentSpread?,
      from selections: [CompilationResult.Selection]
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

        case let .inlineFragment(typeCaseSelectionSet):
          guard let scope = scopeCondition(for: typeCaseSelectionSet, in: selectionSet) else {
            continue
          }

          if selectionSet.typeInfo.typeScope.matches(scope) {
            buildSortedSelections(
              forSelectionSet: selectionSet,
              inFragmentSpread: containingFragmentSpread,
              from: typeCaseSelectionSet.selections
            )

          } else {
            let irTypeCase = buildTypeCaseSelectionSet(
              fromSelectionSet: typeCaseSelectionSet,
              inFragmentSpread: containingFragmentSpread,
              onParent: selectionSet
            )
            selectionSet.selections.direct!.mergeIn(irTypeCase)
          }

        case let .fragmentSpread(fragmentSpread):
          guard let scope = scopeCondition(for: fragmentSpread, in: selectionSet) else {
            continue
          }

          if selectionSet.typeInfo.typeScope.matches(scope) {
            referencedFragments.append(fragmentSpread.fragment)
            let irFragmentSpread = buildFragmentSpread(
              fromFragment: fragmentSpread,
              spreadIntoParent: selectionSet
            )

            selectionSet.selections.direct!.mergeIn(irFragmentSpread)

          } else {
            let irTypeCaseEnclosingFragment = buildTypeCaseSelectionSet(
              fromSelectionSet: CompilationResult.SelectionSet(
                parentType: fragmentSpread.parentType,
                selections: [selection]
              ),
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

      if field.type.namedType is GraphQLCompositeType {
        let irSelectionSet = buildSelectionSet(
          forField: field,
          on: selectionSet,
          inFragmentSpread: fragmentSpread
        )

        return EntityField(
          field,
          inclusionConditions: inclusionResult.conditions,
          selectionSet: irSelectionSet
        )

      } else {
        return ScalarField(field, inclusionConditions: inclusionResult.conditions)
      }
    }

    private func buildSelectionSet(
      forField field: CompilationResult.Field,
      on enclosingSelectionSet: SelectionSet,
      inFragmentSpread fragmentSpread: FragmentSpread?
    ) -> SelectionSet {
      guard let fieldSelectionSet = field.selectionSet else {
        fatalError("SelectionSet cannot be created for non-entity type field \(field).")
      }

      let entity = entity(for: field, on: enclosingSelectionSet.typeInfo.entity)

      let typeScope = ScopeDescriptor.descriptor(
        forType: fieldSelectionSet.parentType,
        givenAllTypesInSchema: schema.referencedTypes
      )
      let typePath = enclosingSelectionSet.typeInfo.typePath.appending(typeScope)

      let irSelectionSet = SelectionSet(
        entity: entity,
        parentType: fieldSelectionSet.parentType,
        typePath: typePath
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

    private func buildTypeCaseSelectionSet(
      fromSelectionSet selectionSet: CompilationResult.SelectionSet,
      inFragmentSpread fragmentSpread: FragmentSpread?,
      onParent parentSelectionSet: SelectionSet
    ) -> SelectionSet {
      let typePath = parentSelectionSet.typeInfo.typePath.mutatingLast {
        $0.appending(selectionSet.parentType)
      }

      let irSelectionSet = SelectionSet(
        entity: parentSelectionSet.typeInfo.entity,
        parentType: selectionSet.parentType,
        typePath: typePath
      )
      buildSortedSelections(
        forSelectionSet: irSelectionSet,
        inFragmentSpread: fragmentSpread,
        from: selectionSet.selections
      )
      return irSelectionSet
    }

    private func buildFragmentSpread(
      fromFragment fragmentSpread: CompilationResult.FragmentSpread,
      spreadIntoParent parentSelectionSet: SelectionSet
    ) -> FragmentSpread {
      let fragment = fragmentSpread.fragment

      let irSelectionSet = SelectionSet(
        entity: parentSelectionSet.typeInfo.entity,
        parentType: fragment.selectionSet.parentType,
        typePath: parentSelectionSet.typeInfo.typePath
      )

      let fragmentSpread = FragmentSpread(
        fragmentSpread: fragmentSpread,
        selectionSet: irSelectionSet
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

extension CompilationResult.SelectionSet: ConditionallyIncludable {}
extension CompilationResult.FragmentSpread: ConditionallyIncludable {}
