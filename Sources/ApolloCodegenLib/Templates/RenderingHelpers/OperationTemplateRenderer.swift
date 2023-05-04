/// Protocol for a `TemplateRenderer` that renders an operation definition template.
/// This protocol provides rendering helper functions for common template elements.
protocol OperationTemplateRenderer: TemplateRenderer { }

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
      \(variables.map {
        let name = $0.name.asInputParameterName
        return "self.\(name) = \(name)"
      }, separator: "\n")
    }
    """
  }

  func VariableProperties(
    _ variables: [CompilationResult.VariableDefinition]
  ) -> TemplateString {
    """
    \(variables.map { "public var \($0.name.asFieldAccessorPropertyName): \($0.type.rendered(as: .inputValue, config: config.config))"}, separator: "\n")
    """
  }

  func VariableParameter(
    _ variable: CompilationResult.VariableDefinition
  ) -> TemplateString {
      """
      \(variable.name.asInputParameterName): \(variable.type.rendered(as: .inputValue, config: config.config))\
      \(if: variable.defaultValue != nil, " = " + variable.renderVariableDefaultValue(config: config.config))
      """
  }

  func VariableAccessors(
    _ variables: [CompilationResult.VariableDefinition],
    graphQLOperation: Bool = true
  ) -> TemplateString {
    guard !variables.isEmpty else {
      return ""
    }

    return """
      public var __variables: \(if: !graphQLOperation, "GraphQLOperation.")Variables? { [\(list: variables.map { "\"\($0.name)\": \($0.name.asFieldAccessorPropertyName)"})] }
      """
  }

}
