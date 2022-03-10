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
    let fileURL = rootURL.appendingPathComponent("Package.swift")

    let configuration = ApolloCodegenConfiguration.mock(
      .swiftPackageManager,
      schemaName: "TestModule",
      to: rootURL.path
    )
    let mockFileManager = MockFileManager(strict: false)

    mockFileManager.mock(closure: .createFile({ path, data, attributes in
      expect(path).to(equal(fileURL.path))

      return true
    }))

    // then
    try SchemaModuleFileGenerator.generate(
      configuration.output.schemaTypes,
      fileManager: mockFileManager
    )

    expect(mockFileManager.allClosuresCalled).to(beTrue())
  }

  func test__generate__givenUnimplementedConfigurations_shouldThrow() throws {
    expect(try SchemaModuleFileGenerator.generate(
      ApolloCodegenConfiguration.mock(.other, schemaName: "TestModule").output.schemaTypes
    )).to(throwError())

    expect(try SchemaModuleFileGenerator.generate(
      ApolloCodegenConfiguration.mock(.none, schemaName: "TestModule").output.schemaTypes
    )).to(throwError())
  }
}
