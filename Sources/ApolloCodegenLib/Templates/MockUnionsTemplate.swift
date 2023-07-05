import Foundation
import OrderedCollections

struct MockUnionsTemplate: TemplateRenderer {

  let graphQLUnions: OrderedSet<GraphQLUnionType>

  let config: ApolloCodegen.ConfigurationContext

  let target: TemplateTarget = .testMockFile

  var template: TemplateString {
    TemplateString("""
    \(accessControlModifier(for: .parent))extension MockObject {
      \(graphQLUnions.map {
        "typealias \($0.formattedName) = Union"
      }, separator: "\n")
    }
    
    """)
  }
}
