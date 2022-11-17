import XCTest
@testable import ApolloCodegenInternalTestHelpers
@testable import ApolloCodegenLib
import Nimble

class ApolloCodegenConfigurationTests: XCTestCase {

  var directoryURL: URL!
  var filename: String!
  var fileURL: URL!
  var input: ApolloCodegenConfiguration.FileInput!
  var output: ApolloCodegenConfiguration.FileOutput!
  var config: ApolloCodegenConfiguration!

  // MARK: Lifecycle

  override func setUpWithError() throws {
    try super.setUpWithError()
    directoryURL = CodegenTestHelper.outputFolderURL()
      .appendingPathComponent("Configuration")
      .appendingPathComponent(self.testRun!.test.name)

    try ApolloFileManager.default.createDirectoryIfNeeded(atPath: directoryURL.path)

    filename = UUID().uuidString
    fileURL = directoryURL.appendingPathComponent(filename)

    input = .init(schemaPath: fileURL.path)
    output = .init(schemaTypes: .init(path: directoryURL.path, moduleType: .embeddedInTarget(name: "MockApplication")))
  }

  override func tearDownWithError() throws {
    try ApolloFileManager.default.deleteDirectory(atPath: directoryURL.path)

    config = nil
    output = nil
    input = nil
    directoryURL = nil
    fileURL = nil
    filename = nil

    try super.tearDownWithError()
  }

  // MARK: Test Helpers

  func buildConfig() {
    config = ApolloCodegenConfiguration.mock(      
      input: input,
      output: output
    )
  }

  // MARK: Initializer Tests

  func test__initializer__givenMinimalFileInput_buildsDefaults() {
    // given
    let input = ApolloCodegenConfiguration.FileInput()

    // then
    expect(input.schemaSearchPaths).to(equal(["**/*.graphqls"]))
    expect(input.operationSearchPaths).to(equal(["**/*.graphql"]))
  }

  func test__initializer__givenMinimalFileOutput_buildsCorrectDefaults() {
    // given
    let output = ApolloCodegenConfiguration.FileOutput(
      schemaTypes: .init(path: directoryURL.path, moduleType: .other)
    )

    // then
    expect(output.operationIdentifiersPath).to(beNil())
    expect(output.operations).to(equal(.inSchemaModule))
  }

  func test__initializer__givenMinimalApolloCodegenConfiguration_buildsCorrectDefaults() {
    // given
    let config = ApolloCodegenConfiguration(
      schemaName: "MockSchema",
      input: .init(schemaPath: fileURL.path),
      output: .init(schemaTypes: .init(path: directoryURL.path, moduleType: .other))
    )

    // then
    expect(config.options.additionalInflectionRules).to(beEmpty())
    expect(config.options.queryStringLiteralFormat).to(equal(.multiline))
    expect(config.options.deprecatedEnumCases).to(equal(.include))
    expect(config.options.schemaDocumentation).to(equal(.include))
    expect(config.options.apqs).to(equal(.disabled))
  }
}
