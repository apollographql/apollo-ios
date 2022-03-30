@testable import ApolloCodegenLib
import ApolloUtils

extension IR {

  public static func mock(schema: String, document: String) throws -> IR {
    let frontend = try GraphQLJSFrontend()
    let compilationResult = try frontend.compile(schema: schema, document: document)
    return .mock(compilationResult: compilationResult)
  }

  public static func mock(schema: String, documents: [String]) throws -> IR {
    let frontend = try GraphQLJSFrontend()
    let compilationResult = try frontend.compile(schema: schema, documents: documents)
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
    return IR.NamedFragment(
      definition: .mock(name, type: type),
      rootField: IR.EntityField.init(
        .mock(),
        inclusionConditions: nil,
        selectionSet: .init(
          entity: .init(
            rootTypePath: LinkedList(type),
            fieldPath: ResponsePath(name)),
          scopePath: LinkedList(.descriptor(forType: type, inclusionConditions: nil, givenAllTypesInSchema: .init([type])))
        )),
      referencedFragments: []
    )
  }
}
