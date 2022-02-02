struct FragmentTemplate {

  let fragment: IR.NamedFragment
  let schema: IR.Schema
  let config: ApolloCodegenConfiguration.FileOutput

  func render() -> String {
    TemplateString(
    """
    \(ImportStatementTemplate.Operation.render(config))

    public struct \(fragment.name): \(schema.name).SelectionSet, Fragment {
      public static var fragmentDefinition: StaticString { ""\"
        \(fragment.definition.source)
        ""\" }

      \(SelectionSetTemplate(schema: schema).BodyTemplate(fragment.rootField.selectionSet))
    }
    """).description
  }

}
