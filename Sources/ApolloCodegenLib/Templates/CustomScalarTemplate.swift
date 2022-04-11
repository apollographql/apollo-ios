import Foundation

/// Provides the format to convert a [GraphQL Custom Scalar](https://spec.graphql.org/draft/#sec-Scalars.Custom-Scalars)
/// into Swift code.
struct CustomScalarTemplate: TemplateRenderer {
  /// IR representation of source [GraphQL Custom Scalar](https://spec.graphql.org/draft/#sec-Scalars.Custom-Scalars).
  let graphqlScalar: GraphQLScalarType

  var target: TemplateTarget { .schemaFile }

  var template: TemplateString {
    TemplateString(
    """
    public typealias \(graphqlScalar.name.firstUppercased) = String
    """
    )
  }
}
