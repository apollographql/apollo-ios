import Foundation
import ArgumentParser
import ApolloCodegenLib

public struct Generate: AsyncParsableCommand {

  // MARK: - Configuration
  
  public static var configuration = CommandConfiguration(
    abstract: "Generate Swift source code based on a code generation configuration."
  )

  @OptionGroup var inputs: InputOptions

  @Flag(
    name: .shortAndLong,
    help: "Fetch the GraphQL schema before Swift code generation."
  )
  var fetchSchema: Bool = false

  // MARK: - Implementation

  public init() { }

  public func run() async throws {
    try await _run()
  }

  func _run(
    fileManager: FileManager = .default,
    codegenProvider: CodegenProvider.Type = ApolloCodegen.self,
    schemaDownloadProvider: SchemaDownloadProvider.Type = ApolloSchemaDownloader.self,
    logger: LogLevelSetter.Type = CodegenLogger.self
  ) async throws {
    logger.SetLoggingLevel(verbose: inputs.verbose)

    try checkForCLIVersionMismatch(
      with: inputs
    )

    try await generate(
      configuration: inputs.getCodegenConfiguration(fileManager: fileManager),
      codegenProvider: codegenProvider,
      schemaDownloadProvider: schemaDownloadProvider
    )
  }

  private func generate(
    configuration: ApolloCodegenConfiguration,
    codegenProvider: CodegenProvider.Type,
    schemaDownloadProvider: SchemaDownloadProvider.Type
  ) async throws {
    if fetchSchema {
      guard
        let schemaDownload = configuration.schemaDownload
      else {
        throw Error(errorDescription: """
          Missing schema download configuration. Hint: check the `schemaDownload` \
          property of your configuration.
          """
        )
      }

      try fetchSchema(
        configuration: schemaDownload,
        schemaDownloadProvider: schemaDownloadProvider
      )
    }
    
    var itemsToGenerate: ApolloCodegen.ItemsToGenerate = .code
        
    if let operationManifest = configuration.operationManifest,
        operationManifest.generateManifestOnCodeGeneration {
      itemsToGenerate.insert(.operationManifest)
    }

    try await codegenProvider.build(
      with: configuration,
      withRootURL: rootOutputURL(for: inputs),
      itemsToGenerate: itemsToGenerate
    )
  }

  private func fetchSchema(
    configuration: ApolloSchemaDownloadConfiguration,
    schemaDownloadProvider: SchemaDownloadProvider.Type
  ) throws {
    try schemaDownloadProvider.fetch(configuration: configuration, withRootURL: rootOutputURL(for: inputs))
  }
}
