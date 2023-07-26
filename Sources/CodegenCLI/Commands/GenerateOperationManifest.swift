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
    
    switch (inputs.string, inputs.path) {
    case let (.some(string), _):
      try generateManifest(
        data: try string.asData(),
        codegenProvider: codegenProvider
      )
    case let (nil, path):
      try generateManifest(
        data: try fileManager.unwrappedContents(atPath: path),
        codegenProvider: codegenProvider
      )
    }
  }
  
  private func generateManifest(
    data: Data,
    codegenProvider: CodegenProvider.Type
  ) throws {
    let configuration = try JSONDecoder().decode(ApolloCodegenConfiguration.self, from: data)
    
    try codegenProvider.generateOperationManifest(
      with: configuration,
      withRootURL: rootOutputURL(for: inputs),
      fileManager: .default
    )
  }
  
}
