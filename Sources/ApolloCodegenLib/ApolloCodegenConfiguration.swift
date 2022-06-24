import Foundation

/// A configuration object that defines behavior for code generation.
public struct ApolloCodegenConfiguration: Codable, Equatable {

  // MARK: Input Types

  /// The input paths and files required for code generation.
  public struct FileInput: Codable, Equatable {
    /// An array of path matching pattern strings used to find GraphQL schema
    /// files to be included for code generation.
    ///
    /// Schema files may contain only spec-compliant
    /// [`TypeSystemDocument`](https://spec.graphql.org/draft/#sec-Type-System) or
    /// [`TypeSystemExtension`](https://spec.graphql.org/draft/#sec-Type-System-Extensions)
    /// definitions in SDL or JSON format.
    /// This includes:
    ///   - [Schema Definitions](https://spec.graphql.org/draft/#SchemaDefinition)
    ///   - [Type Definitions](https://spec.graphql.org/draft/#TypeDefinition)
    ///   - [Directive Definitions](https://spec.graphql.org/draft/#DirectiveDefinition)
    ///   - [Schema Extensions](https://spec.graphql.org/draft/#SchemaExtension)
    ///   - [Type Extensions](https://spec.graphql.org/draft/#TypeExtension)
    ///
    /// You can use absolute or relative paths in path matching patterns. Relative paths will be
    /// based off the current working directory from `FileManager`.
    ///
    /// Each path matching pattern can include the following characters:
    ///  - `*` matches everything but the directory separator (shallow), eg: `*.graphql`
    ///  - `?` matches any single character, eg: `file-?.graphql`
    ///  - `**` matches all subdirectories (deep), eg: `**/*.graphql`
    ///  - `!` excludes any match only if the pattern starts with a `!` character, eg: `!file.graphql`
    ///
    /// - Precondition: JSON format schema files must have the file extension ".json".
    /// When using a JSON format schema file, only a single JSON schema can be provided with any
    /// number of additional SDL schema extension files.
    public let schemaSearchPaths: [String]

    /// An array of path matching pattern strings used to find GraphQL
    /// operation files to be included for code generation.
    ///
    ///  Operation files may contain only spec-compliant
    ///  [`ExecutableDocument`](https://spec.graphql.org/draft/#ExecutableDocument)
    ///  definitions in SDL format.
    ///  This includes:
    ///    - [Operation Definitions](https://spec.graphql.org/draft/#sec-Language.Operations)
    ///    (ie. `query`, `mutation`, or `subscription`)
    ///    - [Fragment Definitions](https://spec.graphql.org/draft/#sec-Language.Fragments)
    ///
    /// You can use absolute or relative paths in path matching patterns. Relative paths will be
    /// based off the current working directory from `FileManager`.
    ///
    /// Each path matching pattern can include the following characters:
    ///  - `*` matches everything but the directory separator (shallow), eg: `*.graphql`
    ///  - `?` matches any single character, eg: `file-?.graphql`
    ///  - `**` matches all subdirectories (deep), eg: `**/*.graphql`
    ///  - `!` excludes any match only if the pattern starts with a `!` character, eg: `!file.graphql`
    public let operationSearchPaths: [String]

