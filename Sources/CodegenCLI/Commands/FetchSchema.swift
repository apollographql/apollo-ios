import Foundation
import ArgumentParser
import ApolloCodegenLib

public struct FetchSchema: ParsableCommand {

  // MARK: - Configuration

  public static var configuration = CommandConfiguration(
    commandName: "fetch-schema",
    abstract: "Download a GraphQL schema from the Apollo Registry or GraphQL introspection."
  )

  @OptionGroup var inputs: InputOptions

  // MARK: - Implementation

  public init() { }

  public func run() throws {
    try _run()
  }

  func _run(
    fileManager: FileManager = .default,
    schemaDownloadProvider: SchemaDownloadProvider.Type = ApolloSchemaDownloader.self,
    logger: LogLevelSetter.Type = CodegenLogger.self
  ) throws {
    logger.SetLoggingLevel(verbose: inputs.verbose)

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

    try schemaDownloadProvider.fetch(
      configuration: schemaDownloadConfiguration,
      withRootURL: rootOutputURL(for: inputs)
    )
  }
}
