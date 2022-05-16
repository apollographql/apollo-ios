extension GraphQLType {

  func rendered(
    containedInNonNull: Bool = false,
    replacingNamedTypeWith newTypeName: String? = nil,
    inSchemaNamed schemaName: String
  ) -> String {
    switch self {
    case let .entity(type as GraphQLNamedType),
      let .inputObject(type as GraphQLNamedType):

      let typeName = newTypeName ?? type.swiftName

      return containedInNonNull ? typeName : "\(typeName)?"

    case let .scalar(type):
      let typeName = newTypeName ?? type.swiftName

      return TemplateString(
        "\(if: type.isCustomScalar, "\(schemaName).")\(typeName)\(if: !containedInNonNull, "?")"
      ).description

    case let .enum(type as GraphQLNamedType):
      let typeName = newTypeName ?? type.name
      let enumType = "GraphQLEnum<\(typeName)>"

      return containedInNonNull ? enumType : "\(enumType)?"

    case let .nonNull(ofType):
      return ofType.rendered(containedInNonNull: true, replacingNamedTypeWith: newTypeName, inSchemaNamed: schemaName)

    case let .list(ofType):
      let inner = "[\(ofType.rendered(containedInNonNull: false, replacingNamedTypeWith: newTypeName, inSchemaNamed: schemaName))]"

      return containedInNonNull ? inner : "\(inner)?"
    }
  }  

  // MARK: Input Value

  /// Renders the type for use as an input value.
  ///
  /// If the outermost type is nullable, it will be wrapped in a `GraphQLNullable` instead of
  /// an `Optional`.
  func renderAsInputValue(inSchemaNamed schemaName: String) -> String {
    return renderAsInputValue(inNullable: true, inSchemaNamed: schemaName)
  }

  private func renderAsInputValue(inNullable: Bool, inSchemaNamed schemaName: String) -> String {
    switch self {
    case .entity, .enum, .scalar, .inputObject:
      let typeName = self.rendered(containedInNonNull: true, inSchemaNamed: schemaName)
      return inNullable ? "GraphQLNullable<\(typeName)>" : typeName

    case let .nonNull(ofType):
      return ofType.renderAsInputValue(inNullable: false, inSchemaNamed: schemaName)

    case let .list(ofType):
      let typeName = "[\(ofType.rendered(inSchemaNamed: schemaName))]"
      return inNullable ? "GraphQLNullable<\(typeName)>" : typeName
    }
  }
}
