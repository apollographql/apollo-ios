import Foundation
import ApolloCodegenLib

extension ApolloCodegenConfiguration {
  static func mock() -> Self {
    return self.init(
      schemaName: "MockSchema",
      input: .init(schemaPath: "./schema.graphqls"),
      output: .init(schemaTypes: .init(path: ".", moduleType: .swiftPackageManager))
    )
  }
}
