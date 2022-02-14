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
}
