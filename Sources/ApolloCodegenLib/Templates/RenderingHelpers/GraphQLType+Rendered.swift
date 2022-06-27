extension GraphQLType {

  enum RenderContext {
    /// Renders the type for use in an operation selection set.
    case selectionSetField(forceNonNull: Bool = false)
    /// Renders the type for use in a test mock object.
    case testMockField(forceNonNull: Bool = false)
    /// Renders the type for use as an input value.
    ///
    /// If the outermost type is nullable, it will be wrapped in a `GraphQLNullable` instead of
    /// an `Optional`.
    case inputValue
  }

  func rendered(
    as context: RenderContext,
    replacingNamedTypeWith newTypeName: String? = nil,
    config: ApolloCodegenConfiguration
  ) -> String {
    switch context {
    case let .selectionSetField(forceNonNull):
      return renderedAsSelectionSetField(
        containedInNonNull: forceNonNull,
        replacingNamedTypeWith: newTypeName,
        config: config
      )

    case let .testMockField(forceNonNull):
      return renderedAsTestMockField(
        containedInNonNull: forceNonNull,
        replacingNamedTypeWith: newTypeName,
        config: config
      )

    case .inputValue:
      return renderAsInputValue(inNullable: true, config: config)
    }
  }

  // MARK: Selection Set Field

  private func renderedAsSelectionSetField(
    containedInNonNull: Bool,
    replacingNamedTypeWith newTypeName: String? = nil,
    config: ApolloCodegenConfiguration
  ) -> String {

    lazy var schemaModuleName: String = {
      !config.output.operations.isInModule ? "\(config.schemaName)." : ""
    }()

    switch self {
    case let .entity(type as GraphQLNamedType):
      let typeName = newTypeName ?? type.swiftName
      return containedInNonNull ? typeName : "\(typeName)?"

    case let .inputObject(type as GraphQLNamedType):
      let typeName = newTypeName ?? type.swiftName
      return TemplateString("\(schemaModuleName)\(typeName)\(if: !containedInNonNull, "?")").description

    case let .scalar(type):
      let typeName = newTypeName ?? type.swiftName

      return TemplateString(
        "\(if: !type.isSwiftType, "\(schemaModuleName)")\(typeName)\(if: !containedInNonNull, "?")"
      ).description

    case let .enum(type as GraphQLNamedType):
      let typeName = newTypeName ?? type.name
      let enumType = "GraphQLEnum<\(schemaModuleName)\(typeName)>"

      return containedInNonNull ? enumType : "\(enumType)?"

    case let .nonNull(ofType):
      return ofType.renderedAsSelectionSetField(
        containedInNonNull: true,
        replacingNamedTypeWith: newTypeName,
        config: config
      )

    case let .list(ofType):
      let rendered = ofType.renderedAsSelectionSetField(
        containedInNonNull: false,
        replacingNamedTypeWith: newTypeName,
        config: config
      )
      let inner = "[\(rendered)]"

      return containedInNonNull ? inner : "\(inner)?"
    }
  }

  // MARK: Mock Object Field

  private func renderedAsTestMockField(
    containedInNonNull: Bool,
    replacingNamedTypeWith newTypeName: String? = nil,
    config: ApolloCodegenConfiguration
  ) -> String {

    lazy var schemaModuleName: String = {
      !config.output.schemaTypes.isInModule ? "\(config.schemaName)." : ""
    }()

    switch self {
    case let .entity(type as GraphQLNamedType), let .inputObject(type as GraphQLNamedType):
      let typeName = newTypeName ?? type.swiftName
      return TemplateString("\(schemaModuleName)\(typeName)\(if: !containedInNonNull, "?")").description

    case let .scalar(type):
      let typeName = newTypeName ?? type.swiftName

      return TemplateString(
        "\(if: !type.isSwiftType, "\(schemaModuleName)")\(typeName)\(if: !containedInNonNull, "?")"
      ).description

    case let .enum(type as GraphQLNamedType):
      let typeName = newTypeName ?? type.name
      let enumType = "GraphQLEnum<\(schemaModuleName)\(typeName)>"

      return containedInNonNull ? enumType : "\(enumType)?"

    case let .nonNull(ofType):
      return ofType.renderedAsTestMockField(
        containedInNonNull: true,
        replacingNamedTypeWith: newTypeName,
        config: config
      )

    case let .list(ofType):
      let rendered = ofType.renderedAsTestMockField(
        containedInNonNull: false,
        replacingNamedTypeWith: newTypeName,
        config: config
      )
      let inner = "[\(rendered)]"

      return containedInNonNull ? inner : "\(inner)?"
    }
  }

  // MARK: Input Value

  private func renderAsInputValue(
    inNullable: Bool,
    config: ApolloCodegenConfiguration
  ) -> String {
    switch self {
    case .entity:
      preconditionFailure("Entities cannot be used as input values")

    case .enum, .scalar, .inputObject:
      let typeName = self.renderedAsSelectionSetField(containedInNonNull: true, config: config)
      return inNullable ? "GraphQLNullable<\(typeName)>" : typeName

    case let .nonNull(ofType):
      return ofType.renderAsInputValue(inNullable: false, config: config)

    case let .list(ofType):
      let typeName = "[\(ofType.renderedAsSelectionSetField(containedInNonNull: false, config: config))]"
      return inNullable ? "GraphQLNullable<\(typeName)>" : typeName
    }
  }
}
