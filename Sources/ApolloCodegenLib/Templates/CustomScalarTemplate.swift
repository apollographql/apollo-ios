import Foundation
import ApolloUtils

/// Provides the format to convert a [GraphQL Custom Scalar](https://spec.graphql.org/draft/#sec-Scalars.Custom-Scalars)
/// into Swift code.
struct CustomScalarTemplate: TemplateRenderer {
  /// IR representation of source [GraphQL Custom Scalar](https://spec.graphql.org/draft/#sec-Scalars.Custom-Scalars).
  let graphqlScalar: GraphQLScalarType

  let config: ApolloCodegen.ConfigurationContext

  let target: TemplateTarget = .schemaFile

  var headerTemplate: TemplateString? {
    TemplateString(
    """
    // @generated
    // This file was automatically generated and can be edited to implement
    // advanced custom scalar functionality.
    //
    // Any changes to this file will not be overwritten by future
    // code generation execution.
    """
    )
  }

  var template: TemplateString {
    TemplateString(
    """
    \(documentation: documentationTemplate, config: config)
    \(embeddedAccessControlModifier)\
    typealias \(graphqlScalar.name.firstUppercased) = String
    
    """
    )
  }

  private var documentationTemplate: String? {
    var string = graphqlScalar.documentation
    if let specifiedByURL = graphqlScalar.specifiedByURL {
      let specifiedByDocs = "Specified by: [](\(specifiedByURL))"
      string = string?.appending("\n\n\(specifiedByDocs)") ?? specifiedByDocs
    }
    return string
  }
}
