/// An abstract base class inherited by unions in a generated GraphQL schema.
/// Each `union` defined in the GraphQL schema will have a subclass of this class generated.
public struct Union: ParentTypeConvertible, Hashable {
  let possibleTypes: [Object]

  init(possibleTypes: [Object]) {
    self.possibleTypes = possibleTypes
  }
}
