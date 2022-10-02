extension GraphQLCompositeType {
  var schemaTypesNamespace: String {
    switch self {
    case is GraphQLObjectType: return "Objects"
    case is GraphQLInterfaceType: return "Interfaces"
    case is GraphQLUnionType: return "Unions"
    default: fatalError("Invalid parentType for Selection Set: \(self)")
    }
  }
}
