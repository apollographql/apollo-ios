import Foundation
import OrderedCollections

struct MockUnionsTemplate: TemplateRenderer {

  let graphQLUnions: OrderedSet<GraphQLUnionType>

  let config: ApolloCodegen.ConfigurationContext

  let target: TemplateTarget = .testMockFile

  var template: TemplateString {
    TemplateString("""
    \(embeddedAccessControlModifier(target: target))extension MockObject {
      \(graphQLUnions.map {
        "typealias \($0.name.firstUppercased) = Union"
      }, separator: "\n")
    }
    
    """)
  }
}
