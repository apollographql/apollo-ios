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
    if let operationNamesToIdentifiers {
      // TODO: Should this throw if there is no operationIdentifier for the operation?
      // TODO: Is operationDefinition.name enough of an index across operation types?
      if let operationIdentifier = operationNamesToIdentifiers[operationDefinition.name] {
        ir.operationIdentifier = operationIdentifier
      }
    }
    return ir
  }

}
