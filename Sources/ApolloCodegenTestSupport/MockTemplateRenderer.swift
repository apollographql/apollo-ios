import Foundation
@testable import ApolloCodegenLib

public struct MockTemplate: TemplateRenderer {
  public var target: TemplateTarget

  public var template: TemplateString {
    TemplateString(
    """
    root {
      nested
    }
    """
    )
  }

  public static func mock(target: TemplateTarget) -> Self {
    MockTemplate(target: target)
  }
}
