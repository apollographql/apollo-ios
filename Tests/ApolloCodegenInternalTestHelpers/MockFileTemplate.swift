import Foundation
@testable import ApolloCodegenLib

public struct MockFileTemplate: TemplateRenderer {
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
    MockFileTemplate(target: target)
  }
}
