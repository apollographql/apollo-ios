struct UnionTemplate {
  let moduleName: String
  let graphqlUnion: GraphQLUnionType

  func render() -> String {
    TemplateString(
    """
    \(ImportStatementTemplate.SchemaType.render())

    public enum \(graphqlUnion.name): UnionType, Equatable {
      \(graphqlUnion.types.map({ type in
      "case \(type.name.firstUppercased)(\(type.name.firstUppercased))"
      }), separator: "\n")

      public init?(_ object: Object) {
        switch object {
        \(graphqlUnion.types.map({ type in
        "case let entity as \(type.name.firstUppercased): self = .\(type.name.firstUppercased)(entity)"
        }), separator: "\n")
        default: return nil
        }
      }

      public var object: Object {
        switch self {
        case \(graphqlUnion.types.map({ type in
        "let .\(type.name.firstUppercased)(object as Object)"
        }), separator: ",\n     "):
            return object
        }
      }

      public static let possibleTypes: [Object.Type] = [
        \(graphqlUnion.types.map({ type in
          "\(moduleName).\(type.name.firstUppercased).self"
        }), separator: ",\n")
      ]
    }
    """
    ).value
  }
}
