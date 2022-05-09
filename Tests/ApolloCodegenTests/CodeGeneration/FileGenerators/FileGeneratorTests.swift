import XCTest
import Nimble
@testable import ApolloCodegenLib
@testable import ApolloCodegenInternalTestHelpers
import ApolloUtils

class FileGeneratorTests: XCTestCase {
  let fileManager = MockFileManager(strict: false)
  let directoryURL = CodegenTestHelper.outputFolderURL()

  var config: ReferenceWrapped<ApolloCodegenConfiguration>!
  var fileTarget: FileTarget!
  var template: MockFileTemplate!
  var subject: MockFileGenerator!

  override func tearDown() {
    template = nil
    subject = nil
    fileTarget = nil
    config = nil

    super.tearDown()
  }

  // MARK: Helpers

  private func buildConfig() {
    let mockedConfig = ApolloCodegenConfiguration.mock(output: .mock(
      moduleType: .swiftPackageManager,
      schemaName: "TestSchema",
      operations: .inSchemaModule,
      path: directoryURL.path
    ))

    config = ReferenceWrapped(value: mockedConfig)
  }

  private func buildSubject() {
    template = MockFileTemplate(target: .schemaFile)
    fileTarget = .object
    subject = .init(template: template, target: fileTarget, fileName: "lowercasedType.swift")
  }

  // MARK: - Tests

  func test__generate__shouldWriteToCorrectPath() throws {
    // given
    buildConfig()
    buildSubject()

    fileManager.mock(closure: .createFile({ path, data, attributes in
      let expected = self.fileTarget.resolvePath(forConfig: self.config)

      // then
      let actual = URL(fileURLWithPath: path).deletingLastPathComponent().path
      expect(actual).to(equal(expected))

      return true
    }))

    // when
    try subject.generate(forConfig: config, fileManager: fileManager)

    // then
    expect(self.fileManager.allClosuresCalled).to(beTrue())
  }

  func test__generate__shouldFirstUppercaseFilename() throws {
    // given
    buildConfig()
    buildSubject()

    fileManager.mock(closure: .createFile({ path, data, attributes in
      let expected = "LowercasedType.swift"

      // then
      let actual = URL(fileURLWithPath: path).lastPathComponent
      expect(actual).to(equal(expected))

      return true
    }))

    // when
    try subject.generate(forConfig: config, fileManager: fileManager)

    // then
    expect(self.fileManager.allClosuresCalled).to(beTrue())
  }

  func test__generate__shouldWriteRenderedTemplate() throws {
    // given
    buildConfig()
    buildSubject()

    let expectedData = template.render(forConfig: config).data(using: .utf8)

    fileManager.mock(closure: .createFile({ path, data, attributes in
      // then
      expect(data).to(equal(expectedData))

      return true
    }))

    // when
    try subject.generate(forConfig: config, fileManager: fileManager)

    // then
    expect(self.fileManager.allClosuresCalled).to(beTrue())
  }
}
