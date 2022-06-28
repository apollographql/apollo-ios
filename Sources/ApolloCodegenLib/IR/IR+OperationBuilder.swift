import Foundation
import OrderedCollections
import ApolloUtils

extension IR {

  func build(operation operationDefinition: CompilationResult.OperationDefinition) -> Operation {
    let rootField = CompilationResult.Field(
      name: operationDefinition.operationType.rawValue,
      type: .nonNull(.entity(operationDefinition.rootType)),
      selectionSet: operationDefinition.selectionSet
    )

    let rootEntity = Entity(
      rootTypePath: LinkedList(operationDefinition.rootType),
      fieldPath: [.init(name: rootField.name, type: rootField.type)]
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
