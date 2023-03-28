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
      schemaDownloadConfiguration: .init(
        using: .introspection(endpointURL: URL(string: "http://some.server")!),
        outputPath: "./schema.graphqls"
      )
    )
  }
}
