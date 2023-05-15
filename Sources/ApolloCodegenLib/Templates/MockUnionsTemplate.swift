import Foundation
import OrderedCollections

struct MockUnionsTemplate: TemplateRenderer {

  let graphQLUnions: OrderedSet<GraphQLUnionType>

  let config: ApolloCodegen.ConfigurationContext

  let target: TemplateTarget = .testMockFile

  var template: TemplateString {
    TemplateString("""
    \(accessControlModifier(for: .parent, in: target))extension MockObject {
      \(graphQLUnions.map {
        "typealias \($0.name.firstUppercased) = Union"
      }, separator: "\n")
    }
    
    """)
  }
}
