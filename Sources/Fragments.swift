public protocol GraphQLConditionalFragment: GraphQLMappable {
  static var possibleTypes: [String] { get }
  
  init?(reader: GraphQLResultReader, ifTypeMatches typeName: String) throws
}

public extension GraphQLConditionalFragment {
  init?(reader: GraphQLResultReader, ifTypeMatches typeName: String) throws {
    if !Self.possibleTypes.contains(typeName) { return nil }
    
    try self.init(reader: reader)
  }
}

public protocol GraphQLNamedFragment: GraphQLConditionalFragment {
  static var fragmentDefinition: String { get }
}