    /// Designated initializer.
    ///
    /// - Parameters:
    ///   - schemaSearchPaths: An array of path matching pattern strings used to find GraphQL schema
    ///   files to be included for code generation.
    ///   Schema files may contain only spec-compliant
    ///   [`TypeSystemDocument`](https://spec.graphql.org/draft/#sec-Type-System) or
    ///   [`TypeSystemExtension`](https://spec.graphql.org/draft/#sec-Type-System-Extensions)
    ///   definitions in SDL or JSON format.
    ///   This includes:
    ///     - [Schema Definitions](https://spec.graphql.org/draft/#SchemaDefinition)
    ///     - [Type Definitions](https://spec.graphql.org/draft/#TypeDefinition)
    ///     - [Directive Definitions](https://spec.graphql.org/draft/#DirectiveDefinition)
    ///     - [Schema Extensions](https://spec.graphql.org/draft/#SchemaExtension)
    ///     - [Type Extensions](https://spec.graphql.org/draft/#TypeExtension)
    ///
    ///     Defaults to `["**/*.graphqls"]`.
    ///
    ///   - operationSearchPaths: An array of path matching pattern strings used to find GraphQL
    ///   operation files to be included for code generation.
    ///   Operation files may contain only spec-compliant
    ///   [`ExecutableDocument`](https://spec.graphql.org/draft/#ExecutableDocument)
    ///   definitions in SDL format.
    ///   This includes:
    ///     - [Operation Definitions](https://spec.graphql.org/draft/#sec-Language.Operations)
    ///     (ie. `query`, `mutation`, or `subscription`)
    ///     - [Fragment Definitions](https://spec.graphql.org/draft/#sec-Language.Fragments)
    ///
    ///     Defaults to `["**/*.graphql"]`.
    ///
    ///  You can use absolute or relative paths in path matching patterns. Relative paths will be
    ///  based off the current working directory from `FileManager`.
    ///
    ///  Each path matching pattern can include the following characters:
    ///   - `*` matches everything but the directory separator (shallow), eg: `*.graphql`
    ///   - `?` matches any single character, eg: `file-?.graphql`
    ///   - `**` matches all subdirectories (deep), eg: `**/*.graphql`
    ///   - `!` excludes any match only if the pattern starts with a `!` character, eg: `!file.graphql`
    ///
    /// - Precondition: JSON format schema files must have the file extension ".json".
    /// When using a JSON format schema file, only a single JSON schema can be provided with any
    /// number of additional SDL schema extension files.
    public init(
      schemaSearchPaths: [String] = ["**/*.graphqls"],
      operationSearchPaths: [String] = ["**/*.graphql"]
    ) {
      self.schemaSearchPaths = schemaSearchPaths
      self.operationSearchPaths = operationSearchPaths
    }

    /// Convenience initializer.
    ///
    /// - Parameters:
    ///   - schemaPath: The path to a local GraphQL schema file to be used for code generation.
    ///   Schema files may contain only spec-compliant
    ///   [`TypeSystemDocument`](https://spec.graphql.org/draft/#sec-Type-System) or
    ///   [`TypeSystemExtension`](https://spec.graphql.org/draft/#sec-Type-System-Extensions)
    ///   definitions in SDL or JSON format.
    ///   This includes:
    ///     - [Schema Definitions](https://spec.graphql.org/draft/#SchemaDefinition)
    ///     - [Type Definitions](https://spec.graphql.org/draft/#TypeDefinition)
    ///     - [Directive Definitions](https://spec.graphql.org/draft/#DirectiveDefinition)
    ///     - [Schema Extensions](https://spec.graphql.org/draft/#SchemaExtension)
    ///     - [Type Extensions](https://spec.graphql.org/draft/#TypeExtension)
    ///
    ///   - operationSearchPaths: An array of path matching pattern strings used to find GraphQL
    ///   operation files to be included for code generation.
    ///   Operation files may contain only spec-compliant
    ///   [`ExecutableDocument`](https://spec.graphql.org/draft/#ExecutableDocument)
    ///   definitions in SDL format.
    ///   This includes:
    ///     - [Operation Definitions](https://spec.graphql.org/draft/#sec-Language.Operations)
    ///     (ie. `query`, `mutation`, or `subscription`)
    ///     - [Fragment Definitions](https://spec.graphql.org/draft/#sec-Language.Fragments)
    ///
    ///     Defaults to `["**/*.graphql"]`.
    ///
    ///  You can use absolute or relative paths in path matching patterns. Relative paths will be
    ///  based off the current working directory from `FileManager`.
    ///
    ///  Each path matching pattern can include the following characters:
    ///   - `*` matches everything but the directory separator (shallow), eg: `*.graphql`
    ///   - `?` matches any single character, eg: `file-?.graphql`
    ///   - `**` matches all subdirectories (deep), eg: `**/*.graphql`
    ///   - `!` excludes any match only if the pattern starts with a `!` character, eg: `!file.graphql`
    ///
    /// - Precondition: JSON format schema files must have the file extension ".json".
    /// When using a JSON format schema file, only a single JSON schema can be provided with any
    /// number of additional SDL schema extension files.
    public init(
      schemaPath: String,
      operationSearchPaths: [String] = ["**/*.graphql"]
    ) {
      self.schemaSearchPaths = [schemaPath]
      self.operationSearchPaths = operationSearchPaths
    }
  }

