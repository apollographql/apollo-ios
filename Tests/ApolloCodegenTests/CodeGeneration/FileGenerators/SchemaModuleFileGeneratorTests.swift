import XCTest
@testable import ApolloCodegenLib
import ApolloCodegenTestSupport
import Nimble

class SchemaModuleFileGeneratorTests: XCTestCase {
  override func tearDown() {
    CodegenTestHelper.deleteExistingOutputFolder()

    super.tearDown()
  }

  func test__generate__givenSwiftPackageManagerConfiguration_shouldGenerateManifest() throws {
    // given
    let rootURL = URL(fileURLWithPath: CodegenTestHelper.outputFolderURL().path)
    let fileURL = rootURL.appendingPathComponent("MockAPI/Package.swift")
    let configuration = ApolloCodegenConfiguration.mock(
      .swiftPackageManager(moduleName: "MockAPI"),
      to: rootURL.path
    )
    let mockFileManager = MockFileManager(strict: false)

    mockFileManager.mock(closure: .createFile({ path, data, attributes in
      expect(path).to(equal(fileURL.path))

      return true
    }))

    // then
    try SchemaModuleFileGenerator(configuration.output.schemaTypes)
      .generateFile(fileManager: mockFileManager)

    expect(mockFileManager.allClosuresCalled).to(beTrue())
  }
}
