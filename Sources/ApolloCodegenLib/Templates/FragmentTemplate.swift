struct FragmentTemplate: TemplateRenderer {
  let fragment: IR.NamedFragment
  let schema: IR.Schema

  var target: TemplateTarget { .operationFile }

  var template: TemplateString {
    TemplateString(
    """
    public struct \(fragment.name): \(schema.name).SelectionSet, Fragment {
      public static var fragmentDefinition: StaticString { ""\"
        \(fragment.definition.source)
        ""\" }

      \(SelectionSetTemplate(schema: schema).BodyTemplate(fragment.rootField.selectionSet))
    }
    """)
  }
}
