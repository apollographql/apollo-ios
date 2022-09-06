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
    \(variables.map { "public var \($0.name): \($0.type.rendered(as: .inputValue(), config: config.config))"}, separator: "\n")
    """
  }

  func VariableParameter(
    _ variable: CompilationResult.VariableDefinition
  ) -> TemplateString {
      """
      \(variable.name): \(variable.type.rendered(as: .inputValue(), config: config.config))\
      \(if: variable.defaultValue != nil, " = " + variable.renderVariableDefaultValue(config: config.config))
      """
  }

  func VariableAccessors(
    _ variables: [CompilationResult.VariableDefinition]
  ) -> TemplateString {
    guard !variables.isEmpty else {
      return ""
    }

    return """
      public var variables: Variables? { [\(list: variables.map { "\"\($0.name)\": \($0.name)"})] }
      """
  }

  func NullishConvenienceInitializer(
    _ variables: [CompilationResult.VariableDefinition]
  ) -> TemplateString {
    if variables.allSatisfy(variableIsNonNull) {
      return ""
    }

    let `init` = "public convenience init"
    if variables.isEmpty {
      return "\(`init`)() {}"
    }

    return """
    \(`init`)(\(list: variables.map(SwiftOptionalVariableParameter))) {
      self.init(
        \(variables.map(DelegateToRequiredInitializerArgument))
      )
    }
    """
  }

  private func DelegateToRequiredInitializerArgument(
    _ variable: CompilationResult.VariableDefinition
  ) -> TemplateString {
    variableIsNonNull(variable) ?
    "\(variable.name): \(variable.name)" :
    "\(variable.name): \(variable.name) ?? .\(config.options.embedNullableVariableConvenienceInitializer.nullishWord)"
  }

  private func SwiftOptionalVariableParameter(
    _ variable: CompilationResult.VariableDefinition
  ) -> TemplateString {
      """
      \(variable.name): \(variable.type.rendered(as: .inputValue(isSwiftOptional: true), config: config.config))\
      \(if: variable.defaultValue != nil, " = " + variable.renderVariableDefaultValue(config: config.config))
      """
  }

  func variableIsNonNull(_ variable: CompilationResult.VariableDefinition) -> Bool {
    if case .nonNull = variable.type {
      return true
    }
    return false
  }
}
