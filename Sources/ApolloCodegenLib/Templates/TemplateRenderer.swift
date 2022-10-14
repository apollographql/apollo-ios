// MARK: TemplateRenderer

/// Defines the file target of the template.
enum TemplateTarget: Equatable {
  /// Used in schema types files; enum, input object, union, etc.
  case schemaFile(type: SchemaFileType)
  /// Used in operation files; query, mutation, fragment, etc.
  case operationFile
  /// Used in files that define a module; Swift Package Manager, etc.
  case moduleFile
  /// Used in test mock files; schema object `Mockable` extensions
  case testMockFile

  enum SchemaFileType: Equatable {
    case schemaMetadata
    case schemaConfiguration
    case object
    case interface
    case union
    case `enum`
    case customScalar
    case inputObject

    var namespaceComponent: String? {      
      switch self {
      case .schemaMetadata, .enum, .customScalar, .inputObject, .schemaConfiguration:
        return nil
      case .object:
        return "Objects"
      case .interface:
        return "Interfaces"
      case .union:
        return "Unions"
      }
    }
  }
}

/// A protocol to handle the rendering of a file template based on the target file type and
/// codegen configuration.
///
/// All templates that output to a file should conform to this protocol, this does not include
/// templates that are used by others such as `HeaderCommentTemplate` or `ImportStatementTemplate`.
protocol TemplateRenderer {
  /// File target of the template.
  var target: TemplateTarget { get }
  /// The template for the header to render.
  var headerTemplate: TemplateString? { get }
  /// A template that must be rendered outside of any namespace wrapping.
  var detachedTemplate: TemplateString? { get }
  /// A template that can be rendered within any namespace wrapping.
  var template: TemplateString { get }
  /// Shared codegen configuration.
  var config: ApolloCodegen.ConfigurationContext { get }
}

// MARK: Extensions

extension TemplateRenderer {

  var headerTemplate: TemplateString? {
    TemplateString(HeaderCommentTemplate.template.description)
  }

  var detachedTemplate: TemplateString? { nil }

  /// Renders the template converting all input values and generating a final String
  /// representation of the template.
  ///
  /// - Parameter config: Shared codegen configuration.
  /// - Returns: Swift code derived from the template format.
  func render() -> String {
    switch target {
    case let .schemaFile(type): return renderSchemaFile(type)
    case .operationFile: return renderOperationFile()
    case .moduleFile: return renderModuleFile()
    case .testMockFile: return renderTestMockFile()
    }
  }

  private func renderSchemaFile(_ type: TemplateTarget.SchemaFileType) -> String {
    let namespace: String? = {
      if case .schemaConfiguration = type {
        return nil
      }

      let useSchemaNamespace = !config.output.schemaTypes.isInModule
      switch (useSchemaNamespace, type.namespaceComponent) {
      case (false, nil):
        return nil
      case (true, nil):
        return config.schemaName
      case let (false, .some(schemaTypeNamespace)):
        return schemaTypeNamespace
      case let (true, .some(schemaTypeNamespace)):
        return "\(config.schemaName).\(schemaTypeNamespace)"
      }
    }()

    return TemplateString(
    """
    \(ifLet: headerTemplate, { "\($0)\n" })
    \(ImportStatementTemplate.SchemaType.template(for: config))

    \(ifLet: detachedTemplate, { "\($0)\n" })
    \(ifLet: namespace, template.wrappedInNamespace(_:), else: template)
    """
    ).description
  }

  private func renderOperationFile() -> String {
    TemplateString(
    """
    \(ifLet: headerTemplate, { "\($0)\n" })
    \(ImportStatementTemplate.Operation.template(for: config))

    \(if: config.output.operations.isInModule && !config.output.schemaTypes.isInModule,
      template.wrappedInNamespace(config.schemaName),
    else:
      template)
    """
    ).description
  }

  private func renderModuleFile() -> String {
    TemplateString(
    """
    \(ifLet: headerTemplate, { "\($0)\n" })
    \(template)
    """
    ).description
  }

  private func renderTestMockFile() -> String {
    TemplateString(
    """
    \(ifLet: headerTemplate, { "\($0)\n" })
    \(ImportStatementTemplate.TestMock.template(for: config))

    \(template)
    """
    ).description
  }

  var embeddedAccessControlModifier: String {
    guard config.output.schemaTypes.isInModule else { return "" }

    return "public "
  }
}

extension TemplateString {
  /// Wraps `namespace` in a public `enum` extension.
  fileprivate func wrappedInNamespace(_ namespace: String) -> Self {
    TemplateString(
    """
    public extension \(namespace.firstUppercased) {
      \(self)
    }
    """
    )
  }
}

// MARK: - Header Comment Template

/// Provides the format to identify a file as automatically generated.
struct HeaderCommentTemplate {
  static let template: StaticString =
    """
    // @generated
    // This file was automatically generated and should not be edited.
    """

  static func editableFileHeader(fileCanBeEditedTo reason: TemplateString) -> TemplateString {
    """
    // @generated
    // This file was automatically generated and can be edited to
    \(comment: reason.description)
    //
    // Any changes to this file will not be overwritten by future
    // code generation execution.
    """
  }
}

// MARK: Import Statement Template

/// Provides the format to import Swift modules required by the template type.
struct ImportStatementTemplate {

  enum SchemaType {
    static func template(
      for config: ApolloCodegen.ConfigurationContext
    ) -> String {
      "import \(config.ApolloAPITargetName)"
    }
  }

  enum Operation {
    static func template(
      for config: ApolloCodegen.ConfigurationContext
    ) -> TemplateString {
      let apolloAPITargetName = config.ApolloAPITargetName
      return """
      import \(apolloAPITargetName)
      @_exported import enum \(apolloAPITargetName).GraphQLEnum
      @_exported import enum \(apolloAPITargetName).GraphQLNullable
      \(if: config.output.operations != .inSchemaModule, "import \(config.schemaModuleName)")
      """
    }
  }

  enum TestMock {
    static func template(for config: ApolloCodegen.ConfigurationContext) -> TemplateString {
      return """
      import \(config.options.cocoapodsCompatibleImportStatements ? "Apollo" : "ApolloTestSupport")
      import \(config.schemaModuleName)
      """
    }
  }
}

fileprivate extension ApolloCodegenConfiguration {
  var schemaModuleName: String {
    switch output.schemaTypes.moduleType {
    case let .embeddedInTarget(targetName): return targetName
    case .swiftPackageManager, .other: return schemaName.firstUppercased
    }
  }
}
