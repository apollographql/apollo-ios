extension GraphQLValue {
  var renderedAsVariableDefaultValue: TemplateString {
    switch self {
    case .null: return ".null"
    case let .enum(enumValue): return ".init(\"\(enumValue)\")"
    default: return renderedAsInputValueLiteral
    }
  }

  var renderedAsInputValueLiteral: TemplateString {
    switch self {
    case let .string(string): return "\"\(string)\""
    case let .boolean(boolean): return boolean ? "true" : "false"
    case let .int(int): return TemplateString(int.description)
    case let .float(float): return TemplateString(float.description)
    case let .enum(enumValue): return "GraphQLEnum(\"\(enumValue)\")"
    case .null: return "nil"
    case let .list(list):
      return "[\(list.map(\.renderedAsInputValueLiteral), separator: ", ")]"

    case let .object(object):
      return "[\(list: object.map{"\"\($0.0)\": \($0.1.renderedAsInputValueLiteral)"})]"

    case .variable:
      preconditionFailure("Variable cannot be used as Default Value for an Operation Variable!")
    }
  }

}
