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
      source: .operation(operationDefinition)      
    )

    let result = RootFieldBuilder.buildRootEntityField(
      forRootField: rootField,
      onRootEntity: rootEntity,
      inIR: self
    )

    let ir = IR.Operation(
      definition: operationDefinition,
      rootField: result.rootField,
      referencedFragments: result.referencedFragments
    )
    // TODO: Should this throw if inputOperationIdentifiers is set, but there is no operationIdentifier for the operation?
    if let inputOperationIdentifiers = inputOperationIdentifiers?[operationDefinition.operationType] {
      if let operationIdentifier = inputOperationIdentifiers[operationDefinition.name] {
        ir.operationIdentifier = operationIdentifier
      }
    }
    return ir
  }

}
