import Foundation
@testable import ApolloCodegenLib

extension ValidationOptions {

  public static func mock(schemaName: String = "TestSchema") -> Self {
    let config = ApolloCodegenConfiguration.mock(schemaName: schemaName)
    return ValidationOptions(config: config)
  }

}