  // MARK: Output Types

  /// The paths and files output by code generation.
  public struct FileOutput: Codable, Equatable {
    /// The local path structure for the generated schema types files.
    public let schemaTypes: SchemaTypesFileOutput
    /// The local path structure for the generated operation object files.
    public let operations: OperationsFileOutput
    /// The local path structure for the test mock operation object files.
    public let testMocks: TestMockFileOutput
    /// An absolute location to an operation id JSON map file. If specified, also stores the
    /// operation IDs (hashes) as properties on operation types.
    public let operationIdentifiersPath: String?
    
    /// Designated initializer.
    ///
    /// - Parameters:
    ///  - schemaTypes: The local path structure for the generated schema types files.
    ///  - operations: The local path structure for the generated operation object files.
    ///  Defaults to `.relative` with a `subpath` of `nil`.
    ///  - testMocks: The local path structure for the test mock operation object files.
    ///  If `.none`, test mocks will not be generated. Defaults to `.none`.
    ///  - operationIdentifiersPath: An absolute location to an operation id JSON map file.
    ///  If specified, also stores the operation IDs (hashes) as properties on operation types.
    ///  Defaults to `nil`.
    public init(
      schemaTypes: SchemaTypesFileOutput,
      operations: OperationsFileOutput = .relative(subpath: nil),
      testMocks: TestMockFileOutput = .none,
      operationIdentifiersPath: String? = nil
    ) {
      self.schemaTypes = schemaTypes
      self.operations = operations
      self.testMocks = testMocks
      self.operationIdentifiersPath = operationIdentifiersPath
    }
  }

  /// The local path structure for the generated schema types files.
  public struct SchemaTypesFileOutput: Codable, Equatable {
    /// Local path where the generated schema types files should be stored.
    public let path: String
    /// Automation to ease the integration of the generated schema types file with compatible
    /// dependency managers.
    public let moduleType: ModuleType

    /// Designated initializer.
    ///
    /// - Parameters:
    ///  - path: Local path where the generated schema type files should be stored.
    ///  - moduleType: Type of module that will be created for the schema types files.
    public init(
      path: String,
      moduleType: ModuleType
    ) {
      self.path = path
      self.moduleType = moduleType
    }

    /// Compatible dependency manager automation.
    public enum ModuleType: Codable, Equatable {
      /// Generated schema types will be manually embedded in a target with the specified `name`.
      /// No module will be created for the generated schema types.
      ///
      /// - Note: Generated files must be manually added to your application target. The generated
      /// schema types files will be namespaced with the value of your configuration's `schemaName`
      /// to prevent naming conflicts.
      case embeddedInTarget(name: String)
      /// Generates a `Package.swift` file that is suitable for linking the generated schema types
      /// files to your project using Swift Package Manager.
      case swiftPackageManager
      /// No module will be created for the generated types and you are required to create the
      /// module to support your preferred dependency manager. You must specify the name of the
      /// module you will create in the `schemaName` property as this will be used in `import`
      /// statements of generated operation files.
      ///
      /// Use this option for dependency managers, such as CocoaPods or Carthage. Example usage
      /// would be to create the podspec file (CocoaPods) or Xcode project file (Carthage) that
      /// is expecting the generated files in the configured output location.
      case other
    }
  }

