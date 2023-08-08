import Foundation
import OrderedCollections

// Only available on macOS
#if os(macOS)

/// A class to facilitate running code generation
public class ApolloCodegen {

  // MARK: Public

  /// Errors that can occur during code generation.
  public enum Error: Swift.Error, LocalizedError {
    /// An error occured during validation of the GraphQL schema or operations.
    case graphQLSourceValidationFailure(atLines: [String])
    case testMocksInvalidSwiftPackageConfiguration
    case inputSearchPathInvalid(path: String)
    case schemaNameConflict(name: String)
    case cannotLoadSchema
    case cannotLoadOperations
    case invalidConfiguration(message: String)
    case invalidSchemaName(_ name: String, message: String)
    case targetNameConflict(name: String)
    case typeNameConflict(name: String, conflictingName: String, containingObject: String)

    public var errorDescription: String? {
      switch self {
      case let .graphQLSourceValidationFailure(lines):
        return """
          An error occured during validation of the GraphQL schema or operations! Check \(lines)
          """
      case .testMocksInvalidSwiftPackageConfiguration:
        return """
          Schema Types must be generated with module type 'swiftPackageManager' to generate a \
          swift package for test mocks.
          """
      case let .inputSearchPathInvalid(path):
        return """
          Input search path '\(path)' is invalid. Input search paths must include a file \
          extension component. (eg. '.graphql')
          """
      case let .schemaNameConflict(name):
        return """
          Schema namespace '\(name)' conflicts with name of a type in the generated code. Please \
          choose a different schema name. Suggestions: \(name)Schema, \(name)GraphQL, \(name)API.
          """
      case .cannotLoadSchema:
        return "A GraphQL schema could not be found. Please verify the schema search paths."
      case .cannotLoadOperations:
        return "No GraphQL operations could be found. Please verify the operation search paths."
      case let .invalidConfiguration(message):
        return "The codegen configuration has conflicting values: \(message)"
      case let .invalidSchemaName(name, message):
        return "The schema namespace `\(name)` is invalid: \(message)"
      case let .targetNameConflict(name):
        return """
        Target name '\(name)' conflicts with a reserved library name. Please choose a different \
        target name.
        """
      case let .typeNameConflict(name, conflictingName, containingObject):
        return """
        TypeNameConflict - \
        Field '\(conflictingName)' conflicts with field '\(name)' in operation/fragment `\(containingObject)`. \
        Recommend using a field alias for one of these fields to resolve this conflict. \
        For more info see: https://www.apollographql.com/docs/ios/troubleshooting/codegen-troubleshooting#typenameconflict
        """
      }
    }
  }
  
  public struct ItemsToGenerate: OptionSet {
    public var rawValue: Int
    
    public static let code = ItemsToGenerate(rawValue: 1 << 0)
    public static let operationManifest = ItemsToGenerate(rawValue: 1 << 1)
    public static let all: ItemsToGenerate = [
      .code,
      .operationManifest
    ]
    
    public init(rawValue: Int) {
      self.rawValue = rawValue
    }
    
  }

  /// Executes the code generation engine with a specified configuration.
  ///
  /// - Parameters:
  ///   - configuration: A configuration object that specifies inputs, outputs and behaviours used
  ///     during code generation.
  ///   - rootURL: The root `URL` to resolve relative `URL`s in the configuration's paths against.
  ///     If `nil`, the current working directory of the executing process will be used.
  public static func build(
    with configuration: ApolloCodegenConfiguration,
    withRootURL rootURL: URL? = nil,
    itemsToGenerate: ItemsToGenerate = [.code]
  ) throws {
    try build(with: configuration, rootURL: rootURL, itemsToGenerate: itemsToGenerate)
  }

