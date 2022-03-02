import XCTest
@testable import ApolloCodegenLib
import ApolloCodegenTestSupport
import Nimble

class DependencyManagerFileGeneratorTests: XCTestCase {
  var rootURL: URL!
  var mockFileManager: MockFileManager!
  var config: ApolloCodegenConfiguration!

  override func setUp() {
    super.setUp()

    rootURL = URL(fileURLWithPath: CodegenTestHelper.outputFolderURL().path)
    mockFileManager = MockFileManager(strict: false)
  }

  override func tearDown() {
    config = nil
    mockFileManager = nil
    rootURL = nil

    CodegenTestHelper.deleteExistingOutputFolder()

    super.tearDown()
  }

  // MARK: Helpers

  private func buildConfig(_ moduleType: ApolloCodegenConfiguration.SchemaTypesFileOutput.ModuleType) {
    config = ApolloCodegenConfiguration.mock(moduleType, to: rootURL.path)
  }

  private func buildSubject() throws {
    try DependencyManagerFileGenerator.generate(
      config.output.schemaTypes,
      fileManager: mockFileManager
    )
  }

  // MARK: Dependency Manager Tests

  func test__generate__givenSwiftPackageManagerConfiguration_shouldGeneratePackageFile() throws {
    // given
    buildConfig(.swiftPackageManager(moduleName: "SPMModule"))

    mockFileManager.mock(closure: .createFile({ path, data, attributes in
      expect(path).to(equal(self.rootURL.appendingPathComponent("Package.swift").path))

      return true
    }))

    // then
    try buildSubject()

    expect(self.mockFileManager.allClosuresCalled).to(beTrue())
  }

  func test__generate__givenCocoaPodsConfiguration_shouldGeneratePodspecFile() throws {
    // given
    buildConfig(.cocoaPods(moduleName: "PodsModule"))

    mockFileManager.mock(closure: .createFile({ path, data, attributes in
      expect(path).to(equal(self.rootURL.appendingPathComponent("PodsModule.podspec").path))

      return true
    }))

    // then
    try buildSubject()

    expect(self.mockFileManager.allClosuresCalled).to(beTrue())
  }

  func test__generate__givenUnimplementedConfigurations_shouldThrow() throws {
    expect(try DependencyManagerFileGenerator.generate(
      ApolloCodegenConfiguration.mock(.carthage(moduleName: "TestModule")).output.schemaTypes
    )).to(throwError())

    expect(try DependencyManagerFileGenerator.generate(
      ApolloCodegenConfiguration.mock(.manuallyLinked(namespace: "TestModule")).output.schemaTypes
    )).to(throwError())
  }
}
