import Foundation

/// Provides the format to convert a [GraphQL Fragment](https://spec.graphql.org/draft/#sec-Language.Fragments)
/// into Swift code.
struct FragmentTemplate: TemplateRenderer {
  /// IR representation of source [GraphQL Fragment](https://spec.graphql.org/draft/#sec-Language.Fragments).
  let fragment: IR.NamedFragment

  let config: ApolloCodegen.ConfigurationContext

  let target: TemplateTarget = .operationFile

  var template: TemplateString {
    let definition = IR.Definition.namedFragment(fragment)

    return TemplateString(
    """
    \(accessControlModifier(for: .parent, in: target))\
    struct \(fragment.generatedDefinitionName): \
    \(definition.renderedSelectionSetType(config)), Fragment {
      \(accessControlModifier(for: .member, in: target))\
    static var fragmentDefinition: StaticString { ""\"
        \(fragment.definition.source)
        ""\" }

      \(SelectionSetTemplate(
        definition: definition,
        generateInitializers: config.options.shouldGenerateSelectionSetInitializers(for: fragment),
        config: config,
        accessControlRenderer: { accessControlModifier(for: .member, in: target) }()
      ).renderBody())
    }

    """)
  }

}
