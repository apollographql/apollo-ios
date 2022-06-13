import Foundation
import ApolloUtils

/// Provides the format to convert a [GraphQL Fragment](https://spec.graphql.org/draft/#sec-Language.Fragments)
/// into Swift code.
struct FragmentTemplate: TemplateRenderer {
  /// IR representation of source [GraphQL Fragment](https://spec.graphql.org/draft/#sec-Language.Fragments).
  let fragment: IR.NamedFragment
  /// IR representation of source GraphQL schema.
  let schema: IR.Schema
  /// Shared codegen configuration.
  let config: ReferenceWrapped<ApolloCodegenConfiguration>

  var target: TemplateTarget { .operationFile }

  var template: TemplateString {
    TemplateString(
    """
		\(embeddedAccessControlModifier(config: config) ?? "")\
    struct \(fragment.name.firstUppercased): \(schema.name)\
    .\(if: isMutable, "Mutable")SelectionSet, Fragment {
      public static var fragmentDefinition: StaticString { ""\"
        \(fragment.definition.source)
        ""\" }

      \(SelectionSetTemplate(
        schema: schema,
        mutable: isMutable
      ).BodyTemplate(fragment.rootField.selectionSet))
    }
    """)
  }

  private var isMutable: Bool {
    fragment.definition.isLocalCacheMutation
  }
}
