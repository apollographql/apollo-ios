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

      let rootTypePath = TypeScopeDescriptor.descriptor(
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
        from: rootSelectionSet
      )

      return (
        EntityField(rootField, selectionSet: rootIrSelectionSet),
        referencedFragments
      )
    }

    private func buildSortedSelections(
      forSelectionSet selectionSet: SelectionSet,
      from selections: [CompilationResult.Selection]
    ) {
      for selection in selections {
        switch selection {
        case let .field(field):
          let irField = buildField(from: field, on: selectionSet)
          selectionSet.selections.direct!.mergeIn(irField)

        case let .inlineFragment(typeCaseSelectionSet):
          if selectionSet.typeInfo.typeScope.matches(typeCaseSelectionSet.parentType) {
            buildSortedSelections(
              forSelectionSet: selectionSet,
              from: typeCaseSelectionSet.selections
            )

          } else {
            let irTypeCase = buildTypeCaseSelectionSet(
              fromSelectionSet: typeCaseSelectionSet,
              onParent: selectionSet
            )
            selectionSet.selections.direct!.mergeIn(irTypeCase)
          }

        case let .fragmentSpread(fragment):
          if selectionSet.typeInfo.typeScope.matches(fragment.type) {
#warning("TODO: Might be missing referenced fragments for type case nested fragments?")
            referencedFragments.append(fragment)
            let irFragmentSpread = buildFragmentSpread(
              fromFragment: fragment,
              onParent: selectionSet
            )

            selectionSet.selections.direct!.mergeIn(irFragmentSpread)

          } else {
            let irTypeCaseEnclosingFragment = buildTypeCaseSelectionSet(
              fromSelectionSet: CompilationResult.SelectionSet(
                parentType: fragment.type,
                selections: [selection]
              ),
              onParent: selectionSet
            )

            selectionSet.selections.direct!.mergeIn(irTypeCaseEnclosingFragment)
          }
        }
      }

      selectionSet.typeInfo.entity.mergedSelectionTree.mergeIn(selectionSet: selectionSet)
    }

    private func buildField(
      from field: CompilationResult.Field,
      on selectionSet: SelectionSet
    ) -> Field {
      if field.type.namedType is GraphQLCompositeType {
        let irSelectionSet = buildSelectionSet(forField: field, on: selectionSet)
        return EntityField(field, selectionSet: irSelectionSet)

      } else {
        return ScalarField(field)
      }
    }

    private func buildSelectionSet(
      forField field: CompilationResult.Field,
      on enclosingSelectionSet: SelectionSet
    ) -> SelectionSet {
      guard let fieldSelectionSet = field.selectionSet else {
        fatalError("SelectionSet cannot be created for non-entity type field \(field).")
      }

      let entity = entity(for: field, on: enclosingSelectionSet.typeInfo.entity)

      let typeScope = TypeScopeDescriptor.descriptor(
        forType: fieldSelectionSet.parentType,
        givenAllTypesInSchema: schema.referencedTypes
      )
      let typePath = enclosingSelectionSet.typeInfo.typePath.appending(typeScope)

      let irSelectionSet = SelectionSet(
        entity: entity,
        parentType: fieldSelectionSet.parentType,
        typePath: typePath
      )
      buildSortedSelections(forSelectionSet: irSelectionSet, from: fieldSelectionSet.selections)
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
      buildSortedSelections(forSelectionSet: irSelectionSet, from: selectionSet.selections)
      return irSelectionSet
    }

    private func buildFragmentSpread(
      fromFragment fragment: CompilationResult.FragmentDefinition,
      onParent parentSelectionSet: SelectionSet
    ) -> FragmentSpread {
      #warning("TODO! Why are we wrapping in a type case here??")
      let irSelectionSet = buildTypeCaseSelectionSet(
        fromSelectionSet: fragment.selectionSet,
        onParent: parentSelectionSet
      )

      return FragmentSpread(
        definition: fragment,
        selectionSet: irSelectionSet
      )
    }
  }
}
