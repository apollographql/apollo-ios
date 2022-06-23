import Foundation
import ApolloUtils

struct MockObjectTemplate: TemplateRenderer {
  /// IR representation of source [GraphQL Object](https://spec.graphql.org/draft/#sec-Objects).
  let graphqlObject: GraphQLObjectType

  let config: ReferenceWrapped<ApolloCodegenConfiguration>

  let ir: IR

  let target: TemplateTarget = .testMockFile

  var template: TemplateString {
    let objectName = graphqlObject.name.firstUppercased
    let fields: [(name: String, type: String, mockType: String)] = ir.fieldCollector
      .collectedFields(for: graphqlObject)
      .map {
        (
          name: $0.0,
          type: $0.1.rendered(as: .selectionSetField(forceNonNull: true), config: config.value),
          mockType: mockTypeName(for: $0.1)
        )
      }

    return """
    extension \
    \(if: !config.output.schemaTypes.isInModule, "\(ir.schema.name.firstUppercased).")\
    \(objectName): Mockable {
      public static let __mockFields = MockFields()

      public typealias MockValueCollectionType = Array<Mock<\(objectName)>>
    
      public struct MockFields {
        \(fields.map {
          return """
          @Field<\($0.type)>("\($0.name)") public var \($0.name)
          """
        }, separator: "\n")
      }
    }

    public extension Mock where O == \(objectName) {
      convenience init(
        \(fields.map { "\($0.name): \($0.mockType)? = nil" }, separator: ",\n")
      ) {
        self.init()
        \(fields.map { "self.\($0.name) = \($0.name)" }, separator: "\n")
      }
    }
    """
  }

  private func mockTypeName(for type: GraphQLType) -> String {
    func nameReplacement(for type: GraphQLType) -> String? {
      switch type {
      case .entity(let graphQLCompositeType):
        switch graphQLCompositeType {
        case is GraphQLInterfaceType, is GraphQLUnionType:
          return "AnyMock"
        default:
          return "Mock<\(graphQLCompositeType.name)>"
        }
      case .scalar,
          .enum,
          .inputObject:
        return nil
      case .nonNull(let graphQLType),
          .list(let graphQLType):
        return nameReplacement(for: graphQLType)
      }
    }

    return type.rendered(
      as: .selectionSetField(forceNonNull: true),
      replacingNamedTypeWith: nameReplacement(for: type),
      config: config.value
    )
  }
  
}
