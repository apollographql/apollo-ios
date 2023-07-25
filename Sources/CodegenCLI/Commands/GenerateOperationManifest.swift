import Foundation
import ArgumentParser
import ApolloCodegenLib

public struct GenerateOperationManifest: ParsableCommand {
  
  // MARK: - Configuration
  
  public static var configuration = CommandConfiguration(
    abstract: "Generate Persisted Queries operation manifest based on a code generation configuration."
  )
  
  @OptionGroup var inputs: InputOptions
  
  @Flag(
    name: .long,
    help: "Ignore Apollo version mismatch errors. Warning: This may lead to incompatible generated objects."
  )
  var ignoreVersionMismatch: Bool = false
  
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
      with: inputs,
      ignoreVersionMismatch: ignoreVersionMismatch
    )
    
    var configData: Data?
    switch (inputs.string, inputs.path) {
    case let (.some(string), _):
      configData = try string.asData()
    case let (nil, path):
      configData = try fileManager.unwrappedContents(atPath: path)
    }
    
    guard let data = configData else {
      print("""
        Error: Codegen Configuration Error
        
        No valid codegen configuration data was found. Please double check
        the string/path provided and try again.
        """)
      return
    }
    let configuration = try JSONDecoder().decode(ApolloCodegenConfiguration.self, from: data)
    
    try codegenProvider.generateOperationManifest(
      with: configuration,
      withRootURL: rootOutputURL(for: inputs),
      fileManager: .default
    )
  }
  
}
