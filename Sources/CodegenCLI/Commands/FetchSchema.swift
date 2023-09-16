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

    try fetchSchema(
      configuration: inputs.getCodegenConfiguration(fileManager: fileManager),
      schemaDownloadProvider: schemaDownloadProvider
    )    
  }

  private func fetchSchema(
    configuration codegenConfiguration: ApolloCodegenConfiguration,
    schemaDownloadProvider: SchemaDownloadProvider.Type
  ) throws {
    guard let schemaDownload = codegenConfiguration.schemaDownload else {
      throw Error(errorDescription: """
        Missing schema download configuration. Hint: check the `schemaDownload` \
        property of your configuration.
        """
      )
    }

    try schemaDownloadProvider.fetch(
      configuration: schemaDownload,
      withRootURL: rootOutputURL(for: inputs),
      session: nil
    )
  }
}
