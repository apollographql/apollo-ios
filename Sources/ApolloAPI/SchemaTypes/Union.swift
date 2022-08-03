/// An abstract base class inherited by unions in a generated GraphQL schema.
/// Each `union` defined in the GraphQL schema will have a subclass of this class generated.
public struct Union: Hashable {
  let name: String
  let possibleTypes: [Object]

  public init(name: String, possibleTypes: [Object]) {
    self.name = name
    self.possibleTypes = possibleTypes
  }
}
