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
    /// An absolute location to an operation id JSON map file.
    public let operationIdentifiersPath: String?

    /// Default property values
    public struct Default {
      public static let operations: OperationsFileOutput = .inSchemaModule
      public static let testMocks: TestMockFileOutput = .none
      public static let operationIdentifiersPath: String? = nil
    }

    /// Designated initializer.
    ///
    /// - Parameters:
    ///  - schemaTypes: The local path structure for the generated schema types files.
    ///  - operations: The local path structure for the generated operation object files.
    ///  Defaults to `.inSchemaModule`.
    ///  - testMocks: The local path structure for the test mock operation object files.
    ///  If `.none`, test mocks will not be generated. Defaults to `.none`.
    ///  - operationIdentifiersPath: An absolute location to an operation id JSON map file.
    ///  If specified, also stores the operation IDs (hashes) as properties on operation types.
    ///  Defaults to `nil`.
    public init(
      schemaTypes: SchemaTypesFileOutput,
      operations: OperationsFileOutput = Default.operations,
      testMocks: TestMockFileOutput = Default.testMocks,
      operationIdentifiersPath: String? = Default.operationIdentifiersPath
    ) {
      self.schemaTypes = schemaTypes
      self.operations = operations
      self.testMocks = testMocks
      self.operationIdentifiersPath = operationIdentifiersPath
    }

    // MARK: Codable

    enum CodingKeys: CodingKey {
      case schemaTypes
      case operations
      case testMocks
      case operationIdentifiersPath
    }

    /// `Decodable` implementation to allow for properties to be optional in the encoded JSON with
    /// specified defaults when not present.
    public init(from decoder: Decoder) throws {
      let values = try decoder.container(keyedBy: CodingKeys.self)

      schemaTypes = try values.decode(SchemaTypesFileOutput.self, forKey: .schemaTypes)
      operations = try values.decode(OperationsFileOutput.self, forKey: .operations)
      testMocks = try values.decode(TestMockFileOutput.self, forKey: .testMocks)

      operationIdentifiersPath = try values.decodeIfPresent(
        String.self,
        forKey: .operationIdentifiersPath
      ) ?? Default.operationIdentifiersPath
    }
  }

  /// The local path structure for the generated schema types files.
  public struct SchemaTypesFileOutput: Codable, Equatable {
    /// Local path where the generated schema types files should be stored.
    public let path: String
    /// How to package the schema types for dependency management.
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
      /// schema types files will be namespaced with the value of your configuration's
      /// `schemaNamespace` to prevent naming conflicts.
      case embeddedInTarget(name: String)
      /// Generates a `Package.swift` file that is suitable for linking the generated schema types
      /// files to your project using Swift Package Manager.
      case swiftPackageManager
      /// No module will be created for the generated types and you are required to create the
      /// module to support your preferred dependency manager. You must specify the name of the
      /// module you will create in the `schemaNamespace` property as this will be used in `import`
      /// statements of generated operation files.
      ///
      /// Use this option for dependency managers, such as CocoaPods. Example usage would be to 
      /// create the podspec file that is expecting the generated files in the configured output 
      /// location.
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
    /// - Note: Generated files must be manually added to your test target. Test mocks generated
    /// this way may also be manually embedded in a test utility module that is imported by your
    /// test target.
    case absolute(path: String)
    /// Generated test mock files will be included in a target defined in the generated
    /// `Package.swift` file that is suitable for linking the generated test mock files to your
    /// test target using Swift Package Manager.
    ///
    /// The name of the test mock target can be specified with the `targetName` value.
    /// If no target name is provided, the target name defaults to "\(schemaNamespace)TestMocks".
    ///
    /// - Note: This requires your `SchemaTypesFileOutput.ModuleType` to be `.swiftPackageManager`.
    /// If this option is provided without the `.swiftPackageManager` module type, code generation
    /// will fail.
    case swiftPackage(targetName: String? = nil)
  }

  // MARK: - Other Types
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
    /// Which generated selection sets should include generated initializers.
    public let selectionSetInitializers: SelectionSetInitializers
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

    /// Default property values
    public struct Default {
      public static let additionalInflectionRules: [InflectionRule] = []
      public static let queryStringLiteralFormat: QueryStringLiteralFormat = .multiline
      public static let deprecatedEnumCases: Composition = .include
      public static let schemaDocumentation: Composition = .include
      public static let selectionSetInitializers: SelectionSetInitializers = [.localCacheMutations]
      public static let apqs: APQConfig = .disabled
      public static let cocoapodsCompatibleImportStatements: Bool = false
      public static let warningsOnDeprecatedUsage: Composition = .include
      public static let conversionStrategies: ConversionStrategies = .init()
      public static let pruneGeneratedFiles: Bool = true
    }

    /// Designated initializer.
    ///
    /// - Parameters:
    ///  - additionalInflectionRules: Any non-default rules for pluralization or singularization
    ///  you wish to include.
    ///  - queryStringLiteralFormat: Formatting of the GraphQL query string literal that is
    ///  included in each generated operation object.
    ///  - deprecatedEnumCases: How deprecated enum cases from the schema should be handled.
    ///  - schemaDocumentation: Whether schema documentation is added to the generated files.
    ///  - selectionSetInitializers: Which generated selection sets should include
    ///    generated initializers.
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
      additionalInflectionRules: [InflectionRule] = Default.additionalInflectionRules,
      queryStringLiteralFormat: QueryStringLiteralFormat = Default.queryStringLiteralFormat,
      deprecatedEnumCases: Composition = Default.deprecatedEnumCases,
      schemaDocumentation: Composition = Default.schemaDocumentation,
      selectionSetInitializers: SelectionSetInitializers = Default.selectionSetInitializers,
      apqs: APQConfig = Default.apqs,
      cocoapodsCompatibleImportStatements: Bool = Default.cocoapodsCompatibleImportStatements,
      warningsOnDeprecatedUsage: Composition = Default.warningsOnDeprecatedUsage,
      conversionStrategies: ConversionStrategies = Default.conversionStrategies,
      pruneGeneratedFiles: Bool = Default.pruneGeneratedFiles
    ) {
      self.additionalInflectionRules = additionalInflectionRules
      self.queryStringLiteralFormat = queryStringLiteralFormat
      self.deprecatedEnumCases = deprecatedEnumCases
      self.schemaDocumentation = schemaDocumentation
      self.selectionSetInitializers = selectionSetInitializers
      self.apqs = apqs
      self.cocoapodsCompatibleImportStatements = cocoapodsCompatibleImportStatements
      self.warningsOnDeprecatedUsage = warningsOnDeprecatedUsage
      self.conversionStrategies = conversionStrategies
      self.pruneGeneratedFiles = pruneGeneratedFiles
    }

    // MARK: Codable

    enum CodingKeys: CodingKey {
      case additionalInflectionRules
      case queryStringLiteralFormat
      case deprecatedEnumCases
      case schemaDocumentation
      case selectionSetInitializers
      case apqs
      case cocoapodsCompatibleImportStatements
      case warningsOnDeprecatedUsage
      case conversionStrategies
      case pruneGeneratedFiles
    }

    public init(from decoder: Decoder) throws {
      let values = try decoder.container(keyedBy: CodingKeys.self)

      additionalInflectionRules = try values.decodeIfPresent(
        [InflectionRule].self,
        forKey: .additionalInflectionRules
      ) ?? Default.additionalInflectionRules

      queryStringLiteralFormat = try values.decodeIfPresent(
        QueryStringLiteralFormat.self,
        forKey: .queryStringLiteralFormat
      ) ?? Default.queryStringLiteralFormat

      deprecatedEnumCases = try values.decodeIfPresent(
        Composition.self,
        forKey: .deprecatedEnumCases
      ) ?? Default.deprecatedEnumCases

      schemaDocumentation = try values.decodeIfPresent(
        Composition.self,
        forKey: .schemaDocumentation
      ) ?? Default.schemaDocumentation

      selectionSetInitializers = try values.decodeIfPresent(
        SelectionSetInitializers.self,
        forKey: .selectionSetInitializers
      ) ?? Default.selectionSetInitializers

      apqs = try values.decodeIfPresent(
        APQConfig.self,
        forKey: .apqs
      ) ?? Default.apqs

      cocoapodsCompatibleImportStatements = try values.decodeIfPresent(
        Bool.self,
        forKey: .cocoapodsCompatibleImportStatements
      ) ?? Default.cocoapodsCompatibleImportStatements

      warningsOnDeprecatedUsage = try values.decodeIfPresent(
        Composition.self,
        forKey: .warningsOnDeprecatedUsage
      ) ?? Default.warningsOnDeprecatedUsage

      conversionStrategies = try values.decodeIfPresent(
        ConversionStrategies.self,
        forKey: .conversionStrategies
      ) ?? Default.conversionStrategies

      pruneGeneratedFiles = try values.decodeIfPresent(
        Bool.self,
        forKey: .pruneGeneratedFiles
      ) ?? Default.pruneGeneratedFiles
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

    /// Default property values
    public struct Default {
      public static let enumCases: CaseConversionStrategy = .camelCase
    }

    public init(enumCases: CaseConversionStrategy = Default.enumCases) {
      self.enumCases = enumCases
    }

    // MARK: Codable

    public enum CodingKeys: CodingKey {
      case enumCases
    }

    public init(from decoder: Decoder) throws {
      let values = try decoder.container(keyedBy: CodingKeys.self)

      enumCases = try values.decodeIfPresent(
        CaseConversionStrategy.self,
        forKey: .enumCases
      ) ?? Default.enumCases
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
  
  /// The ``SelectionSetInitializers`` configuration is used to determine if you would like
  /// initializers to be generated for your generated selection set models.
  ///
  /// There are three categories of selection set models that initializers can be generated for:
  /// - Operations
  /// - Named fragments
  /// - Local cache mutations
  ///
  /// By default, initializers are only generated for local cache mutations.
  ///
  /// ``SelectionSetInitializers`` functions like an `OptionSet`, allowing you to combine multiple
  /// different instances together to indicate all the types you would like to generate
  /// initializers for.
  public struct SelectionSetInitializers: Codable, Equatable, ExpressibleByArrayLiteral {
    private var options: SelectionSetInitializers.Options
    private var definitions: Set<String>

    /// Option to generate initializers for all named fragments.
    public static let namedFragments: SelectionSetInitializers = .init(.namedFragments)

    /// Option to generate initializers for all operations (queries, mutations, subscriptions)
    /// that are not local cache mutations.
    public static let operations: SelectionSetInitializers = .init(.operations)

    /// Option to generate initializers for all local cache mutations.
    public static let localCacheMutations: SelectionSetInitializers = .init(.localCacheMutations)

    /// Option to generate initializers for all models.
    /// This includes named fragments, operations, and local cache mutations.
    public static let all: SelectionSetInitializers = [
      .namedFragments, .operations, .localCacheMutations
    ]

    /// An option to generate initializers for a single operation with a given name.
    public static func operation(named: String) -> SelectionSetInitializers {
      .init(definitionName: named)
    }

    /// An option to generate initializers for a single fragment with a given name.
    public static func fragment(named: String) -> SelectionSetInitializers {
      .init(definitionName: named)
    }

    /// Initializes a `SelectionSetInitializer` with an array of values.
    public init(arrayLiteral elements: SelectionSetInitializers...) {
      guard var options = elements.first else {
        self.options = []
        self.definitions = []
        return
      }
      for element in elements.suffix(from: 1) {
        options.insert(element)
      }
      self = options
    }

    /// Inserts a `SelectionSetInitializer` into the receiver.
    public mutating func insert(_ member: SelectionSetInitializers) {
      self.options = self.options.union(member.options)
      self.definitions = self.definitions.union(member.definitions)
    }
  }

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

    /// Default property values
    public struct Default {
      public static let clientControlledNullability: Bool = false
      public static let legacySafelistingCompatibleOperations: Bool = false
    }

    public init(
      clientControlledNullability: Bool = Default.clientControlledNullability,
      legacySafelistingCompatibleOperations: Bool = Default.legacySafelistingCompatibleOperations
    ) {
      self.clientControlledNullability = clientControlledNullability
      self.legacySafelistingCompatibleOperations = legacySafelistingCompatibleOperations
    }

    // MARK: Codable

    public enum CodingKeys: CodingKey {
      case clientControlledNullability
      case legacySafelistingCompatibleOperations
    }

    public init(from decoder: Decoder) throws {
      let values = try decoder.container(keyedBy: CodingKeys.self)

      clientControlledNullability = try values.decodeIfPresent(
        Bool.self,
        forKey: .clientControlledNullability
      ) ?? Default.clientControlledNullability

      legacySafelistingCompatibleOperations = try values.decodeIfPresent(
        Bool.self,
        forKey: .legacySafelistingCompatibleOperations
      ) ?? Default.legacySafelistingCompatibleOperations
    }
  }

  // MARK: - Properties

  /// Name used to scope the generated schema type files.
  public let schemaNamespace: String
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

  public struct Default {
    public static let options: OutputOptions = OutputOptions()
    public static let experimentalFeatures: ExperimentalFeatures = ExperimentalFeatures()
    public static let schemaDownloadConfiguration: ApolloSchemaDownloadConfiguration? = nil
  }

  // MARK: - Helper Properties
  
  let ApolloAPITargetName: String

  // MARK: Initializers

  /// Designated initializer.
  ///
  /// - Parameters:
  ///  - schemaNamespace: Name used to scope the generated schema type files.
  ///  - input: The input files required for code generation.
  ///  - output: The paths and files output by code generation.
  ///  - options: Rules and options to customize the generated code.
  ///  - experimentalFeatures: Allows users to enable experimental features.
  public init(
    schemaNamespace: String,
    input: FileInput,
    output: FileOutput,
    options: OutputOptions = Default.options,
    experimentalFeatures: ExperimentalFeatures = Default.experimentalFeatures,
    schemaDownloadConfiguration: ApolloSchemaDownloadConfiguration? = Default.schemaDownloadConfiguration
  ) {
    self.schemaNamespace = schemaNamespace
    self.input = input
    self.output = output
    self.options = options
    self.experimentalFeatures = experimentalFeatures
    self.schemaDownloadConfiguration = schemaDownloadConfiguration
    self.ApolloAPITargetName = options.cocoapodsCompatibleImportStatements ? "Apollo" : "ApolloAPI"
  }

  // MARK: Codable

  enum CodingKeys: CodingKey {
    case schemaName
    case schemaNamespace
    case input
    case output
    case options
    case experimentalFeatures
    case schemaDownloadConfiguration
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encode(self.schemaNamespace, forKey: .schemaNamespace)
    try container.encode(self.input, forKey: .input)
    try container.encode(self.output, forKey: .output)
    try container.encode(self.options, forKey: .options)
    try container.encode(experimentalFeatures, forKey: .experimentalFeatures)

    if let schemaDownloadConfiguration {
      try container.encode(schemaDownloadConfiguration, forKey: .schemaDownloadConfiguration)
    }
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    func getSchemaNamespaceValue() throws -> String {
      if let value = try values.decodeIfPresent(String.self, forKey: .schemaNamespace) {
        return value
      }
      if let value = try values.decodeIfPresent(String.self, forKey: .schemaName) {
        return value
      }

      throw DecodingError.keyNotFound(
        CodingKeys.schemaNamespace,
        .init(
          codingPath: [CodingKeys.schemaNamespace],
          debugDescription: "Cannot find value for 'schemaNamespace' key"
        )
      )
    }

    self.init(
      schemaNamespace: try getSchemaNamespaceValue(),
      input: try values.decode(FileInput.self, forKey: .input),
      output: try values.decode(FileOutput.self, forKey: .output),
      options: try values.decodeIfPresent(
        OutputOptions.self,
        forKey: .options
      ) ?? Default.options,
      experimentalFeatures: try values.decodeIfPresent(
        ExperimentalFeatures.self,
        forKey: .experimentalFeatures
      ) ?? Default.experimentalFeatures,
      schemaDownloadConfiguration: try values.decodeIfPresent(
        ApolloSchemaDownloadConfiguration.self,
        forKey: .schemaDownloadConfiguration
      ) ?? Default.schemaDownloadConfiguration
    )
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

extension ApolloCodegenConfiguration.OutputOptions {
  /// Determine whether the operations files are output to the schema types module.
  func shouldGenerateSelectionSetInitializers(for operation: IR.Operation) -> Bool {
    switch operation.definition.isLocalCacheMutation {
    case true where selectionSetInitializers.contains(.localCacheMutations):
      return true

    case false where selectionSetInitializers.contains(.operations):
      return true

    default:
      return selectionSetInitializers.contains(definitionNamed: operation.definition.name)
    }
  }

  /// Determine whether the operations files are output to the schema types module.
  func shouldGenerateSelectionSetInitializers(for fragment: IR.NamedFragment) -> Bool {
    if selectionSetInitializers.contains(.namedFragments) { return true }

    if fragment.definition.isLocalCacheMutation &&
        selectionSetInitializers.contains(.localCacheMutations) {
      return true
    }

    return selectionSetInitializers.contains(definitionNamed: fragment.definition.name)
  }
}

// MARK: - SelectionSetInitializers - Private Implementation
extension ApolloCodegenConfiguration.SelectionSetInitializers {
  struct Options: OptionSet, Codable, Equatable {
    let rawValue: Int
    static let localCacheMutations = Options(rawValue: 1 << 0)
    static let namedFragments      = Options(rawValue: 1 << 1)
    static let operations          = Options(rawValue: 1 << 2)
  }

  private init(_ options: Options) {
    self.options = options
    self.definitions = []
  }

  private init(definitionName: String) {
    self.options = []
    self.definitions = [definitionName]
  }

  func contains(_ options: Self.Options) -> Bool {
    self.options.contains(options)
  }

  func contains(definitionNamed definitionName: String) -> Bool {
    self.definitions.contains(definitionName)
  }

  // MARK: Codable

  enum CodingKeys: CodingKey {
    case operations
    case namedFragments
    case localCacheMutations
    case definitionsNamed
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    var options: Options = []

    func decode(option: @autoclosure () -> Options, forKey key: CodingKeys) throws {
      if let value = try values.decodeIfPresent(Bool.self, forKey: key), value {
        options.insert(option())
      }
    }

    try decode(option: .operations, forKey: .operations)
    try decode(option: .namedFragments, forKey: .namedFragments)
    try decode(option: .localCacheMutations, forKey: .localCacheMutations)

    self.options = options
    self.definitions = try values.decodeIfPresent(
      Set<String>.self,
      forKey: .definitionsNamed) ?? []
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    func encodeIfPresent(option: Options, forKey key: CodingKeys) throws {
      if options.contains(option) {
        try container.encode(true, forKey: key)
      }
    }

    try encodeIfPresent(option: .operations, forKey: .operations)
    try encodeIfPresent(option: .namedFragments, forKey: .namedFragments)
    try encodeIfPresent(option: .localCacheMutations, forKey: .localCacheMutations)

    if !definitions.isEmpty {
      try container.encode(definitions.sorted(), forKey: .definitionsNamed)
    }
  }
}

// MARK: - Deprecations

extension ApolloCodegenConfiguration {
  /// Name used to scope the generated schema type files.
  @available(*, deprecated, renamed: "schemaNamespace")
  public var schemaName: String { schemaNamespace }

  /// Deprecated initializer - use `init(schemaNamespace:input:output:options:experimentalFeatures:schemaDownloadConfiguration:)`
  /// instead.
  ///
  /// - Parameters:
  ///  - schemaName: Name used to scope the generated schema type files.
  ///  - input: The input files required for code generation.
  ///  - output: The paths and files output by code generation.
  ///  - options: Rules and options to customize the generated code.
  ///  - experimentalFeatures: Allows users to enable experimental features.
  @available(*, deprecated, renamed: "init(schemaNamespace:input:output:options:experimentalFeatures:schemaDownloadConfiguration:)")
  public init(
    schemaName: String,
    input: FileInput,
    output: FileOutput,
    options: OutputOptions = Default.options,
    experimentalFeatures: ExperimentalFeatures = Default.experimentalFeatures,
    schemaDownloadConfiguration: ApolloSchemaDownloadConfiguration? = Default.schemaDownloadConfiguration
  ) {
    self.init(
      schemaNamespace: schemaName,
      input: input,
      output: output,
      options: options,
      experimentalFeatures: experimentalFeatures,
      schemaDownloadConfiguration: schemaDownloadConfiguration)
  }
}
