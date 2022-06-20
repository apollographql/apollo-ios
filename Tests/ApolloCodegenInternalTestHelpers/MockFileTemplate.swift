import Foundation
@testable import ApolloCodegenLib
import ApolloUtils

public struct MockFileTemplate: TemplateRenderer {
  public var target: TemplateTarget
  public var config: ReferenceWrapped<ApolloCodegenConfiguration>

  public var template: TemplateString {
    TemplateString(
    """
    root {
      nested
    }
    """
    )
  }

  public var detachedTemplate: TemplateString? {
    TemplateString(
    """
    detached {
      nested
    }
    """
    )
  }

  public static func mock(
    target: TemplateTarget,
    config: ApolloCodegenConfiguration = .mock()
  ) -> Self {
    MockFileTemplate(target: target, config: .init(value: config))
  }
}
