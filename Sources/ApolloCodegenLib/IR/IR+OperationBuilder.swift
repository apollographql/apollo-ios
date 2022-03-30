import Foundation
import OrderedCollections
import ApolloUtils

extension IR {

  func build(operation operationDefinition: CompilationResult.OperationDefinition) -> Operation {
    let rootEntity = buildRootEntity(for: operationDefinition)

    let rootField = CompilationResult.Field(
      name: operationDefinition.operationType.rawValue,
      type: .nonNull(.entity(operationDefinition.rootType)),
      selectionSet: operationDefinition.selectionSet
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

  private func buildRootEntity(for operationDefinition: CompilationResult.OperationDefinition) -> Entity {
    let rootFieldName = operationDefinition.operationType.rawValue
    let rootResponsePath = ResponsePath(rootFieldName)

    let rootEntity = Entity(
      rootTypePath: LinkedList(operationDefinition.rootType),
      fieldPath: rootResponsePath
    )

    return rootEntity
  }

}
