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
}

/// A protocol to handle the rendering of a file template based on the target file type and
/// codegen configuration.
///
/// All templates that output to a file should conform to this protocol, this does not include
/// templates that are used by others such as `HeaderCommentTemplate` or `ImportStatementTemplate`.
protocol TemplateRenderer {
  /// File target of the template.
  var target: TemplateTarget { get }
  /// The swift code format.
  var template: TemplateString { get }

  /// Renders the template converting all input values and generating a final String representation
  /// of the template.
  ///
  /// - Parameter config: Shared codegen configuration.
  /// - Returns: Swift code derived from the template format.
  func render(forConfig config: ReferenceWrapped<ApolloCodegenConfiguration>) -> String
}

// MARK: Extensions

extension TemplateRenderer {
  func render(forConfig config: ReferenceWrapped<ApolloCodegenConfiguration>) -> String {
    switch target {
    case .schemaFile: return renderSchemaFile(forConfig: config)
    case .operationFile: return renderOperationFile(forConfig: config)
    case .moduleFile: return renderModuleFile(forConfig: config)
    }
  }

  private func renderSchemaFile(
    forConfig config: ReferenceWrapped<ApolloCodegenConfiguration>
  ) -> String {
    TemplateString(
    """
    \(HeaderCommentTemplate.template)

    \(ImportStatementTemplate.SchemaType.template)

    \(if: config.output.schemaTypes.isInModule, template,
    else: template.wrappedInNamespace(config.output.schemaTypes.schemaName))
    """
    ).description
  }

  private func renderOperationFile(
    forConfig config: ReferenceWrapped<ApolloCodegenConfiguration>
  ) -> String {
    TemplateString(
    """
    \(HeaderCommentTemplate.template)

    \(ImportStatementTemplate.Operation.template(forConfig: config))

    \(if: config.output.operations.isInModule && !config.output.schemaTypes.isInModule,
      template.wrappedInNamespace(config.output.schemaTypes.schemaName),
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
    \(if: !config.output.schemaTypes.isInModule, """
    \(HeaderCommentTemplate.template)

    """)
    \(template)
    """
    ).description
  }
}

extension TemplateString {
  /// Wraps `namespace` in a public `enum` extension.
  fileprivate func wrappedInNamespace(_ namespace: String) -> Self {
    TemplateString(
    """
    public extension \(namespace) {
      \(self)
    }
    """
    )
  }
}

