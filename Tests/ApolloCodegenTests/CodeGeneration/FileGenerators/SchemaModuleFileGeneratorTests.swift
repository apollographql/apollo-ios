import XCTest
@testable import ApolloCodegenLib
import ApolloCodegenInternalTestHelpers
import Nimble
import ApolloUtils

class SchemaModuleFileGeneratorTests: XCTestCase {
  let rootURL = URL(fileURLWithPath: CodegenTestHelper.outputFolderURL().path)
  let mockFileManager = MockFileManager(strict: false)

  override func tearDown() {
    CodegenTestHelper.deleteExistingOutputFolder()

    super.tearDown()
  }

  // MARK: - Tests

  func test__generate__givenModuleType_swiftPackageManager_shouldGeneratePackageFile() throws {
    // given
    let fileURL = rootURL.appendingPathComponent("Package.swift")

    let configuration = ReferenceWrapped(value: ApolloCodegenConfiguration.mock(
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

    let configuration = ReferenceWrapped(value: ApolloCodegenConfiguration.mock(
      .none,
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
    let configuration = ReferenceWrapped(value: ApolloCodegenConfiguration.mock(
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