  /// The local path structure for the generated operation object files.
  public enum OperationsFileOutput: Codable, Equatable {
    /// All operation object files will be located in the module with the schema types.
    case inSchemaModule
    /// Operation object files will be co-located relative to the defining operation `.graphql`
    /// file. If `subpath` is specified a subfolder will be created relative to the `.graphql` file
    /// and the operation object files will be generated there. If no `subpath` is defined then all
    /// operation object files will be generated alongside the `.graphql` file.
    case relative(subpath: String?)
    /// All operation object files will be located in the specified path.
    case absolute(path: String)
  }

  /// The local path structure for the generated test mock object files.
  public enum TestMockFileOutput: Codable, Equatable {
    /// Test mocks will not be generated. This is the default value.
    case none
    /// Generated test mock files will be located in the specified path.
    /// No module will be created for the generated test mocks.
    ///
    ///- Note: Generated files must be manually added to your test target. Test mocks generated
    /// this way may also be manually embedded in a test utility module that is imported by your
    /// test target.
    case absolute(path: String)
    /// Generated test mock files will be included in a target defined in the generated
    /// `Package.swift` file that is suitable for linking the generated test mock files to your
    /// test target using Swift Package Manager.
    ///
    /// The name of the test mock target can be specified with the `targetName` value.
    /// If no target name is provided, the target name defaults to "\(schemaName)TestMocks".
    ///
    /// - Note: This requires your `SchemaTypesFileOutput.ModuleType` to be `.swiftPackageManager`.
    /// If this option is provided without the `.swiftPackageManager` module type, code generation
    /// will fail.
    case swiftPackage(targetName: String? = nil)
  }

  // MARK: - Output Options
  public struct OutputOptions: Codable, Equatable {
    /// Any non-default rules for pluralization or singularization you wish to include.
    public let additionalInflectionRules: [InflectionRule]
    /// Formatting of the GraphQL query string literal that is included in each
    /// generated operation object.
    public let queryStringLiteralFormat: QueryStringLiteralFormat
    /// How deprecated enum cases from the schema should be handled.
    public let deprecatedEnumCases: Composition
    /// Whether schema documentation is added to the generated files.
    public let schemaDocumentation: Composition
    /// Whether the generated operations should use Automatic Persisted Queries.
    ///
    /// See `APQConfig` for more information on Automatic Persisted Queries.
    public let apqs: APQConfig

    /// Designated initializer.
    ///
    /// - Parameters:
    ///  - additionalInflectionRules: Any non-default rules for pluralization or singularization
    ///  you wish to include.
    ///  - queryStringLiteralFormat: Formatting of the GraphQL query string literal that is
    ///  included in each generated operation object.
    ///  - deprecatedEnumCases: How deprecated enum cases from the schema should be handled.
    ///  - schemaDocumentation: Whether schema documentation is added to the generated files.
    ///  - apqs: Whether the generated operations should use Automatic Persisted Queries.
    public init(
      additionalInflectionRules: [InflectionRule] = [],
      queryStringLiteralFormat: QueryStringLiteralFormat = .multiline,
      deprecatedEnumCases: Composition = .include,
      schemaDocumentation: Composition = .include,
      apqs: APQConfig = .disabled
    ) {
      self.additionalInflectionRules = additionalInflectionRules
      self.queryStringLiteralFormat = queryStringLiteralFormat
      self.deprecatedEnumCases = deprecatedEnumCases
      self.schemaDocumentation = schemaDocumentation
      self.apqs = apqs
    }
  }

  /// Specify the formatting of the GraphQL query string literal.
  public enum QueryStringLiteralFormat: String, Codable, Equatable {
    /// The query string will be copied into the operation object with all line break formatting removed.
    case singleLine
    /// The query string will be copied with original formatting into the operation object.
    case multiline
  }

  /// Composition is used as a substitute for a boolean where context is better placed in the value
  /// instead of the parameter name, e.g.: `includeDeprecatedEnumCases = true` vs.
  /// `deprecatedEnumCases = .include`.
  public enum Composition: String, Codable, Equatable {
    case include
    case exclude
  }

