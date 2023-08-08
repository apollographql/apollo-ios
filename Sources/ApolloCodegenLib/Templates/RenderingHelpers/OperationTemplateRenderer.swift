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
        let name = $0.name.asFieldPropertyName
        return "self.\(name) = \(name)"
      }, separator: "\n")
    }
    """
  }

  func VariableProperties(
    _ variables: [CompilationResult.VariableDefinition]
  ) -> TemplateString {
    """
    \(variables.map { "public var \($0.name.asFieldPropertyName): \($0.type.rendered(as: .inputValue, config: config.config))"}, separator: "\n")
    """
  }

  func VariableParameter(
    _ variable: CompilationResult.VariableDefinition
  ) -> TemplateString {
      """
      \(variable.name.asFieldPropertyName): \(variable.type.rendered(as: .inputValue, config: config.config))\
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
      public var __variables: \(if: !graphQLOperation, "GraphQLOperation.")Variables? { [\(list: variables.map { "\"\($0.name)\": \($0.name.asFieldPropertyName)"})] }
      """
  }

  func DeferredProperties(
    _ definition: IR.Definition
  ) -> TemplateString {
    func isDeferred(_ selectionSet: IR.SelectionSet) -> Bool {
      guard !selectionSet.scope.isDeferred else { return true }

      if let fields = selectionSet.selections.direct?.fields {
        for field in fields.values {
          if let entityField = field as? IR.EntityField {
            guard !isDeferred(entityField.selectionSet) else { return true }
          }
        }
      }

      if let inlineFragments = selectionSet.selections.direct?.inlineFragments {
        for fragment in inlineFragments.values {
          guard !isDeferred(fragment.selectionSet) else { return true }
        }
      }

      if let namedFragments = selectionSet.selections.direct?.namedFragments {
        for fragment in namedFragments.values {
          return (fragment.isDeferred != false)
        }
      }

      return false
    }

    return """
    \(if: isDeferred(definition.rootField.selectionSet), """
    public static let hasDeferredFragments: Bool = true
    """)
    """
  }

}
