import OrderedCollections
extension CompilationResult.VariableDefinition {
  func renderVariableDefaultValue() -> TemplateString? {
    switch defaultValue {
    case .none: return nil
    case .null: return ".null"
    case let .enum(enumValue): return ".init(\"\(enumValue)\")"
    case let .some(value): return renderInputValueLiteral(value: value, type: type)
    }
  }
}

private func renderInputValueLiteral(value: GraphQLValue, type: GraphQLType) -> TemplateString {
  switch value {
  case let .string(string): return "\"\(string)\""
  case let .boolean(boolean): return boolean ? "true" : "false"
  case let .int(int): return TemplateString(int.description)
  case let .float(float): return TemplateString(float.description)
  case let .enum(enumValue): return "GraphQLEnum<\(type.namedType.name)>(\"\(enumValue)\")"
  case .null: return "nil"
  case let .list(list):
    return "[\(list.map { renderInputValueLiteral(value: $0, type: type) }, separator: ", ")]"

  case let .object(object):
    guard case let .inputObject(inputObject) = type else {
      preconditionFailure("Variable type must be InputObject with value of .object type.")
    }

    return inputObject.renderInputValueLiteral(values: object)

  case .variable:
    preconditionFailure("Variable cannot be used as Default Value for an Operation Variable!")
  }
}

fileprivate extension GraphQLInputObjectType {
  func renderInputValueLiteral(values: OrderedDictionary<String, GraphQLValue>) -> TemplateString {
    let entries = values.map { entry -> TemplateString in
      guard let field = self.fields[entry.0] else {
        preconditionFailure("Field \(entry.0) not found on input object.")
      }

      return "\"\(entry.0)\": " +
      ApolloCodegenLib.renderInputValueLiteral(value: entry.1, type: field.type)
    }
    return "[\(list: entries)]"
  }
}
