import Foundation
import PathKit

/// A configuration object that defines behavior for code generation.
public struct ApolloCodegenConfiguration {
  /// The input paths and files required for code generation.
  public struct FileInput {
    /// Local path to the GraphQL schema file. Can be in JSON or SDL format.
    public let schemaPath: String
    /// Glob of files to search for GraphQL operations. This should be used to find queries and any client schema extensions.
    public let glob: String

    /// Designated initializer.
    ///
    /// - Parameters:
    ///  - schemaPath: Local path to the GraphQL schema file. Can be in JSON or SDL format.
    ///  - glob: Glob of files to search for GraphQL operations. This should be used to find queries and any client
    ///  schema extensions. Defaults to `./**/*.graphql`, which will search for `.graphql` files throughout all subfolders of
    ///  the folder where the script is run.
    public init(schemaPath: String, glob: String = "./**/*.graphql") {
      self.schemaPath = schemaPath
      self.glob = glob
    }
  }

  /// The paths and files output by code generation.
  public struct FileOutput {
    /// The local path structure for the generated schema types files.
    public let schemaTypes: SchemaTypesFileOutput
    /// The local path structure for the generated operation object files.
    public let operations: OperationsFileOutput
    /// An absolute location to an operation id JSON map file. If specified, also stores the operation IDs (hashes) as properties on
    /// operation types.
    public let operationIdentifiersPath: String?

    /// Designated initializer.
    ///
    /// - Parameters:
    ///  - schemaTypes: The local path structure for the generated schema types files.
    ///  - operations: The local path structure for the generated operation object files. Defaults to `.relative` with a
    ///  `subpath` of `nil`.
    ///  - operationIdentifiersPath: An absolute location to an operation id JSON map file. If specified, also stores the
    ///  operation IDs (hashes) as properties on operation types. Defaults to `nil`.
    public init(schemaTypes: SchemaTypesFileOutput,
                operations: OperationsFileOutput = .relative(subpath: nil),
                operationIdentifiersPath: String? = nil) {
      self.schemaTypes = schemaTypes
      self.operations = operations
      self.operationIdentifiersPath = operationIdentifiersPath
    }
  }

  /// The local path structure for the generated schema types files.
  public struct SchemaTypesFileOutput {
    /// Compatible dependency manager automation.
    public enum ModuleType {
      /// No module will be created for the generated schema types. Generated files must be manually added to the main application
      /// target. The generated files will be namespaced to prevent naming conflicts.
      ///
      /// - Parameters:
      ///  - namespace: The namespace to use for generated operation objects.
      case manuallyLinked(namespace: String)
      /// Generates a module with a podspec file that is suitable for linking to your project using CocoaPods.
      ///
      /// - Parameters:
      ///  - moduleName: The name for the new shared module that will be created.
      case cocoaPods(moduleName: String)
      /// Generates a module with a cartfile that is suitable for linking to your project using Carthage.
      ///
      /// - Parameters:
      ///  - moduleName: The name for the new shared module that will be created.
      case carthage(moduleName: String)
      /// Generates a module with a package.swift file that is suitable for linking to your project using Swift Package Manager
      ///
      /// - Parameters:
      ///  - moduleName: The name for the new shared module that will be created.
      case swiftPackageManager(moduleName: String)
    }

    /// Local path where the generated schema types files should be stored.
    public let path: String
    /// Automation to ease the integration of the generated schema types file with compatible dependency managers.
    public let dependencyAutomation: ModuleType

    /// Designated initializer.
    ///
    /// - Parameters:
    ///  - path: Local path where the generated schema types files should be stored.
    ///  - dependencyAutomation: Automation to ease the integration of the generated schema types file with compatible
    ///  dependency managers. Defaults to `.manuallyLinked` with a `namespace` of `"API"`.
    public init(path: String, dependencyAutomation: ModuleType = .manuallyLinked(namespace: "API")) {
      self.path = path
      self.dependencyAutomation = dependencyAutomation
    }
  }

