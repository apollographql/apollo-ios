import XCTest
import Nimble
@testable import ApolloCodegenLib
@testable import ApolloCodegenTestSupport
import ApolloUtils

class FileGeneratorTests: XCTestCase {
  let fileManager = MockFileManager(strict: false)
  let directoryURL = CodegenTestHelper.outputFolderURL()

  var config: ReferenceWrapped<ApolloCodegenConfiguration>!
  var template: MockFileTemplate!
  var subject: MockFileGenerator!

  override func tearDown() {
    template = nil
    subject = nil
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
    subject = .init(template: template, target: .object, fileName: "Type.swift")
  }

  // MARK: - Tests

  func test__generate__shouldWriteToCorrectPath() throws {
    // given
    buildConfig()
    buildSubject()

    let expectedPath = directoryURL.appendingPathComponent("Schema/Objects/Type.swift").path

    fileManager.mock(closure: .createFile({ path, data, attributes in
      // then
      expect(path).to(equal(expectedPath))

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
