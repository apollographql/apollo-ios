import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenInternalTestHelpers

final class TemplateRenderer_AccessControlModifier_Tests: XCTestCase {

  struct TestRenderer: TemplateRenderer {
    var target: ApolloCodegenLib.TemplateTarget
    var template: ApolloCodegenLib.TemplateString { "" }
    var config: ApolloCodegenLib.ApolloCodegen.ConfigurationContext
    var embeddedAccessControlModifier: String { embeddedAccessControlModifier(target: target) }
  }

  let swiftPublic: String = "public "
  let swiftInternal: String = ""

  // MARK: - Helpers

  func buildRenderer(
    target: ApolloCodegenLib.TemplateTarget,
    moduleType: ApolloCodegenConfiguration.SchemaTypesFileOutput.ModuleType,
    operations: ApolloCodegenConfiguration.OperationsFileOutput = .inSchemaModule,
    testMocks: ApolloCodegenConfiguration.TestMockFileOutput = .none
  ) -> TestRenderer {
    TestRenderer(
      target: target,
      config: .init(config: .mock(
        output: .mock(moduleType: moduleType, operations: operations, testMocks: testMocks)
      ))
    )
  }

  // MARK: SchemaFile Target Tests

  func test__accessLevel__givenSchemaFileTargets_whenSchemaModuleTypeIsEmbeddedInTarget_withPublicAccessModifier_shouldRenderAsPublic() throws {
    // given
    for fileType in TemplateTarget.SchemaFileType.allCases {
      // when
      let renderer = buildRenderer(
        target: .schemaFile(type: fileType),
        moduleType: .embeddedInTarget(name: "TestTarget", accessModifier: .public)
      )

      // then
      expect(renderer.embeddedAccessControlModifier).to(equal(swiftPublic))
    }
  }

  func test__accessLevel__givenSchemaFileTargets_whenSchemaModuleTypeIsEmbeddedInTarget_withInternalAccessModifier_shouldRenderAsInternal() throws {
    // given
    for fileType in TemplateTarget.SchemaFileType.allCases {
      // when
      let renderer = buildRenderer(
        target: .schemaFile(type: fileType),
        moduleType: .embeddedInTarget(name: "TestTarget", accessModifier: .internal)
      )

      // then
      expect(renderer.embeddedAccessControlModifier).to(equal(swiftInternal))
    }
  }

  func test__accessLevel__givenSchemaFileTargets_whenSchemaModuleTypeIsSwiftPackageManager_shouldRenderAsPublic() throws {
    // given
    for fileType in TemplateTarget.SchemaFileType.allCases {
      // when
      let renderer = buildRenderer(
        target: .schemaFile(type: fileType),
        moduleType: .swiftPackageManager
      )

      // then
      expect(renderer.embeddedAccessControlModifier).to(equal(swiftPublic))
    }
  }

  func test__accessLevel__givenSchemaFileTargets_whenSchemaModuleTypeIsOther_shouldRenderAsPublic() throws {
    // given
    for fileType in TemplateTarget.SchemaFileType.allCases {
      // when
      let renderer = buildRenderer(
        target: .schemaFile(type: fileType),
        moduleType: .other
      )

      // then
      expect(renderer.embeddedAccessControlModifier).to(equal(swiftPublic))
    }
  }

  // MARK: Operation Target Tests

  func test__accessLevel__givenOperationFileTarget_whenOperationsInSchemaModule_withSchemaModuleTypeEmbeddedInTarget_publicAccessModifier_shouldRenderAsPublic() throws {
    // given + when
    let renderer = buildRenderer(
      target: .operationFile,
      moduleType: .embeddedInTarget(name: "TestTarget", accessModifier: .public),
      operations: .inSchemaModule
    )

    // then
    expect(renderer.embeddedAccessControlModifier).to(equal(swiftPublic))
  }

  func test__accessLevel__givenOperationFileTarget_whenOperationsInSchemaModule_withSchemaModuleTypeEmbeddedInTarget_internalAccessModifier_shouldRenderAsInternal() throws {
    // given + when
    let renderer = buildRenderer(
      target: .operationFile,
      moduleType: .embeddedInTarget(name: "TestTarget", accessModifier: .internal),
      operations: .inSchemaModule
    )

    // then
    expect(renderer.embeddedAccessControlModifier).to(equal(swiftInternal))
  }