  /// The local path structure for the generated operation object files.
  public enum OperationsFileOutput: Equatable {
    /// All operation object files will be located in the module with the schema types.
    case inSchemaModule
    /// Operation object files will be co-located relative to the defining operation `.graphql` file. If `subpath` is specified a subfolder
    /// will be created relative to the `.graphql` file and the operation object files will be generated there. If no `subpath` is
    /// defined then all operation object files will be generated alongside the `.graphql` file.
    case relative(subpath: String?)
    /// All operation object files will be located in the specified path.
    case absolute(path: String)
  }

  /// Specify the formatting of the GraphQL query string literal.
  public enum QueryStringLiteralFormat {
    /// The query string will be copied into the operation object with all line break formatting removed.
    case singleLine
    /// The query string will be copied with original formatting into the operation object.
    case multiline
  }

  public enum Composition {
    case include
    case exclude
  }

  /// Enum to select how to handle properties using a custom scalar from the schema.
  public enum CustomScalarFormat: Equatable {
    /// Uses the default type of String.
    case defaultAsString
    /// Use your own types for custom scalars. These will be taken from the associated schema.
    case passthrough
    /// Use your own types for custom scalars with a prefix.
    case passthroughWithPrefix(String)
  }

  /// The input files required for code generation.
  public let input: FileInput
  /// The paths and files output by code generation.
  public let output: FileOutput
  /// Any non-default rules for pluralization or singularization you wish to include.
  public let additionalInflectionRules: [InflectionRule]
  /// Formatting of the GraphQL query string literal that is included in each generated operation object.
  public let queryStringLiteralFormat: QueryStringLiteralFormat
  /// How to handle properties using a custom scalar from the schema.
  public let customScalarFormat: CustomScalarFormat
  /// How deprecated enum cases from the schema should be handled.
  public let deprecatedEnumCases: Composition
  /// Whether schema documentation is added to the generated files.
  public let schemaDocumentation: Composition

  /// Designated initializer.
  ///
  /// - Parameters:
  ///  - input: The input files required for code generation.
  ///  - output: The paths and files output by code generation.
  ///  - additionalInflectionRules: Any non-default rules for pluralization or singularization you wish to include. Defaults to
  ///  an empty array.
  ///  - queryStringLiteralFormat: Formatting of the GraphQL query string literal that is included in each generated operation
  ///  object. Defaults to `.multiline`.
  ///  - customScalarFormat: How to handle properties using a custom scalar from the schema. Defaults to `.defaultAsString`.
  ///  - deprecatedEnumCases: How deprecated enum cases from the schema should be handled. The default of `.include`
  ///  will cause the generated code to include the deprecated enum cases.
  ///  - schemaDocumentation: Whether schema documentation is added to the generated files. The default of `.include` will
  ///  cause the schema documentation comments to be copied over into the generated schema types files.
  public init(input: FileInput,
              output: FileOutput,
              additionalInflectionRules: [InflectionRule] = [],
              queryStringLiteralFormat: QueryStringLiteralFormat = .multiline,
              customScalarFormat: CustomScalarFormat = .defaultAsString,
              deprecatedEnumCases: Composition = .include,
              schemaDocumentation: Composition = .include) {
    self.input = input
    self.output = output
    self.additionalInflectionRules = additionalInflectionRules
    self.queryStringLiteralFormat = queryStringLiteralFormat
    self.customScalarFormat = customScalarFormat
    self.deprecatedEnumCases = deprecatedEnumCases
    self.schemaDocumentation = schemaDocumentation
  }

  /// Convenience initializer with all paths extended from a supplied base path.
  ///
  /// - Parameters:
  ///  - basePath:
  public init(basePath: String, schemaFilename: String = "schema.graphqls") {
    let schemaPath = Path(basePath) + schemaFilename

    self.init(input: .init(schemaPath: schemaPath.string),
              output: .init(schemaTypes: .init(path: basePath)))
  }
}
