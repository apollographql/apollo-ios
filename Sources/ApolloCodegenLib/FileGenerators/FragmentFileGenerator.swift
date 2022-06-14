import Foundation
import ApolloUtils

/// Generates a file containing the Swift representation of a [GraphQL Fragment](https://spec.graphql.org/draft/#sec-Language.Fragments).
struct FragmentFileGenerator: FileGenerator {
  /// Source IR fragment.
  let irFragment: IR.NamedFragment
  /// Source IR schema.
  let schema: IR.Schema
  /// Shared codegen configuration.
  let config: ReferenceWrapped<ApolloCodegenConfiguration>
  
  var template: TemplateRenderer { FragmentTemplate(
    fragment: irFragment,
    schema: schema,
    config: config
  ) }
  var target: FileTarget { .fragment(irFragment.definition) }
  var fileName: String { "\(irFragment.definition.name).swift" }
}
