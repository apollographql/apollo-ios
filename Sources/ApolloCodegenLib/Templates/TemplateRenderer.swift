import ApolloUtils

protocol TemplateRenderer {
  var template: TemplateString { get }

  func render(forConfig config: ReferenceWrapped<ApolloCodegenConfiguration>) -> String
}

extension TemplateRenderer {
  func render(forConfig config: ReferenceWrapped<ApolloCodegenConfiguration>) -> String {
    if config.value.output.schemaTypes.isModule {
      return render()

    } else {
      return render(wrappedInNamespace: config.value.output.schemaTypes.schemaName)
    }
  }

  private func render() -> String {
    TemplateString(
    """
    \(HeaderCommentTemplate.render())

    \(ImportStatementTemplate.SchemaType.render())

    \(template)
    """
    ).description

  }

  private func render(wrappedInNamespace namespace: String) -> String {
    TemplateString(
    """
    \(HeaderCommentTemplate.render())

    \(ImportStatementTemplate.SchemaType.render())

    \(template.wrappedInNamespace(namespace))
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

extension ApolloCodegenConfiguration.SchemaTypesFileOutput {
  fileprivate var isModule: Bool {
    switch moduleType {
    case .swiftPackageManager, .other: return true
    case .none: return false
    }
  }
}
