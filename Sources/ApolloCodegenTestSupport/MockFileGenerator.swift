import Foundation
@testable import ApolloCodegenLib

public struct MockFileGenerator: FileGenerator {
  public var template: TemplateRenderer = MockFileTemplate(target: .schemaFile)
  public var target: FileTarget
  public var fileName: String

  public static func mock(target: FileTarget, filename: String) -> Self {
    MockFileGenerator(target: target, fileName: filename)
  }
}