  func test__accessLevel__givenOperationFileTarget_whenOperationsInSchemaModule_withSchemaModuleTypeSwiftPackageManager_shouldRenderAsPublic() throws {
    // given + when
    let renderer = buildRenderer(
      target: .operationFile,
      moduleType: .swiftPackageManager,
      operations: .inSchemaModule
    )

    // then
    expect(renderer.embeddedAccessControlModifier).to(equal(swiftPublic))
  }

  func test__accessLevel__givenOperationFileTarget_whenOperationsInSchemaModule_withSchemaModuleTypeOther_shouldRenderAsPublic() throws {
    // given + when
    let renderer = buildRenderer(
      target: .operationFile,
      moduleType: .other,
      operations: .inSchemaModule
    )

    // then
    expect(renderer.embeddedAccessControlModifier).to(equal(swiftPublic))
  }

  func test__accessLevel__givenOperationFileTarget_whenOperationsRelative_withPublicAccessModifier_shouldRenderAsPublic() throws {
    // given + when
    let renderer = buildRenderer(
      target: .operationFile,
      moduleType: .embeddedInTarget(name: "TestTarget", accessModifier: .internal),
      operations: .relative(accessModifier: .public)
    )

    // then
    expect(renderer.embeddedAccessControlModifier).to(equal(swiftPublic))
  }

  func test__accessLevel__givenOperationFileTarget_whenOperationsRelative_withInternalAccessModifier_shouldRenderAsInternal() throws {
    // given + when
    let renderer = buildRenderer(
      target: .operationFile,
      moduleType: .embeddedInTarget(name: "TestTarget", accessModifier: .public),
      operations: .relative(accessModifier: .internal)
    )

    // then
    expect(renderer.embeddedAccessControlModifier).to(equal(swiftInternal))
  }

  func test__accessLevel__givenOperationFileTarget_whenOperationsAbsolute_withPublicAccessModifier_shouldRenderAsPublic() throws {
    // given + when
    let renderer = buildRenderer(
      target: .operationFile,
      moduleType: .embeddedInTarget(name: "TestTarget", accessModifier: .internal),
      operations: .absolute(path: "", accessModifier: .public)
    )

    // then
    expect(renderer.embeddedAccessControlModifier).to(equal(swiftPublic))
  }

  func test__accessLevel__givenOperationFileTarget_whenOperationsAbsolute_withInternalAccessModifier_shouldRenderAsInternal() throws {
    // given + when
    let renderer = buildRenderer(
      target: .operationFile,
      moduleType: .embeddedInTarget(name: "TestTarget", accessModifier: .public),
      operations: .absolute(path: "", accessModifier: .internal)
    )

    // then
    expect(renderer.embeddedAccessControlModifier).to(equal(swiftInternal))
  }

  // MARK: TestMock Target Tests

  func test__accessLevel__givenTestMockFileTarget_whenTestMocksInSwiftPackage_shouldRenderAsPublic() throws {
    // given + when
    let renderer = buildRenderer(
      target: .testMockFile,
      moduleType: .embeddedInTarget(name: "TestTarget", accessModifier: .internal),
      testMocks: .swiftPackage(targetName: "TestMocksTarget")
    )

    // then
    expect(renderer.embeddedAccessControlModifier).to(equal(swiftPublic))
  }

  func test__accessLevel__givenTestMockFileTarget_whenTestMocksAbsolute_withPublicAccessModifier_shouldRenderAsPublic() throws {
    // given + when
    let renderer = buildRenderer(
      target: .testMockFile,
      moduleType: .embeddedInTarget(name: "TestTarget", accessModifier: .internal),
      testMocks: .absolute(path: "", accessModifier: .public)
    )

    // then
    expect(renderer.embeddedAccessControlModifier).to(equal(swiftPublic))
  }

  func test__accessLevel__givenTestMockFileTarget_whenTestMocksAbsolute_withInternalAccessModifier_shouldRenderAsInternal() throws {
    // given + when
    let renderer = buildRenderer(
      target: .testMockFile,
      moduleType: .embeddedInTarget(name: "TestTarget", accessModifier: .public),
      testMocks: .absolute(path: "", accessModifier: .internal)
    )

    // then
    expect(renderer.embeddedAccessControlModifier).to(equal(swiftInternal))
  }
}
