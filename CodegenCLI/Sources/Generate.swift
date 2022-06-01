import Foundation
import ArgumentParser
import ApolloCodegenLib

struct Generate: ParsableCommand {

  // MARK: - Configuration
  
  static var configuration = CommandConfiguration(
    abstract: "Generate Swift source code based on a code generation configuration."
  )

  @Option(
    name: .shortAndLong,
    help: "Read the configuration from a file at the path."
  )
  var path: String = Constants.defaultFilePath

  @Option(
    name: .shortAndLong,
    help: "Configuration string in JSON format."
  )
  var string: String?

  @Flag(
    name: .shortAndLong,
    help: "Fetch the GraphQL schema before Swift code generation."
  )
  var fetchSchema: Bool = false

  // MARK: - Implementation

  func run() throws {
    try _run()
  }

  func _run(
    fileManager: FileManager = .default,
    codegenProvider: CodegenProvider.Type = ApolloCodegen.self,
    schemaDownloadProvider: SchemaDownloadProvider.Type = ApolloSchemaDownloader.self
  ) throws {
    if let string = string {
      try generate(
        data: try string.asData(),
        codegenProvider: codegenProvider,
        schemaDownloadProvider: schemaDownloadProvider
      )
      return
    }

    guard let data = fileManager.contents(atPath: path) else {
      throw Error(errorDescription: "Cannot read configuration file at \(path)")
    }

    try generate(
      data: data,
      codegenProvider: codegenProvider,
      schemaDownloadProvider: schemaDownloadProvider
    )
  }

  private func generate(
    data: Data,
    codegenProvider: CodegenProvider.Type,
    schemaDownloadProvider: SchemaDownloadProvider.Type
  ) throws {
    let configuration = try JSONDecoder().decode(ApolloCodegenConfiguration.self, from: data)

    CodegenLogger.level = .warning

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
    
    try codegenProvider.build(with: configuration)
  }

  private func fetchSchema(
    configuration: ApolloSchemaDownloadConfiguration,
    schemaDownloadProvider: SchemaDownloadProvider.Type
  ) throws {
    try schemaDownloadProvider.fetch(configuration: configuration)
  }
}
