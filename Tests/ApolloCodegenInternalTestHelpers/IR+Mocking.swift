@testable import ApolloCodegenLib
import ApolloUtils

extension IR {

  public static func mock(
    schema: String,
    document: String,
    enableCCN: Bool = false
  ) throws -> IR {
    let frontend = try GraphQLJSFrontend()
    let compilationResult = try frontend.compile(
      schema: schema,
      document: document,
      enableCCN: enableCCN
    )
    return .mock(compilationResult: compilationResult)
  }

  public static func mock(
    schema: String,
    documents: [String],
    enableCCN: Bool = false
  ) throws -> IR {
    let frontend = try GraphQLJSFrontend()
    let compilationResult = try frontend.compile(
      schema: schema,
      documents: documents,
      enableCCN: enableCCN
    )
    return .mock(compilationResult: compilationResult)
  }

  public static func mock(
    schemaJSON: String,
    document: String,
    enableCCN: Bool = false
  ) throws -> IR {
    let frontend = try GraphQLJSFrontend()
    let compilationResult = try frontend.compile(
      schemaJSON: schemaJSON,
      document: document,
      enableCCN: enableCCN
    )
    return .mock(compilationResult: compilationResult)
  }

  public static func mock(
    schemaName: String = "TestSchema",
    compilationResult: CompilationResult
  ) -> IR {
    return IR(schemaName: schemaName, compilationResult: compilationResult)
  }

}

extension IR.NamedFragment {

  public static func mock(
    _ name: String,
    type: GraphQLCompositeType = .mock("MockType")
  ) -> IR.NamedFragment {
    let rootField = CompilationResult.Field.mock(name, type: .entity(type))
    let rootEntity = IR.Entity(
      rootTypePath: LinkedList(type),
      fieldPath: [.init(name: name, type: .entity(type))]
    )
    let rootEntityField = IR.EntityField.init(
      rootField,
      inclusionConditions: nil,
      selectionSet: .init(
        entity: rootEntity,
        scopePath: LinkedList(
          .descriptor(
            forType: type,
            inclusionConditions: nil,
            givenAllTypesInSchema: .init([type])
          ))))

    return IR.NamedFragment(
      definition: CompilationResult.FragmentDefinition.mock(name, type: type),
      rootField: rootEntityField,
      referencedFragments: [],
      entities: [rootEntity.fieldPath: rootEntity]
    )
  }
}

extension IR.Operation {

  public static func mock() -> IR.Operation {
    IR.Operation.init(
      definition: .mock(),
      rootField: .init(.mock(),
                       inclusionConditions: nil,
                       selectionSet: .init(
                        entity: .init(
                          rootTypePath: [.mock()],
                          fieldPath: [.init(name: "mock", type: .entity(.mock("name")))]),
                        scopePath: [.descriptor(
                          forType: .mock(),
                          inclusionConditions: nil,
                          givenAllTypesInSchema: .init([]))
                        ])
                      ),
      referencedFragments: [])
  }
}
