import Foundation

/// Generates a file containing the Swift representation of a [GraphQL Fragment](https://spec.graphql.org/draft/#sec-Language.Fragments).
struct FragmentFileGenerator: FileGenerator {
  /// Source IR fragment.
  let namedFragment: IR.NamedFragment
  /// Source IR schema.
  let schema: IR.Schema
  
  var template: TemplateRenderer { FragmentTemplate(fragment: namedFragment, schema: schema) }
  var target: FileTarget { .fragment(namedFragment.definition) }
  var fileName: String { "\(namedFragment.definition.name).swift" }
}
