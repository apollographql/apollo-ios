import OrderedCollections

extension GraphQLValue {
  func renderInputValueLiteral() -> TemplateString {
    switch self {
    case let .string(string): return "\"\(string)\""
    case let .boolean(boolean): return boolean ? "true" : "false"
    case let .int(int): return TemplateString(int.description)
    case let .float(float): return TemplateString(float.description)
    case let .enum(enumValue): return "\"\(enumValue)\""
    case .null: return ".null"
    case let .list(list):
      return "[\(list.map{ $0.renderInputValueLiteral() }, separator: ", ")]"

    case let .object(object):
      return "[\(list: object.map{ "\"\($0.0)\": " + $0.1.renderInputValueLiteral() })]"

    case let .variable(variableName):
      return ".variable(\"\(variableName)\")"
    }
  }
}
