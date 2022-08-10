import Foundation

struct MockObjectTemplate: TemplateRenderer {
  /// IR representation of source [GraphQL Object](https://spec.graphql.org/draft/#sec-Objects).
  let graphqlObject: GraphQLObjectType

  let config: ApolloCodegen.ConfigurationContext

  let ir: IR

  let target: TemplateTarget = .testMockFile

  typealias TemplateField = (
    responseKey: String,
    propertyName: String,
    initializerParameterName: String?,
    type: String,
    mockType: String,
    deprecationReason: String?
  )

  var template: TemplateString {
    let objectName = graphqlObject.name.firstUppercased
    let fields: [TemplateField] = ir.fieldCollector
      .collectedFields(for: graphqlObject)
      .map {
        (
          responseKey: $0.0,
          propertyName: $0.0.asTestMockFieldPropertyName,
          initializerParameterName: $0.0.asTestMockInitializerParameterName,
          type: $0.1.rendered(as: .testMockField(forceNonNull: true), config: config.config),
          mockType: mockTypeName(for: $0.1),
          deprecationReason: $0.deprecationReason
        )
      }

    return """
    public class \(objectName): MockObject {
      public static let objectType: Object = \(config.schemaName).Objects.\(objectName)
      public static let _mockFields = MockFields()
      public typealias MockValueCollectionType = Array<Mock<\(objectName)>>

      public struct MockFields {
        \(fields.map {
          TemplateString("""
          \(ifLet: $0.deprecationReason,
            where: config.options.warningsOnDeprecatedUsage == .include, {
              "@available(*, deprecated, message: \"\($0)\")"
            })
          @Field<\($0.type)>("\($0.responseKey)") public var \($0.propertyName)
          """)
        }, separator: "\n")
      }
    }

    public extension Mock where O == \(objectName) {
      convenience init(
        \(fields.map { """
          \($0.propertyName)\(ifLet: $0.initializerParameterName, {" \($0)"}): \($0.mockType)? = nil
          """ }, separator: ",\n")
      ) {
        self.init()
        \(fields.map { "self.\($0.propertyName) = \($0.initializerParameterName ?? $0.propertyName)" }, separator: "\n")
      }
    }
    
    """
  }

  private func mockTypeName(for type: GraphQLType) -> String {
    func nameReplacement(for type: GraphQLType, forceNonNull: Bool) -> String {
      switch type {
      case .entity(let graphQLCompositeType):
        let mockType: String
        switch graphQLCompositeType {
        case is GraphQLInterfaceType, is GraphQLUnionType:
          mockType = "AnyMock"
        default:
          mockType = "Mock<\(graphQLCompositeType.name.firstUppercased)>"
        }
        return TemplateString("\(mockType)\(if: !forceNonNull, "?")").description
      case .scalar,
          .enum,
          .inputObject:
        return type.rendered(as: .testMockField(forceNonNull: true), config: config.config)
      case .nonNull(let graphQLType):
        return nameReplacement(for: graphQLType, forceNonNull: true)
      case .list(let graphQLType):
        return "[\(nameReplacement(for: graphQLType, forceNonNull: false))]"
      }
    }

    return nameReplacement(for: type, forceNonNull: true)
  }
  
}
