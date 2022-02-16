extension CompilationResult.VariableDefinition {
  func renderInputValueType(includeDefault: Bool = false) -> TemplateString {
    "\(type.renderAsInputValue())\(ifLet: defaultValue, where: {_ in includeDefault}, {" = \($0.renderedAsVariableDefaultValue)"})"
  }

  var hasDefaultValue: Bool {
    switch defaultValue {
    case .none, .some(nil): return false
    default: return true
    }
  }
}