  internal static func build(
    with configuration: ApolloCodegenConfiguration,
    rootURL: URL? = nil,
    fileManager: ApolloFileManager = .default,
    itemsToGenerate: ItemsToGenerate
  ) throws {

    let configContext = ConfigurationContext(
      config: configuration,
      rootURL: rootURL
    )

    try validate(configContext)

    let compilationResult = try compileGraphQLResult(
      configContext,
      experimentalFeatures: configuration.experimentalFeatures
    )

    try validate(configContext, with: compilationResult)

    let ir = IR(compilationResult: compilationResult)
    
    if itemsToGenerate.contains(.operationManifest) {
      var operationIDsFileGenerator = OperationManifestFileGenerator(config: configContext)
      
      for operation in compilationResult.operations {
        autoreleasepool {
          let irOperation = ir.build(operation: operation)
          operationIDsFileGenerator?.collectOperationIdentifier(irOperation)
        }
      }
      
      try operationIDsFileGenerator?.generate(fileManager: fileManager)
    }

    if itemsToGenerate.contains(.code) {
      var existingGeneratedFilePaths = configuration.options.pruneGeneratedFiles ?
      try findExistingGeneratedFilePaths(
        config: configContext,
        fileManager: fileManager
      ) : []

      try generateFiles(
        compilationResult: compilationResult,
        ir: ir,
        config: configContext,
        fileManager: fileManager,
        itemsToGenerate: itemsToGenerate
      )

      if configuration.options.pruneGeneratedFiles {
        try deleteExtraneousGeneratedFiles(
          from: &existingGeneratedFilePaths,
          afterCodeGenerationUsing: fileManager
        )
      }
    }
  }

  // MARK: Internal

  @dynamicMemberLookup
  class ConfigurationContext {
    let config: ApolloCodegenConfiguration
    let pluralizer: Pluralizer
    let rootURL: URL?

    init(
      config: ApolloCodegenConfiguration,
      rootURL: URL? = nil
    ) {
      self.config = config
      self.pluralizer = Pluralizer(rules: config.options.additionalInflectionRules)
      self.rootURL = rootURL?.standardizedFileURL
    }

    subscript<T>(dynamicMember keyPath: KeyPath<ApolloCodegenConfiguration, T>) -> T {
      config[keyPath: keyPath]
    }
  }

  /// Validates the configuration against deterministic errors that will cause code generation to
  /// fail. This validation step does not take into account schema and operation specific types, it
  /// is only a static analysis of the configuration.
  ///
  /// - Parameter config: Code generation configuration settings.
  public static func _validate(config: ApolloCodegenConfiguration) throws {
    try validate(ConfigurationContext(config: config))
  }

  static private func validate(_ context: ConfigurationContext) throws {
    guard
      !context.schemaNamespace.isEmpty,
      !context.schemaNamespace.contains(where: { $0.isWhitespace })
    else {
      throw Error.invalidSchemaName(context.schemaNamespace, message: """
        Cannot be empty nor contain spaces. If your schema namespace has spaces consider \
        replacing them with the underscore character.
        """)
    }

    guard
      !SwiftKeywords.DisallowedSchemaNamespaceNames.contains(context.schemaNamespace.lowercased())
    else {
      throw Error.schemaNameConflict(name: context.schemaNamespace)
    }

    if case .swiftPackage = context.output.testMocks,
        context.output.schemaTypes.moduleType != .swiftPackageManager {
      throw Error.testMocksInvalidSwiftPackageConfiguration
    }

    if case .swiftPackageManager = context.output.schemaTypes.moduleType,
       context.options.cocoapodsCompatibleImportStatements == true {
      throw Error.invalidConfiguration(message: """
        cocoapodsCompatibleImportStatements cannot be set to 'true' when the output schema types \
        module type is Swift Package Manager. Change the cocoapodsCompatibleImportStatements \
        value to 'false', or choose a different module type, to resolve the conflict.
        """)
    }
    
    if case let .embeddedInTarget(targetName, _) = context.output.schemaTypes.moduleType,
       SwiftKeywords.DisallowedEmbeddedTargetNames.contains(targetName.lowercased()) {
      throw Error.targetNameConflict(name: targetName)
    }

    for searchPath in context.input.schemaSearchPaths {
      try validate(inputSearchPath: searchPath)
    }
    for searchPath in context.input.operationSearchPaths {
      try validate(inputSearchPath: searchPath)
    }
  }

