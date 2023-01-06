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
    switch self {
    case
        .entity(let type as GraphQLNamedType),
        .scalar(let type as GraphQLNamedType),
        .enum(let type as GraphQLNamedType),
        .inputObject(let type as GraphQLNamedType):

      let typeName = type.qualifiedRootTypeName(
        in: .selectionSetField(),
        replacingNamedTypeWith: newTypeName,
        config: config
      )

      return containedInNonNull ? typeName : "\(typeName)?"

//    case let :
//      let typeName = newTypeName ?? type.swiftName.firstUppercased
//      return TemplateString("\(schemaModuleName)\(typeName)\(if: !containedInNonNull, "?")").description
//
//    case let .scalar(type):
//      let typeName = newTypeName ?? type.swiftName.firstUppercased
//
//      return TemplateString(
//        "\(if: !type.isSwiftType, "\(schemaModuleName)")\(typeName)\(if: !containedInNonNull, "?")"
//      ).description
//
//    case let .enum(type as GraphQLNamedType):
//      let typeName = newTypeName ?? type.name.firstUppercased
//      let enumType = "GraphQLEnum<\(schemaModuleName)\(typeName)>"
//
//      return containedInNonNull ? enumType : "\(enumType)?"

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
      !config.output.schemaTypes.isInModule ? "\(config.schemaName.firstUppercased)." : ""
    }()

    switch self {
    case let .entity(type as GraphQLNamedType), let .inputObject(type as GraphQLNamedType):
      let typeName = newTypeName ?? type.testMockFieldTypeName.firstUppercased
      return TemplateString("\(typeName)\(if: !containedInNonNull, "?")").description

    case let .scalar(type):
      let typeName = newTypeName ?? type.swiftName.firstUppercased

      return TemplateString(
        "\(if: !type.isSwiftType, "\(schemaModuleName)")\(typeName)\(if: !containedInNonNull, "?")"
      ).description

    case let .enum(type as GraphQLNamedType):
      let typeName = newTypeName ?? type.name.firstUppercased
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

    case
        .scalar(let type as GraphQLNamedType),
        .enum(let type as GraphQLNamedType),
        .inputObject(let type as GraphQLNamedType):

      let typeName = type.qualifiedRootTypeName(
        in: .inputValue,
        config: config
      ).wrappedInGraphQLEnum(ifIsEnumType: self)

      return inNullable ? "GraphQLNullable<\(typeName)>" : typeName

    case let .nonNull(ofType):
      return ofType.renderAsInputValue(inNullable: false, config: config)

    case let .list(ofType):
      let typeName = "[\(ofType.renderAsInputValue(inNullable: true, config: config))]"
      return inNullable ? "GraphQLNullable<\(typeName)>" : typeName
    }
  }

  // MARK: - Render Inner Type

//  private func renderInnerType(
//    in context: RenderContext,
//    inNullable: Bool,
//    config: ApolloCodegenConfiguration
//  ) -> String {
//    private func renderedAsSelectionSetField(
//      containedInNonNull: Bool,
//      replacingNamedTypeWith newTypeName: String? = nil,
//      config: ApolloCodegenConfiguration
//    ) -> String {
//      switch self {
//      case
//          .entity(let type as GraphQLNamedType),
//          .scalar(let type as GraphQLNamedType),
//          .enum(let type as GraphQLNamedType),
//          .inputObject(let type as GraphQLNamedType):
//
//        let typeName = type.qualifiedRootTypeName(
//          in: .selectionSetField(),
//          replacingNamedTypeWith: newTypeName,
//          config: config
//        )
//
//        return containedInNonNull ? typeName : "\(typeName)?"
//
//      case let .nonNull(ofType):
//        return ofType.renderedAsSelectionSetField(
//          containedInNonNull: true,
//          replacingNamedTypeWith: newTypeName,
//          config: config
//        )
//
//      case let .list(ofType):
//        let rendered = ofType.renderedAsSelectionSetField(
//          containedInNonNull: false,
//          replacingNamedTypeWith: newTypeName,
//          config: config
//        )
//        let inner = "[\(rendered)]"
//
//        return containedInNonNull ? inner : "\(inner)?"
//      }
//    }
//  }

}

extension GraphQLNamedType {

  var testMockFieldTypeName: String {
    if SwiftKeywords.TestMockFieldAbstractTypeNamesToNamespace.contains(name) &&
        self is GraphQLAbstractType {
      return "MockObject.\(swiftName)"
    }

    return swiftName
  }

  fileprivate func qualifiedRootTypeName(
    in context: GraphQLType.RenderContext,
    replacingNamedTypeWith newTypeName: String? = nil,
    config: ApolloCodegenConfiguration
  ) -> String {
    lazy var typeName = { newTypeName ?? self.swiftName.firstUppercased }()

    lazy var schemaModuleName: String = {
      switch self {
      case is GraphQLCompositeType:
        return ""

      case let scalar as GraphQLScalarType where scalar.isSwiftType:
        return ""

      default:
        switch context {
        case .testMockField, .inputValue:
          if !config.output.operations.isInModule {
            fallthrough
          } else {
            return ""
          }

        case .selectionSetField:
          return "\(config.schemaName.firstUppercased)."
        }
      }
    }()

    return "\(schemaModuleName)\(typeName)"
  }
}

fileprivate extension String {
  func wrappedInGraphQLEnum(ifIsEnumType type: GraphQLType) -> String {
    if case .enum = type {
      return "GraphQLEnum<\(self)>"
    } else {
      return self
    }
  }
}
