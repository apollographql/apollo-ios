import Foundation
@testable import ApolloCodegenLib

public struct MockTemplate: TemplateRenderer {
  public var template: TemplateString {
    TemplateString(
    """
    root {
      nested
    }
    """
    )
  }
}
