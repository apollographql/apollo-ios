import ApolloUtils

// MARK: TemplateRenderer

/// Defines the file target of the template.
enum TemplateTarget {
  /// Used in schema types files; enum, input object, union, etc.
  case schemaFile
  /// Used in operation files; query, mutation, fragment, etc.
  case operationFile
  /// Used in files that define a module; Swift Package Manager, etc.
  case moduleFile
  /// Used in test mock files; schema object `Mockable` extensions
  case testMockFile
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

  /// The swift code format.
  var template: TemplateString { get }
}

// MARK: Extensions

extension TemplateRenderer {

  var headerTemplate: TemplateString? { TemplateString(HeaderCommentTemplate.template.description) }

  /// Renders the template converting all input values and generating a final String representation
  /// of the template.
  ///
  /// - Parameter config: Shared codegen configuration.
  /// - Returns: Swift code derived from the template format.
  func render(forConfig config: ReferenceWrapped<ApolloCodegenConfiguration>) -> String {
    switch target {
    case .schemaFile: return renderSchemaFile(forConfig: config)
    case .operationFile: return renderOperationFile(forConfig: config)
    case .moduleFile: return renderModuleFile(forConfig: config)
    case .testMockFile: return renderTestMockFile(forConfig: config)
    }
  }

  private func renderSchemaFile(
    forConfig config: ReferenceWrapped<ApolloCodegenConfiguration>
  ) -> String {
    TemplateString(
    """
    \(ifLet: headerTemplate, { "\($0)\n" })
    \(ImportStatementTemplate.SchemaType.template)

    \(if: config.output.schemaTypes.isInModule, template,
    else: template.wrappedInNamespace(config.schemaName))
    """
    ).description
  }

  private func renderOperationFile(
    forConfig config: ReferenceWrapped<ApolloCodegenConfiguration>
  ) -> String {
    TemplateString(
    """
    \(ifLet: headerTemplate, { "\($0)\n" })
    \(ImportStatementTemplate.Operation.template(forConfig: config))

    \(if: config.output.operations.isInModule && !config.output.schemaTypes.isInModule,
      template.wrappedInNamespace(config.schemaName),
    else:
      template)
    """
    ).description
  }

  private func renderModuleFile(
    forConfig config: ReferenceWrapped<ApolloCodegenConfiguration>
  ) -> String {
    TemplateString(
    """
    \(ifLet: headerTemplate, { "\($0)\n" })
    \(template)
    """
    ).description
  }

  private func renderTestMockFile(
    forConfig config: ReferenceWrapped<ApolloCodegenConfiguration>
  ) -> String {
    TemplateString(
    """
    \(ifLet: headerTemplate, { "\($0)\n" })
    \(ImportStatementTemplate.TestMock.template(forConfig: config))
    
    """
    ).description
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
private struct HeaderCommentTemplate {
  static let template: StaticString =
    """
    // @generated
    // This file was automatically generated and should not be edited.
    """
}

// MARK: Import Statement Template

/// Provides the format to import Swift modules required by the template type.
private struct ImportStatementTemplate {
  static let template: StaticString =
    """
    import ApolloAPI
    """

  enum SchemaType {
    static let template: StaticString = ImportStatementTemplate.template
  }

  enum Operation {
    static func template(forConfig config: ReferenceWrapped<ApolloCodegenConfiguration>) -> TemplateString {
      """
      \(ImportStatementTemplate.template)
      \(if: shouldImportSchemaModule(config), "import \(config.schemaName.firstUppercased)")
      """
    }

    private static func shouldImportSchemaModule(
      _ config: ReferenceWrapped<ApolloCodegenConfiguration>
    ) -> Bool {
      config.output.operations != .inSchemaModule && config.output.schemaTypes.isInModule
    }
  }

  enum TestMock {
    static func template(forConfig config: ReferenceWrapped<ApolloCodegenConfiguration>) -> TemplateString {
      """
      import ApolloTestSupport
      \(if: config.output.schemaTypes.isInModule,
        "import \(config.output.schemaTypes.schemaName.firstUppercased)"
      )
      """
    }
  }
}
