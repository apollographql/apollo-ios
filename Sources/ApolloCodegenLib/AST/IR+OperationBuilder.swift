import Foundation
import OrderedCollections
import ApolloUtils

extension IR {

  func build(operation: CompilationResult.OperationDefinition) -> Operation {
    OperationBuilder(compilationResult: compilationResult,
                     operationDefinition: operation).builtOperation
  }

  fileprivate final class OperationBuilder {
    let compilationResult: CompilationResult
    let operationDefinition: CompilationResult.OperationDefinition

    var entitiesForFields: OrderedDictionary<ResponsePath, IR.Entity> = [:]
    lazy var builtOperation: IR.Operation = { build() }()

    init(
      compilationResult: CompilationResult,
      operationDefinition: CompilationResult.OperationDefinition
    ) {
      self.compilationResult = compilationResult
      self.operationDefinition = operationDefinition
    }

    private func build() -> Operation {
      let rootEntity = buildRootEntity()

      let rootField = CompilationResult.Field(
        name: operationDefinition.operationType.rawValue,
        type: .nonNull(.entity(operationDefinition.rootType)),
        selectionSet: operationDefinition.selectionSet
      )

      let rootTypePath = TypeScopeDescriptor.descriptor(
        forType: rootEntity.rootType,
        fieldPath: rootEntity.responsePath,
        givenAllTypes: compilationResult.referencedTypes
      )

      let rootSelectionSet = SelectionSet(
        entity: rootEntity,
        parentType: operationDefinition.rootType,
        typePath: LinkedList(rootTypePath)
      )
      
      buildSortedSelections(
        forSelectionSet: rootSelectionSet,
        from: operationDefinition.selectionSet.selections
      )

      let irRootField = EntityField(rootField, selectionSet: rootSelectionSet)

      return IR.Operation(definition: operationDefinition, rootField: irRootField)
    }

    private func buildRootEntity() -> Entity {
      let rootFieldName = operationDefinition.operationType.rawValue
      let rootResponsePath = ResponsePath(rootFieldName)

      let rootEntity = Entity(
        rootTypePath: LinkedList(operationDefinition.rootType),
        responsePath: rootResponsePath
      )

      entitiesForFields[rootResponsePath] = rootEntity
      return rootEntity
    }

    private func buildSortedSelections(
      forSelectionSet selectionSet: SelectionSet,
      from selections: [CompilationResult.Selection]
    ) {
      for selection in selections {
        switch selection {
        case let .field(field):
          let irField = buildField(from: field, on: selectionSet)
          selectionSet.selections.mergeIn(irField)

        case let .inlineFragment(typeCaseSelectionSet):
          if selectionSet.typeScope.matches(typeCaseSelectionSet.parentType) {
            buildSortedSelections(
              forSelectionSet: selectionSet,
              from: typeCaseSelectionSet.selections
            )

          } else {
            let irTypeCase = buildTypeCaseSelectionSet(
              fromSelectionSet: typeCaseSelectionSet,
              onParent: selectionSet
            )
            selectionSet.selections.mergeIn(irTypeCase)
          }

        case let .fragmentSpread(fragment):
          if selectionSet.typeScope.matches(fragment.type) {
            let irFragmentSpread = buildFragmentSpread(
              fromFragment: fragment,
              onParent: selectionSet
            )

            selectionSet.selections.mergeIn(irFragmentSpread)

          } else {
            let irTypeCaseEnclosingFragment = buildTypeCaseSelectionSet(
              fromSelectionSet: CompilationResult.SelectionSet(
                parentType: fragment.type,
                selections: [selection]
              ),
              onParent: selectionSet
            )

            selectionSet.selections.mergeIn(irTypeCaseEnclosingFragment)
          }
        }
      }

      selectionSet.entity.mergedSelectionTree.mergeIn(selectionSet: selectionSet)
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

      let entity = entity(for: field, on: enclosingSelectionSet.entity)

      let typeScope = TypeScopeDescriptor.descriptor(
        forType: fieldSelectionSet.parentType,
        fieldPath: enclosingSelectionSet.entity.responsePath.appending(field.responseKey),
        givenAllTypes: compilationResult.referencedTypes
      )
      let typePath = enclosingSelectionSet.typePath.appending(typeScope)

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
        .responsePath
        .appending(field.responseKey)

      if let entity = entitiesForFields[responsePath] {
        return entity
      }

      guard let fieldType = field.selectionSet?.parentType else {
        fatalError("Entity cannot be created for non-entity type field \(field).")
      }

      let rootTypePath = enclosingEntity.rootTypePath.appending(fieldType)
      let entity = Entity(rootTypePath: rootTypePath, responsePath: responsePath)

      entitiesForFields[responsePath] = entity

      return entity
    }

    private func buildTypeCaseSelectionSet(
      fromSelectionSet selectionSet: CompilationResult.SelectionSet,
      onParent parentSelectionSet: SelectionSet
    ) -> SelectionSet {
      let typePath = parentSelectionSet.typePath.mutatingLast {
        $0.appending(selectionSet.parentType)
      }

      let irSelectionSet = SelectionSet(
        entity: parentSelectionSet.entity,
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
