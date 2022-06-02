import Foundation
import ArgumentParser
import ApolloCodegenLib

struct FetchSchema: ParsableCommand {

  // MARK: - Configuration

  static var configuration = CommandConfiguration(
    commandName: "fetch-schema",
    abstract: "Download a GraphQL schema from the Apollo Registry or GraphQL introspection."
  )

  @OptionGroup var inputs: InputOptions

  // MARK: - Implementation

  func run() throws {
    try _run()
  }

  func _run(
    fileManager: FileManager = .default,
    schemaDownloadProvider: SchemaDownloadProvider.Type = ApolloSchemaDownloader.self
  ) throws {
    switch (inputs.string, inputs.path) {
    case let (.some(string), _):
      try fetchSchema(data: try string.asData(), schemaDownloadProvider: schemaDownloadProvider)

    case let (nil, path):
      let data = try fileManager.unwrappedContents(atPath: path)
      try fetchSchema(data: data, schemaDownloadProvider: schemaDownloadProvider)
    }
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
