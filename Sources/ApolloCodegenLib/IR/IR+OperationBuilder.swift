import Foundation
import OrderedCollections

extension IR {

  func build(operation operationDefinition: CompilationResult.OperationDefinition) -> Operation {
    let rootField = CompilationResult.Field(
      name: operationDefinition.operationType.rawValue,
      type: .nonNull(.entity(operationDefinition.rootType)),
      selectionSet: operationDefinition.selectionSet
    )

    let rootEntity = Entity(
      source: .operation(operationDefinition),
      rootTypePath: LinkedList(operationDefinition.rootType)
    )

    let result = RootFieldBuilder.buildRootEntityField(
      forRootField: rootField,
      onRootEntity: rootEntity,
      inIR: self
    )

    return IR.Operation(
      definition: operationDefinition,
      rootField: result.rootField,
      referencedFragments: result.referencedFragments
    )
  }

}
