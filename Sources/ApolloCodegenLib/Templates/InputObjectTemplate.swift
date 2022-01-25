import Foundation
import JavaScriptCore

struct InputObjectTemplate {
  let graphqlInputObject: GraphQLInputObjectType

  func render() -> String {
    TemplateString(
    """
    struct \(graphqlInputObject.name.firstUppercased): InputObject {
      private(set) public var dict: InputDict

      init(
        \(InitializerParametersTemplate())
      ) {
        dict = InputDict([
          \(InputDictInitializerTemplate())
        ])
      }

      \(graphqlInputObject.fields.map({ "\(FieldPropertyTemplate($1))" }), separator: "\n\n")
    }
    """
    ).value
  }

  private func InitializerParametersTemplate() -> TemplateString {
    TemplateString("""
    \(graphqlInputObject.fields.map({
      "\($1.name): \($1.renderType(includeDefault: true))"
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
    var \(field.name): \(field.renderType()) {
      get { dict[\"\(field.name)\"] }
      set { dict[\"\(field.name)\"] = newValue }
    }
    """
  }
}

fileprivate extension GraphQLInputField {
  func renderType(includeDefault: Bool = false) -> String {
    "\(type.render())\(isSwiftOptional ? "?" : "")\(includeDefault && hasSwiftNilDefault ? " = nil" : "")"
  }

  private var isSwiftOptional: Bool {
    !isNullable && hasSchemaDefault
  }

  private var hasSwiftNilDefault: Bool {
    isNullable && !hasSchemaDefault
  }

  private var isNullable: Bool {
    switch type {
    case .nonNull(_): return false
    default: return true
    }
  }

  private var hasSchemaDefault: Bool {
    switch defaultValue {
    case .none, .some(nil):
      return false
    case let .some(value):
      guard let value = value as? JSValue else {
        fatalError("Cannot determine default value for Input field: \(self)")
      }

      return !value.isUndefined
    }
  }
}

fileprivate extension GraphQLType {
  func render(containedInNonNull: Bool = false) -> String {
    switch self {
    case let .entity(type as GraphQLNamedType),
      let .enum(type as GraphQLNamedType),
      let .inputObject(type as GraphQLNamedType):

      return containedInNonNull ? type.name : "GraphQLNullable<\(type.name)>"

    case let .scalar(type as GraphQLNamedType):
      let typeName = (type.name == "Boolean" ? "Bool" : type.name)

      return containedInNonNull ? typeName : "GraphQLNullable<\(typeName)>"

    case let .nonNull(ofType):
      return ofType.render(containedInNonNull: true)

    case let .list(ofType):
      let inner = "[\(ofType.render(containedInNonNull: false))]"

      return containedInNonNull ? inner : "GraphQLNullable<\(inner)>"
    }
  }
}
