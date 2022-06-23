import ApolloUtils
extension GraphQLType {

  func rendered(
    containedInNonNull: Bool = false,
    replacingNamedTypeWith newTypeName: String? = nil,
    config: ReferenceWrapped<ApolloCodegenConfiguration>
  ) -> String {

    var schemaModuleName = ""

    switch self {
    case let .inputObject(type as GraphQLNamedType):
      if !config.output.operations.isInModule {
        schemaModuleName = "\(config.schemaName)."
      }
      fallthrough

    case let .entity(type as GraphQLNamedType):
      let typeName = newTypeName ?? type.swiftName
      return containedInNonNull ? "\(schemaModuleName)\(typeName)" : "\(schemaModuleName)\(typeName)?"

    case let .scalar(type):
      if !type.isSwiftType && !config.output.operations.isInModule {
        schemaModuleName = "\(config.schemaName)."
      }

      let typeName = newTypeName ?? type.swiftName

      return TemplateString(
        "\(schemaModuleName)\(typeName)\(if: !containedInNonNull, "?")"
      ).description

    case let .enum(type as GraphQLNamedType):
      if !config.output.operations.isInModule {
        schemaModuleName = "\(config.schemaName)."
      }

      let typeName = newTypeName ?? type.name
      let enumType = "GraphQLEnum<\(schemaModuleName)\(typeName)>"

      return containedInNonNull ? enumType : "\(enumType)?"

    case let .nonNull(ofType):
      return ofType.rendered(containedInNonNull: true, replacingNamedTypeWith: newTypeName, config: config)

    case let .list(ofType):
      let inner = "[\(ofType.rendered(containedInNonNull: false, replacingNamedTypeWith: newTypeName, config: config))]"

      return containedInNonNull ? inner : "\(inner)?"
    }
  }

  // MARK: Input Value

  /// Renders the type for use as an input value.
  ///
  /// If the outermost type is nullable, it will be wrapped in a `GraphQLNullable` instead of
  /// an `Optional`.
  func renderAsInputValue(config: ReferenceWrapped<ApolloCodegenConfiguration>) -> String {
    return renderAsInputValue(inNullable: true, config: config)
  }

  private func renderAsInputValue(
    inNullable: Bool,
    config: ReferenceWrapped<ApolloCodegenConfiguration>
  ) -> String {
    switch self {
    case .entity, .enum, .scalar, .inputObject:
      let typeName = self.rendered(containedInNonNull: true, config: config)
      return inNullable ? "GraphQLNullable<\(typeName)>" : typeName

    case let .nonNull(ofType):
      return ofType.renderAsInputValue(inNullable: false, config: config)

    case let .list(ofType):
      let typeName = "[\(ofType.rendered(config: config))]"
      return inNullable ? "GraphQLNullable<\(typeName)>" : typeName
    }
  }
}
