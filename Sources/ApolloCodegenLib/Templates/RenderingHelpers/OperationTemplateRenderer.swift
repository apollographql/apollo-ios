/// Protocol for a `TemplateRenderer` that renders an operation definition template.
/// This protocol provides rendering helper functions for common template elements.
protocol OperationTemplateRenderer: TemplateRenderer {
  var schema: IR.Schema { get }
}

extension OperationTemplateRenderer {
  func Initializer(
    _ variables: [CompilationResult.VariableDefinition]
  ) -> TemplateString {
    let `init` = "public init"
    if variables.isEmpty {
      return "\(`init`)() {}"
    }

    return """
    \(`init`)(\(list: variables.map(VariableParameter))) {
      \(variables.map { "self.\($0.name) = \($0.name)" }, separator: "\n")
    }
    """
  }

  func VariableProperties(
    _ variables: [CompilationResult.VariableDefinition]
  ) -> TemplateString {
    """
    \(variables.map { "public var \($0.name): \($0.type.renderAsInputValue(inSchemaNamed: schema.name))"}, separator: "\n")
    """
  }

  func VariableParameter(
    _ variable: CompilationResult.VariableDefinition
  ) -> TemplateString {
      """
      \(variable.name): \(variable.type.renderAsInputValue(inSchemaNamed: schema.name))\
      \(if: variable.defaultValue != nil, " = " + variable.renderVariableDefaultValue())
      """
  }

  func VariableAccessors(
    _ variables: [CompilationResult.VariableDefinition]
  ) -> TemplateString {
    guard !variables.isEmpty else {
      return ""
    }

    return """
      public var variables: Variables? {
        [\(variables.map { "\"\($0.name)\": \($0.name)"}, separator: ",\n   ")]
      }
      """
  }
}