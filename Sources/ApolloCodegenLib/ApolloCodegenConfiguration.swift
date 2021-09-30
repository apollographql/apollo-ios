import Foundation

/// A configuration object that defines behavior for code generation.
public struct ApolloCodegenConfiguration {
  /// Specify the input files required for code generation.
  public struct FileInput {
    /// Path to the GraphQL schema file. Can be in JSON or SDL format.
    public let schema: URL
    /// Glob of files to search for GraphQL operations. This should be used to find queries and any client schema extensions. Defaults to `./**/*.graphql`, which will search for `.graphql` files throughout all subfolders of the folder where the script is run.
    public let glob: String
  }

  /// Configure the folder structure of the generated files.
  public struct FileOutput {
    /// The location structure for the schema types files.
    public let schemaTypes: SchemaTypesFileOutput
    /// The location structure for the operation object files.
    public let operations: OperationsFileOutput
    /// [optional] Path to an operation id JSON map file. If specified, also stores the operation IDs (hashes) as properties on operation
    /// types. Defaults to `nil`.
    public let operationIDs: URL?
  }

  /// Defines the location structure for the schema types files.
  public struct SchemaTypesFileOutput {
    /// Compatible dependency manager automation.
    public enum DependencyManagerAutomation {
      /// No automation. The generated schema types files must be manually added to the main application target.
      case includedInTarget
      /// Generate a podspec file.
      case cocoaPods
      /// Generate a cartfile.
      case carthage
      /// Generate a package.swift file.
      case swiftPackageManager
    }

    /// The namespace to use for generated operation objects. When combined with `.includedInTarget` this should be the main target name. When used with any other dependency manager this should be the name of the new shared module that will be created.
    public let name: String
    /// An absolute location where the schema types files should be generated.
    public let url: URL
    /// Automation to ease the integration of the generated schema types file with compatible dependency managers.
    public let dependencyAutomation: DependencyManagerAutomation
  }

  /// Defines the location structure for the operation object files.
  public enum OperationsFileOutput {
    /// All operation object files will be located in the module with the schema types.
    case inSchemaModule
    /// Operation object files will be co-located relative to the defining `.graphql` file.
    case relative(subpath: String?)
    /// All operation object files will be located in the specified path.
    case absolute(url: URL)
  }

  /// Specify the formatting of the GraphQL query string literal.
  public enum GraphQLQueryStringLiteralFormat {
    /// The query string will be copied into the operation object with all line break formatting removed.
    case singleLine
    /// The query string will be copied with original formatting into the operation object.
    case multiline
    /// The query string will not be copied into the operation object. You must be using preregisterd queries with this configuration.
    case exclude
  }

  public enum CompositionOption {
    case include
    case exclude
  }

  /// Enum to select how to handle properties using a custom scalar from the schema.
  public enum CustomScalarFormat: Equatable {
    /// Uses the default type of String.
    case defaultAsString
    /// Use your own types for custom scalars.
    case passthrough
    /// Use your own types for custom scalars with a prefix.
    case passthroughWithPrefix(String)
  }

  /// Specify the input files required for code generation.
  public let input: FileInput
  /// Define the folder structure of the output files.
  public let output: FileOutput
  /// Any non-default rules for pluralization or singularization you wish to include. Defaults to an empty array.
  public let additionalInflectionRules: [InflectionRule]
  /// Formatting of the GraphQL query string literal that is included in each generated operation object. Defaults to `.multiline`.
  public let graphqlQueryStringLiteralFormat: GraphQLQueryStringLiteralFormat
  /// How to handle properties using a custom scalar from the schema. Defaults to `.defaultAsString`.
  public let customScalarFormat: CustomScalarFormat
  /// How deprecated enum cases should be handled in generated code. Defaults to `.include`.
  public let deprecatedEnumCases: CompositionOption
  /// Specifies whether schema documentation is copied into the generated file. Defaults to `.include`.
  public let schemaDocumentation: CompositionOption

  /// Designated initializer.
  ///
  /// - Parameters:
  ///  - input: Specify the input files required for code generation.
  ///  - output: Define the folder structure of the output files.
  ///  - additionalInflectionRules: Any non-default rules for pluralization or singularization you wish to include. Defaults to an empty array.
  ///  - graphqlQueryStringLiterals: Formatting of the GraphQL query string literal that is included in each generated operation object. Defaults to `.multiline`.
  ///  - customScalarFormat: How to handle properties using a custom scalar from the schema. Defaults to `.defaultAsString`.
  ///  - deprecatedEnumCases: How deprecated enum cases should be handled in generated code. Defaults to `.include`.
  ///  - schemaDocumentation: Specifies whether schema documentation is copied into the generated file. Defaults to `.include`.
  public init(input: FileInput,
              output: FileOutput,
              additionalInflectionRules: [InflectionRule] = [],
              graphqlQueryStringLiteralFormat: GraphQLQueryStringLiteralFormat = .multiline,
              customScalarFormat: CustomScalarFormat = .defaultAsString,
              deprecatedEnumCases: CompositionOption = .include,
              schemaDocumentation: CompositionOption = .include) {
    self.input = input
    self.output = output
    self.additionalInflectionRules = additionalInflectionRules
    self.graphqlQueryStringLiteralFormat = graphqlQueryStringLiteralFormat
    self.customScalarFormat = customScalarFormat
    self.deprecatedEnumCases = deprecatedEnumCases
    self.schemaDocumentation = schemaDocumentation
  }

  /// Convenience initializer with default values designed to work with a default `ApolloSchemaDownloadConfiguration` instance.
  ///
  /// - Parameters:
  ///  - inputFolderURL: A folder containing the GraphQL schema file.
  ///  - schemaFilename: The filename of the GraphQL schema file without extension. Defaults to "schema" which is the default output filename of `ApolloSchemaDownloadConfiguration`.
  ///  - outputFolderURL: A folder for all generated files. This will include schema types and operation objects.
  ///  - applicationTarget: The name of your application target. This will be used to namespace the generated objects.
  public init(inputFolderURL: URL,
              schemaFilename: String = "schema",
              outputFolderURL: URL,
              applicationTarget: String) {
    let schemaURL = inputFolderURL.appendingPathComponent("\(schemaFilename).graphqls")
    let input = FileInput(schema: schemaURL, glob: "./**/*.graphql")

    let schemaTypesOutput = SchemaTypesFileOutput(name: applicationTarget, url: outputFolderURL, dependencyAutomation: .includedInTarget)
    let output = FileOutput(schemaTypes: schemaTypesOutput,
                            operations: .absolute(url: outputFolderURL),
                            operationIDs: nil)

    self.init(input: input, output: output)
  }
}
