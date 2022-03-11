import XCTest
@testable import ApolloCodegenLib
import ApolloCodegenTestSupport
import Nimble

class SchemaModuleFileGeneratorTests: XCTestCase {
  let rootURL = URL(fileURLWithPath: CodegenTestHelper.outputFolderURL().path)
  let mockFileManager = MockFileManager(strict: false)

  override func tearDown() {
    CodegenTestHelper.deleteExistingOutputFolder()

    super.tearDown()
  }

  func test__generate__givenModuleType_swiftPackageManager_shouldGeneratePackageFile() throws {
    // given
    let fileURL = rootURL.appendingPathComponent("Package.swift")

    let configuration = ApolloCodegenConfiguration.mock(
      .swiftPackageManager,
      to: rootURL.path
    )

    mockFileManager.mock(closure: .createFile({ path, data, attributes in
      expect(path).to(equal(fileURL.path))

      return true
    }))

    // then
    try SchemaModuleFileGenerator.generate(
      configuration.output.schemaTypes,
      fileManager: mockFileManager
    )

    expect(self.mockFileManager.allClosuresCalled).to(beTrue())
  }

  func test__generate__givenModuleType_none_shouldGenerateEnumFile() throws {
    // given
    let fileURL = rootURL.appendingPathComponent("ModuleTestSchema.swift")

    let configuration = ApolloCodegenConfiguration.mock(
      .none,
      schemaName: "ModuleTestSchema",
      to: rootURL.path
    )

    mockFileManager.mock(closure: .createFile({ path, data, attributes in
      expect(path).to(equal(fileURL.path))

      return true
    }))

    // then
    try SchemaModuleFileGenerator.generate(
      configuration.output.schemaTypes,
      fileManager: mockFileManager
    )

    expect(self.mockFileManager.allClosuresCalled).to(beTrue())
  }

  func test__generate__givenModuleType_other_shouldReturn() throws {
    expect(try SchemaModuleFileGenerator.generate(
      ApolloCodegenConfiguration.mock(.other).output.schemaTypes
    )).notTo(throwError())
  }
}
