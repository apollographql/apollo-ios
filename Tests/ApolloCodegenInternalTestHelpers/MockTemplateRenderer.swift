import Foundation
@testable import ApolloCodegenLib

public struct MockTemplateRenderer: TemplateRenderer {
  public var target: ApolloCodegenLib.TemplateTarget
  public var template: ApolloCodegenLib.TemplateString
  public var config: ApolloCodegenLib.ApolloCodegen.ConfigurationContext

  public init(
    target: TemplateTarget,
    template: TemplateString,
    config: ApolloCodegen.ConfigurationContext
  ) {
    self.target = target
    self.template = template
    self.config = config
  }
}