  /// Enum to enable using
  /// [Automatic Persisted Queries (APQs)](https://www.apollographql.com/docs/apollo-server/performance/apq)
  /// with your generated operations.
  ///
  /// APQs are an Apollo Server feature. When using Apollo iOS to connect to any other GraphQL server,
  /// `APQConfig` should be set to `.disabled`
  public enum APQConfig: String, Codable, Equatable {
    /// The default value. Disables APQs.
    /// The operation document is sent to the server with each operation request.
    case disabled

    /// Automatically persists your operations using Apollo Server's
    /// [APQs](https://www.apollographql.com/docs/apollo-server/performance/apq).
    case automaticallyPersist

    /// Provides only the `operationIdentifier` for operations that have been previously persisted
    /// to an Apollo Server using
    /// [APQs](https://www.apollographql.com/docs/apollo-server/performance/apq).
    ///
    /// If the server does not recognize the `operationIdentifier`, the operation will fail. This
    /// method should only be used if you are manually persisting your queries to an Apollo Server.
    case persistedOperationsOnly
  }

  // MARK: - Other Types

  public struct ExperimentalFeatures: Codable, Equatable {
    /**
     * EXPERIMENTAL: If enabled, the parser will understand and parse Client Controlled Nullability
     * Designators contained in Fields. They'll be represented in the
     * `required` field of the FieldNode.
     *
     * The syntax looks like the following:
     *
     * ```graphql
     *   {
     *     nullableField!
     *     nonNullableField?
     *     nonNullableSelectionSet? {
     *       childField!
     *     }
     *   }
     * ```
     * Note: this feature is experimental and may change or be removed in the
     * future.
     */
    public let clientControlledNullability: Bool

    public init(clientControlledNullability: Bool = false) {
      self.clientControlledNullability = clientControlledNullability
    }
  }

  // MARK: Properties

  /// Name used to scope the generated schema type files.
  public let schemaName: String
  /// The input files required for code generation.
  public let input: FileInput
  /// The paths and files output by code generation.
  public let output: FileOutput
  /// Rules and options to customize the generated code.
  public let options: OutputOptions
  /// Allows users to enable experimental features.
  ///
  /// Note: These features could change at any time and they are not guaranteed to always be
  /// available.
  public let experimentalFeatures: ExperimentalFeatures
  /// Schema download configuration.
  public let schemaDownloadConfiguration: ApolloSchemaDownloadConfiguration?

  // MARK: Initializers

  /// Designated initializer.
  ///
  /// - Parameters:
  ///  - schemaName: Name used to scope the generated schema type files.
  ///  - input: The input files required for code generation.
  ///  - output: The paths and files output by code generation.
  ///  - options: Rules and options to customize the generated code.
  ///  - experimentalFeatures: Allows users to enable experimental features.
  public init(
    schemaName: String,
    input: FileInput,
    output: FileOutput,
    options: OutputOptions = OutputOptions(),
    experimentalFeatures: ExperimentalFeatures = ExperimentalFeatures(),
    schemaDownloadConfiguration: ApolloSchemaDownloadConfiguration? = nil
  ) {
    self.schemaName = schemaName
    self.input = input
    self.output = output
    self.options = options
    self.experimentalFeatures = experimentalFeatures
    self.schemaDownloadConfiguration = schemaDownloadConfiguration
  }

}

// MARK: - Validation Extension

extension ApolloCodegenConfiguration {
  public enum PathType {
    case schema
    case schemaTypes
    case operations
    case operationIdentifiers

    public var errorRecoverySuggestion: String {
      switch self {
      case .schema:
        return "Check that the schema input path is an existing schema file containing SDL or JSON."
      case .schemaTypes:
        return "Check that the schema types output path exists and is a directory, or can be created."
      case .operations:
        return "Check that the operations output path exists and is a directory, or can be created."
      case .operationIdentifiers:
        return "Check that the operations identifiers path is an existing file or can be created."
      }
    }
  }

  /// Errors which can happen with code generation
  public enum Error: Swift.Error, LocalizedError, Equatable {
    case notAFile(PathType)
    case notADirectory(PathType)
    case folderCreationFailed(PathType, underlyingError: Swift.Error)
    case testMocksInvalidSwiftPackageConfiguration

