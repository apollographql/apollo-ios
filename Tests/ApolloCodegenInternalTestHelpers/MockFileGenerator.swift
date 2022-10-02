import Foundation
@testable import ApolloCodegenLib

public struct MockFileGenerator: FileGenerator {
  public var template: TemplateRenderer
  public var target: FileTarget
  public var fileName: String
  public var fileExtension: String

  public static func mock(
    template: TemplateRenderer,
    target: FileTarget,
    filename: String,
    extension: String = "graphql.swift"
  ) -> Self {
    MockFileGenerator(
      template: template,
      target: target,
      fileName: filename,
      fileExtension: `extension`
    )
  }
}
