import Foundation
import ApolloUtils

/// Provides the format to convert a [GraphQL Fragment](https://spec.graphql.org/draft/#sec-Language.Fragments)
/// into Swift code.
struct FragmentTemplate: TemplateRenderer {
  /// IR representation of source [GraphQL Fragment](https://spec.graphql.org/draft/#sec-Language.Fragments).
  let fragment: IR.NamedFragment
  /// IR representation of source GraphQL schema.
  let schema: IR.Schema

  let config: ApolloCodegen.ConfigurationContext

  let target: TemplateTarget = .operationFile

  var template: TemplateString {
    TemplateString(
    """
    \(embeddedAccessControlModifier)\
    struct \(fragment.name.firstUppercased): \(schema.name)\
    .\(if: isMutable, "Mutable")SelectionSet, Fragment {
      public static var fragmentDefinition: StaticString { ""\"
        \(fragment.definition.source)
        ""\" }

      \(SelectionSetTemplate(
        schema: schema,
        mutable: isMutable,
        config: config
      ).BodyTemplate(fragment.rootField.selectionSet))
    }

    """)
  }

  private var isMutable: Bool {
    fragment.definition.isLocalCacheMutation
  }
}
