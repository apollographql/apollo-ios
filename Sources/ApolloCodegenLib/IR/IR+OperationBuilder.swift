import Foundation
import OrderedCollections
import ApolloUtils

extension IR {

  func build(operation: CompilationResult.OperationDefinition) -> Operation {
    OperationBuilder.build(operation: operation, inSchema: schema)
  }

  fileprivate final class OperationBuilder {

    static func build(
      operation: CompilationResult.OperationDefinition,
      inSchema schema: Schema
    ) -> IR.Operation {
      return OperationBuilder(schema: schema, operationDefinition: operation).build()
    }

    let schema: Schema
    let operationDefinition: CompilationResult.OperationDefinition

    private init(
      schema: Schema,
      operationDefinition: CompilationResult.OperationDefinition
    ) {
      self.schema = schema
      self.operationDefinition = operationDefinition
    }

    private func build() -> Operation {
      let rootEntity = buildRootEntity()

      let rootField = CompilationResult.Field(
        name: operationDefinition.operationType.rawValue,
        type: .nonNull(.entity(operationDefinition.rootType)),
        selectionSet: operationDefinition.selectionSet
      )

      let (irRootField, referencedFragments) = RootFieldBuilder.buildRootEntityField(
        forRootField: rootField,
        onRootEntity: rootEntity,
        inSchema: schema
      )

      return IR.Operation(
        definition: operationDefinition,
        rootField: irRootField,
        referencedFragments: referencedFragments
      )
    }

    private func buildRootEntity() -> Entity {
      let rootFieldName = operationDefinition.operationType.rawValue
      let rootResponsePath = ResponsePath(rootFieldName)

      let rootEntity = Entity(
        rootTypePath: LinkedList(operationDefinition.rootType),
        fieldPath: rootResponsePath
      )

      return rootEntity
    }
  }

}
