import Foundation
import ArgumentParser
import ApolloCodegenLib

public struct Generate: ParsableCommand {

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

  public func run() throws {
    try _run()
  }

  func _run(
    fileManager: FileManager = .default,
    codegenProvider: CodegenProvider.Type = ApolloCodegen.self,
    schemaDownloadProvider: SchemaDownloadProvider.Type = ApolloSchemaDownloader.self,
    logger: LogLevelSetter.Type = CodegenLogger.self
  ) throws {
    logger.SetLoggingLevel(verbose: inputs.verbose)

    try checkForCLIVersionMismatch(
      with: inputs
    )

    try generate(
      configuration: inputs.getCodegenConfiguration(fileManager: fileManager),
      codegenProvider: codegenProvider,
      schemaDownloadProvider: schemaDownloadProvider
    )
  }

  private func generate(
    configuration: ApolloCodegenConfiguration,
    codegenProvider: CodegenProvider.Type,
    schemaDownloadProvider: SchemaDownloadProvider.Type
  ) throws {
    if fetchSchema {
      guard
        let schemaDownloadConfiguration = configuration.schemaDownloadConfiguration
      else {
        throw Error(errorDescription: """
          Missing schema download configuration. Hint: check the `schemaDownloadConfiguration` \
          property of your configuration.
          """
        )
      }

      try fetchSchema(
        configuration: schemaDownloadConfiguration,
        schemaDownloadProvider: schemaDownloadProvider
      )
    }
    let buildOptions: ApolloCodegen.CodeGenerationBuildOptions = (configuration.operationManifestConfiguration?.generateManifestOnCodeGeneration ?? false) ? [.code, .operationManifest] : [.code]

    try codegenProvider.build(
      with: configuration,
      withRootURL: rootOutputURL(for: inputs),
      buildOptions: buildOptions
    )
  }

  private func fetchSchema(
    configuration: ApolloSchemaDownloadConfiguration,
    schemaDownloadProvider: SchemaDownloadProvider.Type
  ) throws {
    try schemaDownloadProvider.fetch(configuration: configuration, withRootURL: rootOutputURL(for: inputs))
  }
}
