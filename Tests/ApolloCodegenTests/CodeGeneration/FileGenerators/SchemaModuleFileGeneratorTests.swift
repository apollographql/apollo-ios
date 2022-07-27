import XCTest
@testable import ApolloCodegenLib
import ApolloCodegenInternalTestHelpers
import Nimble
import ApolloUtils

class SchemaModuleFileGeneratorTests: XCTestCase {
  let rootURL = URL(fileURLWithPath: CodegenTestHelper.outputFolderURL().path)
  let mockFileManager = MockApolloFileManager(strict: false)

  override func tearDown() {
    CodegenTestHelper.deleteExistingOutputFolder()

    super.tearDown()
  }

  // MARK: - Tests

  func test__generate__givenModuleType_swiftPackageManager_shouldGeneratePackageFile() throws {
    // given
    let fileURL = rootURL.appendingPathComponent("Package.swift")

    let configuration = ApolloCodegen.ConfigurationContext(config: ApolloCodegenConfiguration.mock(
      .swiftPackageManager,
      to: rootURL.path
    ))

    mockFileManager.mock(closure: .createFile({ path, data, attributes in
      // then
      expect(path).to(equal(fileURL.path))

      return true
    }))

    // when
    try SchemaModuleFileGenerator.generate(configuration, fileManager: mockFileManager)

    // then
    expect(self.mockFileManager.allClosuresCalled).to(beTrue())
  }

  func test__generate__givenModuleType_none_shouldGenerateNamespaceFile() throws {
    // given
    let fileURL = rootURL.appendingPathComponent("ModuleTestSchema.swift")

    let configuration = ApolloCodegen.ConfigurationContext(config: ApolloCodegenConfiguration.mock(
      .embeddedInTarget(name: "MockApplication"),
      schemaName: "ModuleTestSchema",
      to: rootURL.path
    ))

    mockFileManager.mock(closure: .createFile({ path, data, attributes in
      // then
      expect(path).to(equal(fileURL.path))

      return true
    }))

    // when
    try SchemaModuleFileGenerator.generate(configuration, fileManager: mockFileManager)

    // then
    expect(self.mockFileManager.allClosuresCalled).to(beTrue())
  }

  func test__generate__givenModuleType_other_shouldNotGenerateFile() throws {
    // given
    let configuration = ApolloCodegen.ConfigurationContext(config: ApolloCodegenConfiguration.mock(
      .other,
      to: rootURL.path
    ))

    mockFileManager.mock(closure: .createFile({ path, data, attributes in
      // then
      fail("Unexpected module file created at \(path)")

      return true
    }))

    // when
    try SchemaModuleFileGenerator.generate(configuration, fileManager: mockFileManager)

    // then
    expect(self.mockFileManager.allClosuresCalled).to(beFalse())
  }
}
