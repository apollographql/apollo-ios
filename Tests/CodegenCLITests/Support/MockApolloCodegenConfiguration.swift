import Foundation
import ApolloCodegenLib

extension ApolloCodegenConfiguration {
  static func mock() -> Self {
    return self.init(
      schemaNamespace: "MockSchema",
      input: .init(
        schemaPath: "./schema.graphqls"
      ),
      output: .init(
        schemaTypes: .init(path: ".", moduleType: .swiftPackageManager)
      ),
      options: .init(
        operationDocumentFormat: [.definition, .operationId]
      ),
      schemaDownload: .init(
        using: .introspection(endpointURL: URL(string: "http://some.server")!),
        outputPath: "./schema.graphqls"
      ),
      operationManifest: .init(
        path: "./manifest",
        version: .persistedQueries,
        generateManifestOnCodeGeneration: false
      )
    )
  }
}
