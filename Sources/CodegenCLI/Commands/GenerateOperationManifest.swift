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
    
    try checkForCLIVersionMismatch(
      with: inputs
    )

    try generateManifest(
      configuration: inputs.getCodegenConfiguration(fileManager: fileManager),
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
  
}
