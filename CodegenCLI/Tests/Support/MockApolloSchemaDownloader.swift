import Foundation
import apollo_ios_cli
import ApolloCodegenLib

class MockApolloSchemaDownloader: SchemaDownloadProvider {
  static var fetchHandler: ((ApolloSchemaDownloadConfiguration) throws -> Void)? = nil

  static func fetch(configuration: ApolloSchemaDownloadConfiguration) throws {
    guard let handler = fetchHandler else {
      fatalError("You must set fetchHandler before calling \(#function)!")
    }

    defer {
      fetchHandler = nil
    }

    try handler(configuration)
  }
}
