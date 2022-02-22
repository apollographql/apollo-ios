import Foundation
import JavaScriptCore

struct InputObjectTemplate {
  let graphqlInputObject: GraphQLInputObjectType

  func render() -> String {
    TemplateString(
    """
    \(HeaderCommentTemplate.render())

    \(ImportStatementTemplate.SchemaType.render())

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
    ).description
  }

  private func InitializerParametersTemplate() -> TemplateString {
    TemplateString("""
    \(graphqlInputObject.fields.map({
      "\($1.name): \($1.renderInputValueType(includeDefault: true))"
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
    public var \(field.name): \(field.renderInputValueType()) {
      get { data.\(field.name) }
      set { data.\(field.name) = newValue }
    }
    """
  }
}
