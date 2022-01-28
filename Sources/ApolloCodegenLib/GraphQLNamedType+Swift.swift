extension GraphQLNamedType {
  /// Provides a Swift type name for GraphQL-specific type names that are not compatible with Swift.
  var swiftName: String {
    if name == "Boolean" { return "Bool" }

    return name
  }
}
