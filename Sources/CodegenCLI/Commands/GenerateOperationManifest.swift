import Foundation
import ArgumentParser
import ApolloCodegenLib

public struct GenerateOperationManifest: ParsableCommand {
  
  // MARK: - Configuration
  
  public static var configuration = CommandConfiguration(
    abstract: "Generate Persisted Queries operation manifest based on a code generation configuration."
  )

  @OptionGroup var inputs: InputOptions

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

    let configuration = try inputs.getCodegenConfiguration(fileManager: fileManager)

    try validate(configuration: configuration)

    try generateManifest(
      configuration: configuration,
      codegenProvider: codegenProvider
    )
  }
  
  private func generateManifest(
    configuration: ApolloCodegenConfiguration,
    codegenProvider: CodegenProvider.Type
  ) throws {
    try codegenProvider.build(
      with: configuration,
      withRootURL: rootOutputURL(for: inputs),
      itemsToGenerate: [.operationManifest]
    )
  }

  // MARK: - Validation

  func validate(configuration: ApolloCodegenConfiguration) throws {
    try checkForCLIVersionMismatch(with: inputs)

    guard configuration.operationManifestConfiguration != nil else {
      throw ValidationError("""
          `operationManifestConfiguration` section must be set in the codegen configuration JSON in order
          to generate and operation manifest.
          """)
    }
  }
  
}
