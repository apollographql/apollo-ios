import ApolloUtils
import GitHubAPI

// MARK: TemplateRenderer

enum TemplateTarget {
  case schemaFile
  case operationFile
  case moduleFile
}

protocol TemplateRenderer {
  var target: TemplateTarget { get }
  var template: TemplateString { get }

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

