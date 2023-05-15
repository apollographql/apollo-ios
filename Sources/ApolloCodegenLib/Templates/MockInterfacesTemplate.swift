import Foundation
import OrderedCollections

struct MockInterfacesTemplate: TemplateRenderer {

  let graphQLInterfaces: OrderedSet<GraphQLInterfaceType>

  let config: ApolloCodegen.ConfigurationContext

  let target: TemplateTarget = .testMockFile

  var template: TemplateString {
    TemplateString("""
    \(accessControlModifier(for: .parent))extension MockObject {
      \(graphQLInterfaces.map {
        "typealias \($0.name.firstUppercased) = Interface"
      }, separator: "\n")
    }

    """)
  }
}
