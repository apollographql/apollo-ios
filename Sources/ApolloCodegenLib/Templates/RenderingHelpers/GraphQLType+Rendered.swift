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
    renderType(
      in: .selectionSetField(),
      containedInNonNull: containedInNonNull,
      replacingNamedTypeWith: newTypeName,
      config: config
    )
  }

  // MARK: Mock Object Field

  private func renderedAsTestMockField(
    containedInNonNull: Bool,
    replacingNamedTypeWith newTypeName: String? = nil,
    config: ApolloCodegenConfiguration
  ) -> String {
    renderType(
      in: .testMockField(),
      containedInNonNull: containedInNonNull,
      replacingNamedTypeWith: newTypeName,
      config: config
    )
  }

  // MARK: Input Value

  private func renderAsInputValue(
    inNullable: Bool,
    config: ApolloCodegenConfiguration
  ) -> String {
    switch self {
    case let .nonNull(ofType):
      return ofType.renderAsInputValue(inNullable: false, config: config)

    case let .list(ofType):
      let typeName = "[\(ofType.renderType(in: .inputValue, config: config))]"
      return inNullable ? "GraphQLNullable<\(typeName)>" : typeName

    default:
      let typeName = renderType(in: .inputValue, containedInNonNull: true, config: config)
      return inNullable ? "GraphQLNullable<\(typeName)>" : typeName
    }
  }

  // MARK: - Render Type

  private func renderType(
    in context: RenderContext,
    containedInNonNull: Bool = false,
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
        in: context,
        replacingNamedTypeWith: newTypeName,
        config: config
      ).wrappedInGraphQLEnum(ifIsEnumType: self)

      return containedInNonNull ? typeName : "\(typeName)?"

    case let .nonNull(ofType):
      return ofType.renderType(
        in: context,
        containedInNonNull: true,
        replacingNamedTypeWith: newTypeName,
        config: config
      )

    case let .list(ofType):
      let rendered = ofType.renderType(
        in: context,
        containedInNonNull: false,
        replacingNamedTypeWith: newTypeName,
        config: config
      )
      let inner = "[\(rendered)]"

      return containedInNonNull ? inner : "\(inner)?"
    }
  }

}

extension GraphQLNamedType {

  var testMockFieldTypeName: String {
    if SwiftKeywords.TestMockFieldAbstractTypeNamesToNamespace.contains(name) &&
        self is GraphQLAbstractType {
      return "MockObject.\(formattedName)"
    }

    return formattedName
  }

  fileprivate func qualifiedRootTypeName(
    in context: GraphQLType.RenderContext,
    replacingNamedTypeWith newTypeName: String? = nil,
    config: ApolloCodegenConfiguration
  ) -> String {

    let typeName: String = {
      if case .testMockField = context {
        return newTypeName ?? testMockFieldTypeName.firstUppercased
      } else {
        return newTypeName ?? self.formattedName
      }
    }()

    let schemaModuleName: String = {
      switch self {
      case is GraphQLCompositeType:
        return ""

      case let scalar as GraphQLScalarType where scalar.isSwiftType:
        return ""

      default:
        switch context {
        case .inputValue:
          if !config.output.operations.isInModule {
            fallthrough
          } else {
            return ""
          }

        case .selectionSetField, .testMockField:
          return "\(config.schemaNamespace.firstUppercased)."
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