  static private func validate(inputSearchPath: String) throws {
    guard inputSearchPath.contains(".") && !inputSearchPath.hasSuffix(".") else {
      throw Error.inputSearchPathInvalid(path: inputSearchPath)
    }
  }

  /// Validates the configuration context against the GraphQL compilation result, checking for
  /// configuration errors that are dependent on the schema and operations.
  static func validate(_ context: ConfigurationContext, with compilationResult: CompilationResult) throws {
    guard
      !compilationResult.referencedTypes.contains(where: { namedType in
        namedType.swiftName == context.schemaNamespace.firstUppercased
      }),
      !compilationResult.fragments.contains(where: { fragmentDefinition in
        fragmentDefinition.name == context.schemaNamespace.firstUppercased
      })
    else {
      throw Error.schemaNameConflict(name: context.schemaNamespace)
    }
  }
  
  /// Validates that there are no type conflicts within a SelectionSet
  static private func validateTypeConflicts(
    for selectionSet: IR.SelectionSet,
    with context: ConfigurationContext,
    in containingObject: String,
    including parentTypes: [String: String] = [:]
  ) throws {
    // Check for type conflicts resulting from singularization/pluralization of fields
    var typeNamesByFormattedTypeName = [String: String]()
    
    var fields: [IR.EntityField] = selectionSet.selections.direct?.fields.values.compactMap { $0 as? IR.EntityField } ?? []
    fields.append(contentsOf: selectionSet.selections.merged.fields.values.compactMap { $0 as? IR.EntityField } )

    try fields.forEach { field in
      let formattedTypeName = field.formattedSelectionSetName(with: context.pluralizer)
      if let existingFieldName = typeNamesByFormattedTypeName[formattedTypeName] {
        throw Error.typeNameConflict(
          name: existingFieldName,
          conflictingName: field.name,
          containingObject: containingObject
        )
      }
      typeNamesByFormattedTypeName[formattedTypeName] = field.name
    }
    
    // Combine `parentTypes` and `typeNamesByFormattedTypeName` to check against fragment names and
    // pass into recursive function calls
    var combinedTypeNames = parentTypes
    combinedTypeNames.merge(typeNamesByFormattedTypeName) { (current, _) in current }
    
    // passing each fields selection set for validation after we have fully built our `typeNamesByFormattedTypeName` dictionary
    try fields.forEach { field in
      try validateTypeConflicts(
        for: field.selectionSet,
        with: context,
        in: containingObject,
        including: combinedTypeNames
      )
    }
    
    var namedFragments: [IR.NamedFragment] = selectionSet.selections.direct?.namedFragments.values.map(\.fragment) ?? []
    namedFragments.append(contentsOf: selectionSet.selections.merged.namedFragments.values.map(\.fragment))
    
    try namedFragments.forEach { fragment in
      if let existingTypeName = combinedTypeNames[fragment.generatedDefinitionName] {
        throw Error.typeNameConflict(
          name: existingTypeName,
          conflictingName: fragment.name,
          containingObject: containingObject
        )
      }
    }
    
    // gather nested fragments to loop through and check as well    
    var nestedSelectionSets: [IR.SelectionSet] = selectionSet.selections.direct?.inlineFragments.values.map(\.selectionSet) ?? []
    nestedSelectionSets.append(contentsOf: selectionSet.selections.merged.inlineFragments.values.map(\.selectionSet))
    
    try nestedSelectionSets.forEach { nestedSet in
      try validateTypeConflicts(
        for: nestedSet,
        with: context,
        in: containingObject,
        including: combinedTypeNames
      )
    }
  }

