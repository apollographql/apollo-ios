import Foundation
import CodegenCLI
import ApolloCodegenLib

class MockApolloSchemaDownloader: SchemaDownloadProvider {
  static var fetchHandler: ((ApolloSchemaDownloadConfiguration) throws -> Void)? = nil

  static func fetch(
    configuration: ApolloSchemaDownloadConfiguration,
    withRootURL rootURL: URL?
  ) throws {
    guard let handler = fetchHandler else {
      fatalError("You must set fetchHandler before calling \(#function)!")
    }

    defer {
      fetchHandler = nil
    }

    try handler(configuration)
  }
}
