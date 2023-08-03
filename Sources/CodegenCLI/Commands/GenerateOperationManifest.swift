import Foundation
import ArgumentParser
import ApolloCodegenLib

public struct GenerateOperationManifest: ParsableCommand {
  
  // MARK: - Configuration
  
  public static var configuration = CommandConfiguration(
    abstract: "Generate Persisted Queries operation manifest based on a code generation configuration."
  )

  struct OutputOptions: ParsableArguments {
    @Option(
      name: .shortAndLong,
      help: """
      Output the operation manifest to the given path. This overrides the value of the \
      `output.operationManifest.path` in your configuration.
      
      **If the `output.operationManifest` is not included in your configuration, this is required.**
      """
    )
    var outputPath: String?
    
    @Option(
      name: .long,
      help: """
      The version for the operation manifest format to generate. This overrides the value of the \
      `output.operationManifest.path` in your configuration.
      
      **If the `output.operationManifest` is not included in your configuration, this is required.**
      """
    )
    var manifestVersion: ApolloCodegenConfiguration.OperationManifestFileOutput.Version?
  }

  @OptionGroup var inputs: InputOptions
  @OptionGroup var outputOptions: OutputOptions

  // MARK: - Implementation
  
  public init() { }
  
  public func run() throws {
    try _run()
  }
  
  func _run(
    fileManager: FileManager = .default,
    codegenProvider: CodegenProvider.Type = ApolloCodegen.self,
    logger: LogLevelSetter.Type = CodegenLogger.self
  ) throws {
    logger.SetLoggingLevel(verbose: inputs.verbose)

    var configuration = try inputs.getCodegenConfiguration(fileManager: fileManager)

    try validate(configuration: configuration)

    if let outputPath = outputOptions.outputPath,
       let manifestVersion = outputOptions.manifestVersion {
      configuration.output.operationManifest = .init(
        path: outputPath,
        version: manifestVersion
      )
    }

    try generateManifest(
      configuration: configuration,
      codegenProvider: codegenProvider
    )
  }
  
  private func generateManifest(
    configuration: ApolloCodegenConfiguration,
    codegenProvider: CodegenProvider.Type
  ) throws {
    try codegenProvider.generateOperationManifest(
      with: configuration,
      withRootURL: rootOutputURL(for: inputs),
      fileManager: .default
    )
  }

  // MARK: - Validation

  enum ParsingError: Swift.Error {
    case manifestVersionMissing
    case outputPathMissing

    var errorDescription: String? {
      switch self {
      case .manifestVersionMissing:
        return """
            `manifest-version` argument missing. When `output-path` is used, `manifest-version` \
            must also be present.
            """
      case .outputPathMissing:
        return """
            No output path for operation manifest found. You must either provide the `output-path` \
            argument or your codegen configuration must have a value present for the \
            `output.operationManifest` option.
            """
      }
    }
  }

  func validate(configuration: ApolloCodegenConfiguration) throws {
    try checkForCLIVersionMismatch(with: inputs)

    if configuration.output.operationManifest == nil {
      guard outputOptions.outputPath != nil else {
        throw ParsingError.outputPathMissing
      }
    }

    if outputOptions.outputPath != nil {
      guard outputOptions.manifestVersion != nil else {
        throw ParsingError.manifestVersionMissing
      }
    }
  }
  
}

extension ApolloCodegenConfiguration.OperationManifestFileOutput.Version: ExpressibleByArgument {}
