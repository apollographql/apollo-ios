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
    /// Generate import statements that are compatible with including `Apollo` via Cocoapods.
    ///
    /// Cocoapods bundles all files from subspecs into the main target for a pod. This means that
    /// when including `Apollo` via Cocoapods, the files in `ApolloAPI` will be added to the
    /// `Apollo` target. In order for the generated code to compile, all `import ApolloAPI`
    /// statements must be generated as `import Apollo` instead. Setting this option to `true`
    /// configures the import statements to be compatible with Cocoapods.
    ///
    /// Defaults to `false`.
    public let cocoapodsCompatibleImportStatements: Bool
    /// Annotate generated Swift code with the Swift `available` attribute and `deprecated`
    /// argument for parts of the GraphQL schema annotated with the built-in `@deprecated`
    /// directive.
    public let warningsOnDeprecatedUsage: Composition
    /// Rules for how to convert the names of values from the schema in generated code.
    public let conversionStrategies: ConversionStrategies
    /// Whether unused generated files will be automatically deleted.
    ///
    /// This will automatically delete any previously generated files that no longer
    /// would be generated.
    ///
    /// This includes:
    /// - Operations whose definitions do not exist
    ///   - `Query`, `Mutation`, `Subscription`, `LocalCacheMutation`
    /// - `Fragments` whose definitions do not exist
    /// - Schema Types that are no longer referenced
    ///   - `Object`, `Interface`, `Union`
    /// - `TestMocks` for schema types that are no longer referenced
    /// - `InputObjects` that are no longer referenced
    ///
    /// This only prunes files in directories that would have been generated given the current ``ApolloCodegenConfiguration/FileInput`` and ``ApolloCodegenConfiguration/FileOutput``
    /// options. Generated files that are no longer in the search paths of the
    /// ``ApolloCodegenConfiguration`` will not be pruned.
    ///
    ///  Defaults to `true`.
    public let pruneGeneratedFiles: Bool

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
    ///  - cocoapodsCompatibleImportStatements: Generate import statements that are compatible with
    ///    including `Apollo` via Cocoapods.
    ///  - warningsOnDeprecatedUsage: Annotate generated Swift code with the Swift `available`
    ///    attribute and `deprecated` argument for parts of the GraphQL schema annotated with the
    ///    built-in `@deprecated` directive.
    ///  - conversionStrategies: Rules for how to convert the names of values from the schema in
    ///    generated code.
    ///  - pruneGeneratedFiles: Whether unused generated files will be automatically deleted.
    public init(
      additionalInflectionRules: [InflectionRule] = [],
      queryStringLiteralFormat: QueryStringLiteralFormat = .multiline,
      deprecatedEnumCases: Composition = .include,
      schemaDocumentation: Composition = .include,
      apqs: APQConfig = .disabled,
      cocoapodsCompatibleImportStatements: Bool = false,
      warningsOnDeprecatedUsage: Composition = .include,
      conversionStrategies: ConversionStrategies = .init(),
      pruneGeneratedFiles: Bool = true
    ) {
      self.additionalInflectionRules = additionalInflectionRules
      self.queryStringLiteralFormat = queryStringLiteralFormat
      self.deprecatedEnumCases = deprecatedEnumCases
      self.schemaDocumentation = schemaDocumentation
      self.apqs = apqs
      self.cocoapodsCompatibleImportStatements = cocoapodsCompatibleImportStatements
      self.warningsOnDeprecatedUsage = warningsOnDeprecatedUsage
      self.conversionStrategies = conversionStrategies
      self.pruneGeneratedFiles = pruneGeneratedFiles
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

  /// ``CaseConversionStrategy`` is used to specify the strategy used to convert the casing of
  /// GraphQL schema values into generated Swift code.
  public enum CaseConversionStrategy: String, Codable, Equatable {
    /// Generates swift code using the exact name provided in the GraphQL schema
    /// performing no conversion.
    case none
    /// Convert to lower camel case from `snake_case`, `UpperCamelCase`, or `UPPERCASE`.
    case camelCase
  }

  /// ``ConversionStrategies`` configures rules for how to convert the names of values from the
  /// schema in generated code.
  public struct ConversionStrategies: Codable, Equatable {
    /// Determines how the names of enum cases in the GraphQL schema will be converted into
    /// cases on the generated Swift enums.
    /// Defaultss to ``ApolloCodegenConfiguration/CaseConversionStrategy/camelCase``
    public let enumCases: CaseConversionStrategy

    public init(enumCases: CaseConversionStrategy = .camelCase) {
      self.enumCases = enumCases
    }
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
     * **EXPERIMENTAL**: If enabled, the parser will understand and parse Client Controlled Nullability
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
     * - Note: This feature is experimental and may change or be removed in the
     * future.
     */
    public let clientControlledNullability: Bool

    /**
     * **EXPERIMENTAL**: If enabled, the generated operations will be transformed using a method
     * that attempts to maintain compatibility with the legacy behavior from
     * [`apollo-tooling`](https://github.dev/apollographql/apollo-tooling)
     * for registering persisted operation to a safelist.
     *
     * - Note: Safelisting queries is a deprecated feature of Apollo Server that has reduced
     * support for legacy use cases. This option may not work as intended in all situations.
     */
    public let legacySafelistingCompatibleOperations: Bool

    public init(
      clientControlledNullability: Bool = false,
      legacySafelistingCompatibleOperations: Bool = false
    ) {
      self.clientControlledNullability = clientControlledNullability
      self.legacySafelistingCompatibleOperations = legacySafelistingCompatibleOperations
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