  /// Performs GraphQL source validation and compiles the schema and operation source documents.
  static func compileGraphQLResult(
    _ config: ConfigurationContext,
    experimentalFeatures: ApolloCodegenConfiguration.ExperimentalFeatures = .init()
  ) throws -> CompilationResult {
    let frontend = try GraphQLJSFrontend()
    let graphQLSchema = try createSchema(config, frontend)
    let operationsDocument = try createOperationsDocument(config, frontend, experimentalFeatures)
    let validationOptions = ValidationOptions(config: config)

    let graphqlErrors = try frontend.validateDocument(
      schema: graphQLSchema,
      document: operationsDocument,
      validationOptions: validationOptions
    )

    guard graphqlErrors.isEmpty else {
      let errorlines = graphqlErrors.flatMap({
        if let logLines = $0.logLines {
          return logLines
        } else {
          return ["\($0.name ?? "unknown"): \($0.message ?? "")"]
        }
      })
      CodegenLogger.log(errorlines.joined(separator: "\n"), logLevel: .error)
      throw Error.graphQLSourceValidationFailure(atLines: errorlines)
    }

    return try frontend.compile(
      schema: graphQLSchema,
      document: operationsDocument,
      experimentalLegacySafelistingCompatibleOperations: experimentalFeatures.legacySafelistingCompatibleOperations,
      validationOptions: validationOptions
    )
  }

  static func createSchema(
    _ config: ConfigurationContext,
    _ frontend: GraphQLJSFrontend
  ) throws -> GraphQLSchema {

    let matches = try match(
      searchPaths: config.input.schemaSearchPaths,
      relativeTo: config.rootURL
    )

    guard !matches.isEmpty else {
      throw Error.cannotLoadSchema
    }

    let sources = try matches.map { try frontend.makeSource(from: URL(fileURLWithPath: $0)) }
    return try frontend.loadSchema(from: sources)
  }

  static func createOperationsDocument(
    _ config: ConfigurationContext,
    _ frontend: GraphQLJSFrontend,
    _ experimentalFeatures: ApolloCodegenConfiguration.ExperimentalFeatures
  ) throws -> GraphQLDocument {

    let matches = try match(
      searchPaths: config.input.operationSearchPaths,
      relativeTo: config.rootURL)

    guard !matches.isEmpty else {
      throw Error.cannotLoadOperations
    }

    let documents = try matches.map({ path in
      return try frontend.parseDocument(
        from: URL(fileURLWithPath: path),
        experimentalClientControlledNullability: experimentalFeatures.clientControlledNullability
      )
    })
    return try frontend.mergeDocuments(documents)
  }

  static func match(searchPaths: [String], relativeTo relativeURL: URL?) throws -> OrderedSet<String> {
    let excludedDirectories = [
      ".build",
      ".swiftpm",
      ".Pods"]

    return try Glob(searchPaths, relativeTo: relativeURL)
      .match(excludingDirectories: excludedDirectories)
  }

