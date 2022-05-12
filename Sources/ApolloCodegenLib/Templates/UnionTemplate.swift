import Foundation

/// Provides the format to convert a [GraphQL Union](https://spec.graphql.org/draft/#sec-Unions)
/// into Swift code.
struct UnionTemplate: TemplateRenderer {
  /// Module name.
  let moduleName: String
  /// IR representation of source [GraphQL Union](https://spec.graphql.org/draft/#sec-Unions).
  let graphqlUnion: GraphQLUnionType

  var target: TemplateTarget = .schemaFile

  var template: TemplateString {
    TemplateString(
    """
    public enum \(graphqlUnion.name.firstUppercased): Union, Equatable {
      \(graphqlUnion.types.map({ type in
      "case \(type.name.firstUppercased)(\(type.name.firstUppercased))"
      }), separator: "\n")
      case __unknown(Object)

      public init(_ object: Object) {
        switch object {
        \(graphqlUnion.types.map({ type in
        "case let entity as \(type.name.firstUppercased): self = .\(type.name.firstUppercased)(entity)"
        }), separator: "\n")
        default: self = .__unknown(object)
        }
      }

      public var object: Object {
        switch self {
        case \(graphqlUnion.types.map({ type in
        "let .\(type.name.firstUppercased)(object as Object)"
        }), separator: ",\n     ", terminator: ",")
          let .__unknown(object):
            return object
        }
      }

      public static let possibleTypes: [Object.Type] = [
        \(graphqlUnion.types.map({ type in
          "\(moduleName.firstUppercased).\(type.name.firstUppercased).self"
        }), separator: ",\n")
      ]
    }
    """
    )
  }
}
