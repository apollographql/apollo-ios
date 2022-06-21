extension GraphQLNamedType {
  /// Provides a Swift type name for GraphQL-specific type names that are not compatible with Swift.
  var swiftName: String {
    switch name {
    case "Boolean": return "Bool"
    case "Float": return "Double"
    default: return name
    }
  }
}
