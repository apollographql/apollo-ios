import OrderedCollections
import ApolloUtils

protocol InputVariableRenderable {
  var type: GraphQLType { get }
  var defaultValue: GraphQLValue? { get }
//  var config: ReferenceWrapped<ApolloCodegenConfiguration> { get }
}

extension CompilationResult.VariableDefinition: InputVariableRenderable {}

struct InputVariable: InputVariableRenderable {
  let type: GraphQLType
  let defaultValue: GraphQLValue?
//  let config: ReferenceWrapped<ApolloCodegenConfiguration>
}

extension InputVariableRenderable {
  func renderVariableDefaultValue() -> TemplateString {
    renderVariableDefaultValue(inList: false)
  }

  private func renderVariableDefaultValue(inList: Bool) -> TemplateString {
    switch defaultValue {
    case .none: return ""
    case .null: return inList ? "nil" : ".null"
    case let .string(string): return "\"\(string)\""
    case let .boolean(boolean): return boolean ? "true" : "false"
    case let .int(int): return TemplateString(int.description)
    case let .float(float): return TemplateString(float.description)
    case let .enum(enumValue): return ".init(.\(enumValue))"
    case let .list(list):
      switch type {
      case let .nonNull(.list(listInnerType)),
        let .list(listInnerType):
        return """
        [\(list.compactMap {
          InputVariable(type: listInnerType, defaultValue: $0).renderVariableDefaultValue(inList: true)
        }, separator: ", ")]
        """

      default:
        preconditionFailure("Variable type must be List with value of .list type.")
      }

    case let .object(object):
      switch type {
      case let .nonNull(.inputObject(inputObjectType)):
        return inputObjectType.renderInitializer(values: object)

      case let .inputObject(inputObjectType):
        return """
        .init(
          \(inputObjectType.renderInitializer(values: object))
        )
        """

      default:
        preconditionFailure("Variable type must be InputObject with value of .object type.")
      }

    case .variable:
      preconditionFailure("Variable cannot be used as Default Value for an Operation Variable!")
    }
  }
}

fileprivate extension GraphQLInputObjectType {
  func renderInitializer(values: OrderedDictionary<String, GraphQLValue>) -> TemplateString {
    let entries = values.compactMap { entry -> TemplateString in
      guard let field = self.fields[entry.0] else {
        preconditionFailure("Field \(entry.0) not found on input object.")
      }

      let variable = InputVariable(type: field.type, defaultValue: entry.value)

      return "\(entry.0): " + variable.renderVariableDefaultValue()
    }

    return """
    \(name)(\(list: entries))
    """
  }
}
