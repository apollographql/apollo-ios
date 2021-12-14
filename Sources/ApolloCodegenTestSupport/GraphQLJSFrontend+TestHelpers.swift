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

  public func compile(schema: String, documents: [String]) throws -> CompilationResult {
    let schemaSource = try makeSource(schema, filePath: "")
    let schema = try loadSchemaFromSDL(schemaSource)

    let documents: [GraphQLDocument] = try documents.enumerated().map {
      let source = try makeSource($0.element, filePath: "Doc_\($0.offset)")
      return try parseDocument(source)
    }

    let mergedDocument = try mergeDocuments(documents)
    return try compile(schema: schema, document: mergedDocument)
  }

}