    public var errorDescription: String {
      switch self {
      case let .notAFile(pathType):
        return "\(pathType) path must be a file!"
      case let .notADirectory(pathType):
        return "\(pathType) path must be a folder!"
      case let .folderCreationFailed(pathType, underlyingError):
        return "\(pathType) folder cannot be created! Error: \(underlyingError)"
      case .testMocksInvalidSwiftPackageConfiguration:
        return "Invalid Configuration: Test mocks swift package without schema types swift package generated!"
      }
    }

    public var recoverySuggestion: String {
      switch self {
      case let .notAFile(pathType),
        let .notADirectory(pathType),
        let .folderCreationFailed(pathType, _):
        return pathType.errorRecoverySuggestion
      case .testMocksInvalidSwiftPackageConfiguration:
        return "Schema Types must be generated with module type 'swiftPackageManager' to generate a swift package for test mocks."
      }
    }

    public func logging(withPath path: String) -> Error {
      CodegenLogger.log(self.logMessage(forPath: path), logLevel: .error)
      CodegenLogger.log(self.recoverySuggestion, logLevel: .debug)
      return self
    }

    private func logMessage(forPath path: String) -> String {
      self.errorDescription + "Path: \(path)"
    }

    public static func == (lhs: Error, rhs: Error) -> Bool {
      lhs.errorDescription == rhs.errorDescription
    }
  }

  /// Validates paths within the configuration ensuring that required files exist and that output
  /// directories can be created.
  public func validate() throws {
    try validateTestMocksConfiguration()

    let fileManager = FileManager.default.apollo

    CodegenLogger.log("Validating \(String(describing: self))", logLevel: .debug)

    // File inputs
    if input.schemaSearchPaths.count == 1 {
      let schemaPath = input.schemaSearchPaths[0]
      guard fileManager.doesFileExist(atPath: schemaPath) else {
        throw Error.notAFile(.schema).logging(withPath: schemaPath)
      }
    }

    // File outputs - schema types
    try requireDirectory(atPath: output.schemaTypes.path, ofType: .schemaTypes)

    // File outputs - operations
    if case .absolute(let operationsOutputPath) = output.operations {
      try requireDirectory(atPath: operationsOutputPath, ofType: .operations)
    }

    // File outputs - operation identifiers
    if let operationIdentifiersPath = output.operationIdentifiersPath {
      if fileManager.doesDirectoryExist(atPath: operationIdentifiersPath) {
        throw Error.notAFile(.operationIdentifiers).logging(withPath: operationIdentifiersPath)
      }
    }
  }

  private func validateTestMocksConfiguration() throws {
    if case .swiftPackage = output.testMocks,
        output.schemaTypes.moduleType != .swiftPackageManager {
      throw Error.testMocksInvalidSwiftPackageConfiguration
    }
  }

  /// Validates that if the given path exists it is a directory. If it does not exist it attempts to create it.
  private func requireDirectory(atPath path: String, ofType pathType: PathType) throws {
    let fileManager = FileManager.default.apollo

    if fileManager.doesFileExist(atPath: path) {
      throw Error.notADirectory(pathType).logging(withPath: path)
    }

    do {
      try fileManager.createDirectoryIfNeeded(atPath: path)
    } catch (let underlyingError) {
      throw Error.folderCreationFailed(pathType, underlyingError: underlyingError)
        .logging(withPath: path)
    }
  }
}

// MARK: - Helpers

extension ApolloCodegenConfiguration.SchemaTypesFileOutput {
  /// Determine whether the schema types files are output to a module.
  var isInModule: Bool {
    switch moduleType {
    case .embeddedInTarget: return false
    case .swiftPackageManager, .other: return true
    }
  }  
}

extension ApolloCodegenConfiguration.OperationsFileOutput {
  /// Determine whether the operations files are output to the schema types module.
  var isInModule: Bool {
    switch self {
    case .inSchemaModule: return true
    case .absolute, .relative: return false
    }
  }
}
