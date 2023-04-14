extension IR.Definition {

  func renderedSelectionSetType(_ config: ApolloCodegen.ConfigurationContext) -> TemplateString {
    "\(config.schemaNamespace.firstUppercased).\(if: isMutable, "Mutable")SelectionSet"
  }

  var isMutable: Bool {
    switch self {
    case  let .operation(operation):
      return operation.definition.isLocalCacheMutation
    case let .namedFragment(fragment):
      return fragment.definition.isLocalCacheMutation
    }
  }

  var generatedDefinitionName: String {
    switch self {
    case  let .operation(operation):
      return operation.generatedDefinitionName
    case let .namedFragment(fragment):
      return fragment.generatedDefinitionName
    }
  }

}

extension IR.Operation {

  var generatedDefinitionName: String {
    definition.nameWithSuffix.firstUppercased
  }

}

extension IR.NamedFragment {

  var generatedDefinitionName: String {
    definition.name.firstUppercased
  }

}
