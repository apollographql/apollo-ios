import Foundation
import ApolloCodegenLib

extension GraphQLJSFrontend {

  public func compile(schema: String, document: String) throws -> CompilationResult {
    let schemaSource = try makeSource(schema, filePath: "")
    let documentSource = try makeSource(document, filePath: "")

    let schema = try loadSchemaFromSDL(schemaSource)
    let document = try parseDocument(documentSource)

    return try compile(schema: schema, document: document)
  }

}
