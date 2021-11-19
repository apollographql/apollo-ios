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
      let rootFieldName = operationDefinition.operationType.rawValue
      let rootFieldPath = ResponsePath(rootFieldName)
      let rootEntity = Entity(
        rootType: operationDefinition.rootType,
        responsePath: rootFieldPath
      )
      entitiesForFields[rootFieldPath] = rootEntity

      let rootField = CompilationResult.Field(
        name: rootFieldName,
        type: .nonNull(.entity(operationDefinition.rootType)),
        selectionSet: operationDefinition.selectionSet
      )
      let irRootField = EntityField(
        rootField,
        selectionSet: buildRootSelectionSet(for: rootField, on: rootEntity, enclosedInScope: nil)
      )

      return IR.Operation(definition: operationDefinition, rootField: irRootField)
    }

    private func entity(
      for field: CompilationResult.Field,
      on enclosingEntity: Entity
    ) -> Entity {
      let fieldPath = enclosingEntity.responsePath.appending(field.responseKey)

      if let entity = entitiesForFields[fieldPath] {
        return entity
      }

      guard let fieldType = field.type.namedType as? GraphQLCompositeType else {
        fatalError("Entity cannot be created for non-entity type field \(field).")
      }

      let entity = Entity(
        rootType: fieldType,
        responsePath: fieldPath
      )

      entitiesForFields[fieldPath] = entity

      return entity
    }

    private func buildRootSelectionSet(
      for field: CompilationResult.Field,
      on enclosingSelectionSet: SelectionSet
    ) -> SelectionSet {
      guard let fieldSelectionSet = field.selectionSet else {
        fatalError("SelectionSet cannot be created for non-entity type field \(field).")
      }

      let typeScope = TypeScopeDescriptor.descriptor(
        for: fieldSelectionSet.parentType,
        givenAllTypes: compilationResult.referencedTypes
      )

      let entity = entity(for: field, on: enclosingSelectionSet.entity)

      let enclosingEntityScope = enclosingSelectionSet
        .enclosingEntityScope?
        .appending(enclosingSelectionSet.typeScope.scope) ??
      LinkedList(enclosingSelectionSet.typeScope.scope)

      let irSelectionSet = SelectionSet(
        entity: entity,
        parentType: fieldSelectionSet.parentType,
        typeScope: typeScope,
        enclosingEntityScope: enclosingEntityScope
      )
      computeSortedSelections(for: irSelectionSet, from: fieldSelectionSet.selections)
      return irSelectionSet
    }

    private func computeSortedSelections(
      for selectionSet: SelectionSet,
      from selections: [CompilationResult.Selection]
    ) {
      for selection in selections {
        switch selection {
        case let .field(field) where field.type.namedType is GraphQLCompositeType:
          let irSelectionSet = buildRootSelectionSet(for: field, on: selectionSet)
          let irField = EntityField(field, selectionSet: irSelectionSet)
          selectionSet.selections.mergeIn(irField)

        case let .field(field):
          let irField = ScalarField(field)
          selectionSet.selections.mergeIn(irField)

        case let .inlineFragment(typeCaseSelectionSet):
          if selectionSet.scopeDescriptor.matches(typeCaseSelectionSet.parentType) {
            computedSelections.mergeIn(typeCaseSelectionSet.selections)

          } else {
            computedSelections.mergeIn(typeCase: typeCaseSelectionSet)
            appendOrMergeIntoChildren(typeCaseSelectionSet)
          }

        case let .fragmentSpread(fragment):
          func shouldMergeFragmentDirectly() -> Bool {
#warning("TODO: Might be able to change this to use TypeScopeDescriptor.matches()?")
            if fragment.type == selectionSet.type { return true }

            if let implementingType = selectionSet.type as? GraphQLInterfaceImplementingType,
               let fragmentInterface = fragment.type as? GraphQLInterfaceType,
               implementingType.implements(fragmentInterface) {
              return true
            }

            return false
          }

          if shouldMergeFragmentDirectly() {
            computedSelections.mergeIn(fragment)

          } else {
            let typeCaseForFragment = CompilationResult.SelectionSet(
              parentType: fragment.type,
              selections: [selection]
            )

            computedSelections.mergeIn(typeCase: typeCaseForFragment)
            appendOrMergeIntoChildren(typeCaseForFragment)
          }
        }
      }

      self.add(computedSelections, forScope: selectionSet.scopeDescriptor.scope)

      let children = computedChildSelectionSets.mapValues {
        SelectionSet(selectionSet: $0, parent: selectionSet)
      }
      return (computedSelections, children)
    }

  }
}