  /// Generates Swift files for the compiled schema, ir and configured output structure.
  static func generateFiles(
    compilationResult: CompilationResult,
    ir: IR,
    config: ConfigurationContext,
    fileManager: ApolloFileManager = .default,
    itemsToGenerate: ItemsToGenerate
  ) throws {
    for fragment in compilationResult.fragments {
      try autoreleasepool {
        let irFragment = ir.build(fragment: fragment)
        try validateTypeConflicts(for: irFragment.rootField.selectionSet, with: config, in: irFragment.definition.name)
        try FragmentFileGenerator(irFragment: irFragment, config: config)
          .generate(forConfig: config, fileManager: fileManager)
      }
    }

    var operationIDsFileGenerator = OperationManifestFileGenerator(config: config)

    for operation in compilationResult.operations {
      try autoreleasepool {
        let irOperation = ir.build(operation: operation)
        try validateTypeConflicts(for: irOperation.rootField.selectionSet, with: config, in: irOperation.definition.name)
        try OperationFileGenerator(irOperation: irOperation, config: config)
          .generate(forConfig: config, fileManager: fileManager)

        if itemsToGenerate.contains(.operationManifest) {
          operationIDsFileGenerator?.collectOperationIdentifier(irOperation)
        }
      }
    }

    if itemsToGenerate.contains(.operationManifest) {
      try operationIDsFileGenerator?.generate(fileManager: fileManager)
    }
    operationIDsFileGenerator = nil

    for graphQLObject in ir.schema.referencedTypes.objects {
      try autoreleasepool {
        try ObjectFileGenerator(
          graphqlObject: graphQLObject,
          config: config
        ).generate(
          forConfig: config,
          fileManager: fileManager
        )

        if config.output.testMocks != .none {
          try MockObjectFileGenerator(
            graphqlObject: graphQLObject,
            ir: ir,
            config: config
          ).generate(
            forConfig: config,
            fileManager: fileManager
          )
        }
      }
    }

    for graphQLEnum in ir.schema.referencedTypes.enums {
      try autoreleasepool {
        try EnumFileGenerator(graphqlEnum: graphQLEnum, config: config)
          .generate(forConfig: config, fileManager: fileManager)
      }
    }

    for graphQLInterface in ir.schema.referencedTypes.interfaces {
      try autoreleasepool {
        try InterfaceFileGenerator(graphqlInterface: graphQLInterface, config: config)
          .generate(forConfig: config, fileManager: fileManager)
      }
    }

    for graphQLUnion in ir.schema.referencedTypes.unions {
      try autoreleasepool {
        try UnionFileGenerator(
          graphqlUnion: graphQLUnion,
          config: config
        ).generate(
          forConfig: config,
          fileManager: fileManager
        )
      }
    }

    for graphQLInputObject in ir.schema.referencedTypes.inputObjects {
      try autoreleasepool {
        try InputObjectFileGenerator(
          graphqlInputObject: graphQLInputObject,
          config: config
        ).generate(
          forConfig: config,
          fileManager: fileManager
        )
      }
    }

    for graphQLScalar in ir.schema.referencedTypes.customScalars {
      try autoreleasepool {
        try CustomScalarFileGenerator(graphqlScalar: graphQLScalar, config: config)
          .generate(forConfig: config, fileManager: fileManager)
      }
    }

    if config.output.testMocks != .none {
      try MockUnionsFileGenerator(
        ir: ir,
        config: config
      )?.generate(
        forConfig: config,
        fileManager: fileManager
      )
      try MockInterfacesFileGenerator(
        ir: ir,
        config: config
      )?.generate(
        forConfig: config,
        fileManager: fileManager
      )
    }

    try SchemaMetadataFileGenerator(schema: ir.schema, config: config)
      .generate(forConfig: config, fileManager: fileManager)
    try SchemaConfigurationFileGenerator(config: config)
      .generate(forConfig: config, fileManager: fileManager)

    try SchemaModuleFileGenerator.generate(config, fileManager: fileManager)
  }

  private static func findExistingGeneratedFilePaths(
    config: ConfigurationContext,
    fileManager: ApolloFileManager = .default
  ) throws -> Set<String> {
    var globs: [Glob] = []
    globs.append(Glob(
      ["\(config.output.schemaTypes.path)/**/*.graphql.swift"],
      relativeTo: config.rootURL
    ))

    switch config.output.operations {
    case .inSchemaModule: break

    case let .absolute(operationsPath, _):
      globs.append(Glob(
        ["\(operationsPath)/**/*.graphql.swift"],
        relativeTo: config.rootURL
      ))

    case let .relative(subpath, _):
      let searchPaths = config.input.operationSearchPaths.map { searchPath -> String in
        let startOfLastPathComponent = searchPath.lastIndex(of: "/") ?? searchPath.firstIndex(of: ".")!
        var path = searchPath.prefix(upTo: startOfLastPathComponent)
        if let subpath = subpath {
          path += "/\(subpath)"
        }
        path += "/*.graphql.swift"
        return path.description
      }

      globs.append(Glob(
        searchPaths,
        relativeTo: config.rootURL
      ))
    }

    switch config.output.testMocks {
    case let .absolute(testMocksPath, _):
      globs.append(Glob(
        ["\(testMocksPath)/**/*.graphql.swift"],
        relativeTo: config.rootURL
      ))
    default: break
    }

    return try globs.reduce(into: []) { partialResult, glob in
      partialResult.formUnion(try glob.match())
    }
  }

  static func deleteExtraneousGeneratedFiles(
    from oldGeneratedFilePaths: inout Set<String>,
    afterCodeGenerationUsing fileManager: ApolloFileManager
  ) throws {
    oldGeneratedFilePaths.subtract(fileManager.writtenFiles)
    for path in oldGeneratedFilePaths {
      try fileManager.deleteFile(atPath: path)
    }
  }

}

#endif
