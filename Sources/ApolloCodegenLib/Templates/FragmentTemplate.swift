struct FragmentTemplate {

  let fragment: IR.NamedFragment
  let schema: IR.Schema
  let config: ApolloCodegenConfiguration

  func render() -> String {
    TemplateString(
    """
    \(ImportStatementTemplate.Operation.render(config))

    \(SelectionSetTemplate(schema: schema).render(for: fragment))
    """).description
  }

}
