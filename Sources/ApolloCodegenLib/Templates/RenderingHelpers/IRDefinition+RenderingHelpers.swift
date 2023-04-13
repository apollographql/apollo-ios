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

}
