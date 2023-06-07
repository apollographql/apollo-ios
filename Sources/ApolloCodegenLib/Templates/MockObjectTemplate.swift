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
    let objectName = graphqlObject.formattedName
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

    let memberAccessControl = accessControlModifier(for: .member)

    return """
    \(accessControlModifier(for: .parent))class \(objectName): MockObject {
      \(memberAccessControl)static let objectType: Object = \(config.schemaNamespace.firstUppercased).Objects.\(objectName)
      \(memberAccessControl)static let _mockFields = MockFields()
      \(memberAccessControl)typealias MockValueCollectionType = Array<Mock<\(objectName)>>

      \(memberAccessControl)struct MockFields {
        \(fields.map {
          TemplateString("""
          \(deprecationReason: $0.deprecationReason, config: config)
          @Field<\($0.type)>("\($0.responseKey)") public var \($0.propertyName)
          """)
        }, separator: "\n")
      }
    }
    \(!fields.isEmpty ?
      TemplateString("""
      
      \(accessControlModifier(for: .parent))\
      extension Mock where O == \(objectName) {
        \(conflictingFieldNameProperties(fields))
        convenience init(
          \(fields.map { """
            \($0.propertyName)\(ifLet: $0.initializerParameterName, {" \($0)"}): \($0.mockType)? = nil
            """ }, separator: ",\n")
        ) {
          self.init()
          \(fields.map { "_set(\($0.initializerParameterName ?? $0.propertyName), for: \\.\($0.propertyName))" }, separator: "\n")
        }
      }
      """) : TemplateString(stringLiteral: "")
    )
    
    """
  }

  private func conflictingFieldNameProperties(_ fields: [TemplateField]) -> TemplateString {
    """
    \(fields.map { """
      \(if: $0.propertyName.isConflictingTestMockFieldName, """
        var \($0.propertyName): \($0.mockType)? {
          get { _data["\($0.propertyName)"] as? \($0.mockType) }
          set { _set(newValue, for: \\.\($0.propertyName)) }
        }
        """)
      """ }, separator: "\n", terminator: "\n")
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
          mockType = "Mock<\(graphQLCompositeType.formattedName)>"
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
