import Foundation
import ApolloUtils

/// Provides the format to convert a [GraphQL Input Object](https://spec.graphql.org/draft/#sec-Input-Objects)
/// into Swift code.
struct InputObjectTemplate: TemplateRenderer {
  /// IR representation of source [GraphQL Input Object](https://spec.graphql.org/draft/#sec-Input-Objects).
  let graphqlInputObject: GraphQLInputObjectType
  /// IR representation of a GraphQL schema.
  let schema: IR.Schema

  let config: ApolloCodegen.ConfigurationContext

  let target: TemplateTarget = .schemaFile

  var template: TemplateString {
    TemplateString(
    """
    \(documentation: graphqlInputObject.documentation, config: config)
    \(embeddedAccessControlModifier)\
    struct \(graphqlInputObject.name.firstUppercased): InputObject {
      public private(set) var __data: InputDict
    
      public init(_ data: InputDict) {
        __data = data
      }

      public init(
        \(InitializerParametersTemplate())
      ) {
        __data = InputDict([
          \(InputDictInitializerTemplate())
        ])
      }

      \(graphqlInputObject.fields.map({ "\(FieldPropertyTemplate($1))" }), separator: "\n\n")
    }

    """
    )
  }

  private func InitializerParametersTemplate(
    _ fields:
  ) -> TemplateString {
    TemplateString("""
    \(graphqlInputObject.fields.map({
      "\($1.name): \($1.renderInputValueType(includeDefault: true, config: config.config))"
    }), separator: ",\n")
    """)
  }

  private func InputDictInitializerTemplate() -> TemplateString {
    TemplateString("""
    \(graphqlInputObject.fields.map({ "\"\($1.name)\": \($1.name)" }), separator: ",\n")
    """)
  }

  private func FieldPropertyTemplate(_ field: GraphQLInputField) -> TemplateString {
    """
    \(documentation: field.documentation, config: config)
    \(ifLet: field.deprecationReason,
      where: config.options.warningsOnDeprecatedUsage == .include, {
        "@available(*, deprecated, message: \"\($0)\")"
      })
    public var \(field.name): \(field.renderInputValueType(config: config.config)) {
      get { __data.\(field.name) }
      set { __data.\(field.name) = newValue }
    }
    """
  }
}
