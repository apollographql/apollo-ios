import Foundation
import ArgumentParser
import ApolloCodegenLib

struct FetchSchema: ParsableCommand {

  // MARK: - Configuration

  static var configuration = CommandConfiguration(
    commandName: "fetch-schema",
    abstract: "Download a GraphQL schema from the Apollo Registry or GraphQL introspection."
  )

  @Option(
    name: .shortAndLong,
    help: "Read the configuration from a file at the path."
  )
  var path: String = Constants.defaultFilePath

  @Option(
    name: .shortAndLong,
    help: "Configuration string in JSON format."
  )
  var string: String?

  // MARK: - Implementation

  func run() throws {
    try _run()
  }

  func _run(
    fileManager: FileManager = .default,
    schemaDownloadProvider: SchemaDownloadProvider.Type = ApolloSchemaDownloader.self
  ) throws {
    if let string = string {
      try fetchSchema(data: try string.asData(), schemaDownloadProvider: schemaDownloadProvider)
      return
    }

    guard let data = fileManager.contents(atPath: path) else {
      throw Error(errorDescription: "Cannot read configuration file at \(path)")
    }

    try fetchSchema(data: data, schemaDownloadProvider: schemaDownloadProvider)
  }

  private func fetchSchema(
    data: Data,
    schemaDownloadProvider: SchemaDownloadProvider.Type
  ) throws {
    let codegenConfiguration = try JSONDecoder().decode(ApolloCodegenConfiguration.self, from: data)

    guard let schemaDownloadConfiguration = codegenConfiguration.schemaDownloadConfiguration else {
      throw Error(errorDescription: """
        Missing schema download configuration. Hint: check the `schemaDownloadConfiguration` \
        property of your configuration.
        """
      )
    }

    CodegenLogger.level = .warning

    try schemaDownloadProvider.fetch(configuration: schemaDownloadConfiguration)
  }
}
