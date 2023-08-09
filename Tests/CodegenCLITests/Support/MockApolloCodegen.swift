import Foundation
import CodegenCLI
import ApolloCodegenLib

class MockApolloCodegen: CodegenProvider {
  static var buildHandler: ((ApolloCodegenConfiguration) throws -> Void)? = nil

  static func build(
    with configuration: ApolloCodegenConfiguration,
    withRootURL rootURL: URL?,
    itemsToGenerate: ApolloCodegen.ItemsToGenerate
  ) throws {
    guard let handler = buildHandler else {
      fatalError("You must set buildHandler before calling \(#function)!")
    }

    defer {
      buildHandler = nil
    }

    try handler(configuration)
  }
  
}
