extension GraphQLType {
  var rendered: String {
    rendered(containedInNonNull: false)
  }

  func rendered(replacingNamedTypeWith newTypeName: String) -> String {
    rendered(containedInNonNull: false, replacingNamedTypeWith: newTypeName)
  }

  private func rendered(
    containedInNonNull: Bool,
    replacingNamedTypeWith newTypeName: String? = nil
  ) -> String {
    switch self {
    case let .entity(type as GraphQLNamedType),
      let .scalar(type as GraphQLNamedType),
      let .inputObject(type as GraphQLNamedType):

      let typeName = newTypeName ?? type.swiftName

      return containedInNonNull ? typeName : "\(typeName)?"

    case let .enum(type as GraphQLNamedType):
      let typeName = newTypeName ?? type.name
      let enumType = "GraphQLEnum<\(typeName)>"

      return containedInNonNull ? enumType : "\(enumType)?"

    case let .nonNull(ofType):
      return ofType.rendered(containedInNonNull: true, replacingNamedTypeWith: newTypeName)

    case let .list(ofType):
      let inner = "[\(ofType.rendered(containedInNonNull: false, replacingNamedTypeWith: newTypeName))]"

      return containedInNonNull ? inner : "\(inner)?"
    }
  }

  // MARK: Input Value

  /// Renders the type for use as an input value.
  ///
  /// If the outermost type is nullable, it will be wrapped in a `GraphQLNullable` instead of
  /// an `Optional`.
  func renderAsInputValue() -> String {
    return renderAsInputValue(inNullable: true)
  }

  private func renderAsInputValue(inNullable: Bool) -> String {
    switch self {
    case .entity, .enum, .scalar, .inputObject:
      let typeName = self.rendered(containedInNonNull: true)
      return inNullable ? "GraphQLNullable<\(typeName)>" : typeName

    case let .nonNull(ofType):
      return ofType.renderAsInputValue(inNullable: false)

    case let .list(ofType):
      let typeName = "[\(ofType.rendered)]"
      return inNullable ? "GraphQLNullable<\(typeName)>" : typeName
    }
  }
}
