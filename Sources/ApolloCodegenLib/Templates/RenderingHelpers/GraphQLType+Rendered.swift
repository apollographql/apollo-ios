extension GraphQLType {

  func rendered(
    containedInNonNull: Bool = false,
    replacingNamedTypeWith newTypeName: String? = nil,
    in schema: IR.Schema
  ) -> String {
    switch self {
    case let .entity(type as GraphQLNamedType),
      let .inputObject(type as GraphQLNamedType):

      let typeName = newTypeName ?? type.swiftName

      return containedInNonNull ? typeName : "\(typeName)?"

    case let .scalar(type):
      let typeName = newTypeName ?? type.swiftName

      return TemplateString(
        "\(if: type.isCustomScalar, "\(schema.name).")\(typeName)\(if: !containedInNonNull, "?")"
      ).description

    case let .enum(type as GraphQLNamedType):
      let typeName = newTypeName ?? type.name
      let enumType = "GraphQLEnum<\(typeName)>"

      return containedInNonNull ? enumType : "\(enumType)?"

    case let .nonNull(ofType):
      return ofType.rendered(containedInNonNull: true, replacingNamedTypeWith: newTypeName, in: schema)

    case let .list(ofType):
      let inner = "[\(ofType.rendered(containedInNonNull: false, replacingNamedTypeWith: newTypeName, in: schema))]"

      return containedInNonNull ? inner : "\(inner)?"
    }
  }

  // MARK: Input Value

  /// Renders the type for use as an input value.
  ///
  /// If the outermost type is nullable, it will be wrapped in a `GraphQLNullable` instead of
  /// an `Optional`.
  func renderAsInputValue(in schema: IR.Schema) -> String {
    return renderAsInputValue(inNullable: true, in: schema)
  }

  private func renderAsInputValue(inNullable: Bool, in schema: IR.Schema) -> String {
    switch self {
    case .entity, .enum, .scalar, .inputObject:
      let typeName = self.rendered(containedInNonNull: true, in: schema)
      return inNullable ? "GraphQLNullable<\(typeName)>" : typeName

    case let .nonNull(ofType):
      return ofType.renderAsInputValue(inNullable: false, in: schema)

    case let .list(ofType):
      let typeName = "[\(ofType.rendered(in: schema))]"
      return inNullable ? "GraphQLNullable<\(typeName)>" : typeName
    }
  }
}
