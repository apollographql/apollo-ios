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
      let rootMST = MergedSelectionTree()
      let rootEntity = Entity(
        rootType: operationDefinition.rootType,
        responsePath: rootFieldPath,
        mergedSelectionTree: rootMST
      )
      entitiesForFields[rootFieldPath] = rootEntity

      let rootField = EntityField(
        name: rootFieldName,
        type: .nonNull(.entity(operationDefinition.rootType)),
        entity: rootEntity,
        selectionSet: operationDefinition.selectionSet
      )

      return IR.Operation(definition: operationDefinition, rootField: rootField)
    }

    //    private func buildEntityField(

    private func buildSelectionSet(from selectionSet: CompilationResult.SelectionSet) -> IR.SelectionSet {

    }

    private func computeSelectionsAndChildren(
      from selections: [CompilationResult.Selection],
      typeScope: TypeScope
      //      for selectionSet: IR.SelectionSet
    ) -> (
      selections: SortedSelections,
      children: SelectionSet.ChildTypeCaseDictionary
    ) {
      var computedChildSelectionSets: OrderedDictionary<String, CompilationResult.SelectionSet> = [:]
      var computedSelections = SortedSelections()

      func appendOrMergeIntoChildren(_ selectionSet: CompilationResult.SelectionSet) {
        let keyInScope = selectionSet.hashForSelectionSetScope
        if let existingValue = computedChildSelectionSets[keyInScope] {
          computedChildSelectionSets[keyInScope] = existingValue.merging(selectionSet)

        } else {
          computedChildSelectionSets[keyInScope] = selectionSet
        }
      }

      for selection in selections {
        switch selection {
        case let .field(field) where field.type.namedType is GraphQLCompositeType:
          //          let builderForField = enclosingEntityMergedSelectionBuilder(for: field)
          //        builderForField.add(??, forScope: ??)
//          let astField = ASTField(field, enclosingEntityMergedSelectionBuilder: builderForField)
//          computedSelections.mergeIn(astField)

        case let .field(field):
          computedSelections.mergeIn(ASTField(field))

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
