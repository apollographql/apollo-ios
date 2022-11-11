import Foundation
import ArgumentParser
import ApolloCodegenLib

public struct Generate: ParsableCommand {

  // MARK: - Configuration
  
  public static var configuration = CommandConfiguration(
    abstract: "Generate Swift source code based on a code generation configuration."
  )

  @OptionGroup var inputs: InputOptions
  @OptionGroup var ignored: IgnoredOptions

  @Flag(
    name: .shortAndLong,
    help: "Fetch the GraphQL schema before Swift code generation."
  )
  var fetchSchema: Bool = false

  @Flag(
    name: .long,
    help: "Ignore Apollo version mismatch errors. This may lead to incompatible generated objects."
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
    schemaDownloadProvider: SchemaDownloadProvider.Type = ApolloSchemaDownloader.self,
    logger: LogLevelSetter.Type = CodegenLogger.self
  ) throws {
    logger.SetLoggingLevel(verbose: inputs.verbose)

    try checkForCLIVersionMismatch()

    switch (inputs.string, inputs.path) {
    case let (.some(string), _):
      try generate(
        data: try string.asData(),
        codegenProvider: codegenProvider,
        schemaDownloadProvider: schemaDownloadProvider
      )

    case let (nil, path):
      let data = try fileManager.unwrappedContents(atPath: path)
      try generate(
        data: data,
        codegenProvider: codegenProvider,
        schemaDownloadProvider: schemaDownloadProvider
      )
    }
  }

  private func checkForCLIVersionMismatch() throws {
    if case let .versionMismatch(cliVersion, apolloVersion) =
        try VersionChecker.matchCLIVersionToApolloVersion(projectRootURL: rootOutputURL(for: inputs)) {
      let errorMessage = """
        Apollo Version Mismatch
        We've detected that the version of the Apollo Codegen CLI does not match the version of the
        Apollo library used in your project. This may lead to incompatible generated objects.

        Please update your version of the Codegen CLI by following the instructions at:
        https://www.apollographql.com/docs/ios/code-generation/codegen-cli/#installation

        CLI version: \(cliVersion)
        Apollo version: \(apolloVersion)
        """

      if ignoreVersionMismatch {
        print("""
          Warning: \(errorMessage)
          """)
      } else {

        throw Error(errorDescription: """
          Error: \(errorMessage)

          To ignore this error and run the CLI anyways, use the argument: --ignore-version-mismatch.
          """)
      }
    }
  }

  private func generate(
    data: Data,
    codegenProvider: CodegenProvider.Type,
    schemaDownloadProvider: SchemaDownloadProvider.Type
  ) throws {
    let configuration = try JSONDecoder().decode(ApolloCodegenConfiguration.self, from: data)

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

    try codegenProvider.build(with: configuration, withRootURL: rootOutputURL(for: inputs))
  }

  private func fetchSchema(
    configuration: ApolloSchemaDownloadConfiguration,
    schemaDownloadProvider: SchemaDownloadProvider.Type
  ) throws {
    try schemaDownloadProvider.fetch(configuration: configuration, withRootURL: rootOutputURL(for: inputs))
  }
}
