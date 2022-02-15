import JavaScriptCore

protocol InputValueRenderable {
  var name: String { get }
  var type: GraphQLType { get }
  var hasDefaultValue: Bool { get }
}

extension InputValueRenderable {
  func renderInputValueType(includeDefault: Bool = false) -> String {
    "\(type.renderAsInputValue())\(isSwiftOptional ? "?" : "")\(includeDefault && hasSwiftNilDefault ? " = nil" : "")"
  }

  private var isSwiftOptional: Bool {
    !isNullable && hasDefaultValue
  }

  private var hasSwiftNilDefault: Bool {
    isNullable && !hasDefaultValue
  }

  var isNullable: Bool {
    switch type {
    case .nonNull: return false
    default: return true
    }
  }
}

extension GraphQLInputField: InputValueRenderable {
  var hasDefaultValue: Bool {
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

extension CompilationResult.VariableDefinition: InputValueRenderable {
  var hasDefaultValue: Bool {
    switch defaultValue {
    case .none, .some(nil), .some(.null): return false
    default: return true
    }
  }
}
