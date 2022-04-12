import Foundation

/// Provides the format to convert a [GraphQL Input Object](https://spec.graphql.org/draft/#sec-Input-Objects)
/// into Swift code.
struct InputObjectTemplate: TemplateRenderer {
  /// IR representation of source [GraphQL Input Object](https://spec.graphql.org/draft/#sec-Input-Objects).
  let graphqlInputObject: GraphQLInputObjectType

  let schema: IR.Schema

  var target: TemplateTarget = .schemaFile

  var template: TemplateString {
    TemplateString(
    """
    public struct \(graphqlInputObject.name.firstUppercased): InputObject {
      public private(set) var data: InputDict
    
      public init(_ data: InputDict) {
        self.data = data
      }

      public init(
        \(InitializerParametersTemplate())
      ) {
        data = InputDict([
          \(InputDictInitializerTemplate())
        ])
      }

      \(graphqlInputObject.fields.map({ "\(FieldPropertyTemplate($1))" }), separator: "\n\n")
    }
    """
    )
  }

  private func InitializerParametersTemplate() -> TemplateString {
    TemplateString("""
    \(graphqlInputObject.fields.map({
      "\($1.name): \($1.renderInputValueType(includeDefault: true, in: schema))"
    }), separator: ",\n")
    """)
  }

  private func InputDictInitializerTemplate() -> TemplateString {
    TemplateString("""
    \(graphqlInputObject.fields.map({ "\"\($1.name)\": \($1.name)" }), separator: ",\n")
    """)
  }

  private func FieldPropertyTemplate(_ field: GraphQLInputField) -> String {
    """
    public var \(field.name): \(field.renderInputValueType(in: schema)) {
      get { data.\(field.name) }
      set { data.\(field.name) = newValue }
    }
    """
  }
}
