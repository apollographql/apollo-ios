import Foundation
import JavaScriptCore

struct InputObjectTemplate {
  let graphqlInputObject: GraphQLInputObjectType

  func render() -> String {
    TemplateString(
    """
    \(ImportStatementTemplate.SchemaType.render())

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
    ).description
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

  var isSwiftOptional: Bool {
    !isNullable && hasSchemaDefault
  }

  var hasSwiftNilDefault: Bool {
    isNullable && !hasSchemaDefault
  }

  var isNullable: Bool {
    switch type {
    case .nonNull(_): return false
    default: return true
    }
  }

  var hasSchemaDefault: Bool {
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
  enum NullabilityContainer {
    case none
    case graphqlNullable
    case swiftOptional
  }

  func render(nullability: NullabilityContainer = .graphqlNullable) -> String {
    switch self {
    case let .entity(type as GraphQLNamedType),
      let .enum(type as GraphQLNamedType),
      let .scalar(type as GraphQLNamedType),
      let .inputObject(type as GraphQLNamedType):

      switch nullability {
      case .none: return type.swiftName
      case .graphqlNullable: return "GraphQLNullable<\(type.swiftName)>"
      case .swiftOptional: return "\(type.swiftName)?"
      }

    case let .nonNull(ofType):
      return ofType.render(nullability: .none)

    case let .list(ofType):
      let inner = "[\(ofType.render(nullability: .swiftOptional))]"

      if nullability == .graphqlNullable { return "GraphQLNullable<\(inner)>" }
      else { return inner }
    }
  }
}
