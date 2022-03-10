import XCTest
import ApolloCodegenTestSupport
@testable import ApolloCodegenLib
import Nimble

class ApolloCodegenConfiguration_ResolvePath_Tests: XCTestCase {
  let directoryURL = CodegenTestHelper.outputFolderURL()

  var config: ApolloCodegenConfiguration.FileOutput!

  private func buildOutputConfig(
    moduleType: ApolloCodegenConfiguration.SchemaTypesFileOutput.ModuleType = .none,
    operations: ApolloCodegenConfiguration.OperationsFileOutput
  ) {
    config = .mock(
      moduleType: moduleType,
      schemaName: "TestAPI",
      operations: operations,
      path: directoryURL.path
    )
  }

  // MARK: OperationsFileOutput.relative
  //
  // Operations written to <.graphql file path>/<subpath?>/file.swift
  // Schema Types written to <schema types path>/<subtype>/file.swift

  func test_resolvePath_givenOperationsRelativeWithSubpath_shouldOutputSchemaObjectToSchemaPath() throws {
    // given
    buildOutputConfig(operations: .relative(subpath: "Generated"))

    let expected: String = directoryURL.appendingPathComponent("Objects").path

    //when
    let actual = config.resolvePath(.object)

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsRelativeWithSubpath_shouldOutputSchemaEnumToSchemaPath() throws {
    // given
    buildOutputConfig(operations: .relative(subpath: "Generated"))

    let expected: String = directoryURL.appendingPathComponent("Enums").path

    //when
    let actual = config.resolvePath(.enum)

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsRelativeWithSubpath_shouldOutputSchemaInterfaceToSchemaPath() throws {
    // given
    buildOutputConfig(operations: .relative(subpath: "Generated"))

    let expected: String = directoryURL.appendingPathComponent("Interfaces").path

    //when
    let actual = config.resolvePath(.interface)

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsRelativeWithSubpath_shouldOutputSchemaUnionToSchemaPath() throws {
    // given
    buildOutputConfig(operations: .relative(subpath: "Generated"))

    let expected: String = directoryURL.appendingPathComponent("Unions").path

    //when
    let actual = config.resolvePath(.union)

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsRelativeWithSubpath_shouldOutputSchemaInputObjectToSchemaPath() throws {
    // given
    buildOutputConfig(operations: .relative(subpath: "Generated"))

    let expected: String = directoryURL.appendingPathComponent("InputObjects").path

    //when
    let actual = config.resolvePath(.inputObject)

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsRelativeWithSubpath_shouldOutputQueryOperationToRelativeSubpath() throws {
    // given
    buildOutputConfig(operations: .relative(subpath: "Generated"))

    let operation = CompilationResult.OperationDefinition.mock(
      type: .query,
      path: directoryURL.appendingPathComponent("Sources/query.graphql").path
    )

    let expected: String = directoryURL.appendingPathComponent("Sources/Generated").path

    //when
    let actual = config.resolvePath(.operation(operation))

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsRelativeWithSubpath_shouldOutputMutationOperationToRelativeSubpath() throws {
    // given
    buildOutputConfig(operations: .relative(subpath: "Generated"))

    let operation = CompilationResult.OperationDefinition.mock(
      type: .mutation,
      path: directoryURL.appendingPathComponent("Sources/mutation.graphql").path
    )

    let expected: String = directoryURL.appendingPathComponent("Sources/Generated").path

    //when
    let actual = config.resolvePath(.operation(operation))

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsRelativeWithSubpath_shouldOutputSubscriptionOperationToRelativeSubpath() throws {
    // given
    buildOutputConfig(operations: .relative(subpath: "Generated"))

    let operation = CompilationResult.OperationDefinition.mock(
      type: .subscription,
      path: directoryURL.appendingPathComponent("Sources/subscription.graphql").path
    )

    let expected: String = directoryURL.appendingPathComponent("Sources/Generated").path

    //when
    let actual = config.resolvePath(.operation(operation))

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsRelativeWithSubpath_shouldOutputFragmentOperationToRelativeSubpath() throws {
    // given
    buildOutputConfig(operations: .relative(subpath: "Generated"))

    let fragment = CompilationResult.FragmentDefinition.mock(
      "TestFragment",
      path: directoryURL.appendingPathComponent("Sources/TestFragment.graphql").path
    )

    let expected: String = directoryURL.appendingPathComponent("Sources/Generated").path

    //when
    let actual = config.resolvePath(.fragment(fragment))

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsRelativeWithSubpath_shouldOutputSchemaToSchemaTypesPath() throws {
    // given
    buildOutputConfig(operations: .relative(subpath: "Generated"))

    let expected: String = directoryURL.path

    //when
    let actual = config.resolvePath(.schema)

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsRelativeNoSubpath_shouldOutputSchemaObjectToSchemaPath() throws {
    // given
    buildOutputConfig(operations: .relative(subpath: nil))

    let expected: String = directoryURL.appendingPathComponent("Objects").path

    //when
    let actual = config.resolvePath(.object)

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsRelativeNoSubpath_shouldOutputSchemaEnumToSchemaPath() throws {
    // given
    buildOutputConfig(operations: .relative(subpath: nil))

    let expected: String = directoryURL.appendingPathComponent("Enums").path

    //when
    let actual = config.resolvePath(.enum)

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsRelativeNoSubpath_shouldOutputSchemaInterfaceToSchemaPath() throws {
    // given
    buildOutputConfig(operations: .relative(subpath: nil))

    let expected: String = directoryURL.appendingPathComponent("Interfaces").path

    //when
    let actual = config.resolvePath(.interface)

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsRelativeNoSubpath_shouldOutputSchemaUnionToSchemaPath() throws {
    // given
    buildOutputConfig(operations: .relative(subpath: nil))

    let expected: String = directoryURL.appendingPathComponent("Unions").path

    //when
    let actual = config.resolvePath(.union)

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsRelativeNoSubpath_shouldOutputSchemaInputObjectToSchemaPath() throws {
    // given
    buildOutputConfig(operations: .relative(subpath: nil))

    let expected: String = directoryURL.appendingPathComponent("InputObjects").path

    //when
    let actual = config.resolvePath(.inputObject)

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsRelativeNoSubpath_shouldOutputQueryOperationToRelativePath() throws {
    // given
    buildOutputConfig(operations: .relative(subpath: nil))

    let operation = CompilationResult.OperationDefinition.mock(
      type: .query,
      path: directoryURL.appendingPathComponent("Sources/query.graphql").path
    )

    let expected: String = directoryURL.appendingPathComponent("Sources").path

    //when
    let actual = config.resolvePath(.operation(operation))

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsRelativeNoSubpath_shouldOutputMutationOperationToRelativePath() throws {
    // given
    buildOutputConfig(operations: .relative(subpath: nil))

    let operation = CompilationResult.OperationDefinition.mock(
      type: .mutation,
      path: directoryURL.appendingPathComponent("Sources/mutation.graphql").path
    )

    let expected: String = directoryURL.appendingPathComponent("Sources").path

    //when
    let actual = config.resolvePath(.operation(operation))

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsRelativeNoSubpath_shouldOutputSubscriptionOperationToRelativePath() throws {
    // given
    buildOutputConfig(operations: .relative(subpath: nil))

    let operation = CompilationResult.OperationDefinition.mock(
      type: .subscription,
      path: directoryURL.appendingPathComponent("Sources/subscription.graphql").path
    )

    let expected: String = directoryURL.appendingPathComponent("Sources").path

    //when
    let actual = config.resolvePath(.operation(operation))

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsRelativeNoSubpath_shouldOutputFragmentOperationToRelativePath() throws {
    // given
    buildOutputConfig(operations: .relative(subpath: nil))

    let fragment = CompilationResult.FragmentDefinition.mock(
      "TestFragment",
      path: directoryURL.appendingPathComponent("Sources/TestFragment.graphql").path
    )

    let expected: String = directoryURL.appendingPathComponent("Sources").path

    //when
    let actual = config.resolvePath(.fragment(fragment))

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsRelativeNoSubpath_shouldOutputSchemaToSchemaTypesPath() throws {
    // given
    buildOutputConfig(operations: .relative(subpath: nil))

    let expected: String = directoryURL.path

    //when
    let actual = config.resolvePath(.schema)

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenFragmentFilenameWithExtension_shouldNotIncludeExtension() throws {
    // given
    let config = ApolloCodegenConfiguration.FileOutput(
      schemaTypes: .init(path: directoryURL.path, schemaName: "API", moduleType: .swiftPackageManager),
      operations: .relative(subpath: nil),
      operationIdentifiersPath: nil
    )

    let fragment = CompilationResult.FragmentDefinition.mock(path: directoryURL.appendingPathComponent("filename.extension").path)

    let expected = directoryURL.path

    // then
    expect(config.resolvePath(.fragment(fragment))).to(equal(expected))
  }

  func test_resolvePath_givenOperationFilenameWithExtension_shouldNotIncludeExtension() throws {
    // given
    let config = ApolloCodegenConfiguration.FileOutput(
      schemaTypes: .init(path: directoryURL.path, schemaName: "API", moduleType: .swiftPackageManager),
      operations: .relative(subpath: nil),
      operationIdentifiersPath: nil
    )

    let operation = CompilationResult.OperationDefinition.mock(path: directoryURL.appendingPathComponent("filename.extension").path)

    let expected = directoryURL.path

    // then
    expect(config.resolvePath(.operation(operation))).to(equal(expected))
  }

  // MARK: OperationsFileOutput.absolute
  //
  // Operations written to <absolute path>/file.swift
  // Schema Types written to <schema types path>/<subtype>/file.swift

  func test_resolvePath_givenOperationsAbsolute_shouldOutputSchemaObjectToSchemaPath() throws {
    // given
    buildOutputConfig(operations: .absolute(path: directoryURL.appendingPathComponent("Generated").path))

    let expected: String = directoryURL.appendingPathComponent("Objects").path

    //when
    let actual = config.resolvePath(.object)

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsAbsolute_shouldOutputSchemaEnumToSchemaPath() throws {
    // given
    buildOutputConfig(operations: .absolute(path: directoryURL.appendingPathComponent("Generated").path))

    let expected: String = directoryURL.appendingPathComponent("Enums").path

    //when
    let actual = config.resolvePath(.enum)

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsAbsolute_shouldOutputSchemaInterfaceToSchemaPath() throws {
    // given
    buildOutputConfig(operations: .absolute(path: directoryURL.appendingPathComponent("Generated").path))

    let expected: String = directoryURL.appendingPathComponent("Interfaces").path

    //when
    let actual = config.resolvePath(.interface)

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsAbsolute_shouldOutputSchemaUnionToSchemaPath() throws {
    // given
    buildOutputConfig(operations: .absolute(path: directoryURL.appendingPathComponent("Generated").path))

    let expected: String = directoryURL.appendingPathComponent("Unions").path

    //when
    let actual = config.resolvePath(.union)

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsAbsolute_shouldOutputSchemaInputObjectToSchemaPath() throws {
    // given
    buildOutputConfig(operations: .absolute(path: directoryURL.appendingPathComponent("Generated").path))

    let expected: String = directoryURL.appendingPathComponent("InputObjects").path

    //when
    let actual = config.resolvePath(.inputObject)

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsAbsolute_shouldOutputQueryOperationToAbsolutePath() throws {
    // given
    buildOutputConfig(operations: .absolute(path: directoryURL.appendingPathComponent("Generated").path))

    let operation = CompilationResult.OperationDefinition.mock(
      type: .query,
      path: directoryURL.appendingPathComponent("Sources").path
    )

    let expected: String = directoryURL.appendingPathComponent("Generated").path

    //when
    let actual = config.resolvePath(.operation(operation))

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsAbsolute_shouldOutputMutationOperationToAbsolutePath() throws {
    // given
    buildOutputConfig(operations: .absolute(path: directoryURL.appendingPathComponent("Generated").path))

    let operation = CompilationResult.OperationDefinition.mock(
      type: .mutation,
      path: directoryURL.appendingPathComponent("Sources").path
    )

    let expected: String = directoryURL.appendingPathComponent("Generated").path

    //when
    let actual = config.resolvePath(.operation(operation))

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsAbsolute_shouldOutputSubscriptionOperationToAbsolutePath() throws {
    // given
    buildOutputConfig(operations: .absolute(path: directoryURL.appendingPathComponent("Generated").path))

    let operation = CompilationResult.OperationDefinition.mock(
      type: .subscription,
      path: directoryURL.appendingPathComponent("Sources").path
    )

    let expected: String = directoryURL.appendingPathComponent("Generated").path

    //when
    let actual = config.resolvePath(.operation(operation))

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsAbsolute_shouldOutputFragmentOperationToAbsolutePath() throws {
    // given
    buildOutputConfig(operations: .absolute(path: directoryURL.appendingPathComponent("Generated").path))

    let fragment = CompilationResult.FragmentDefinition.mock(
      "TestFragment",
      path: directoryURL.appendingPathComponent("Sources").path
    )

    let expected: String = directoryURL.appendingPathComponent("Generated").path

    //when
    let actual = config.resolvePath(.fragment(fragment))

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsAbsolute_shouldOutputSchemaToSchemaTypesPath() throws {
    // given
    buildOutputConfig(operations: .absolute(path: directoryURL.appendingPathComponent("Generated").path))

    let expected: String = directoryURL.path

    //when
    let actual = config.resolvePath(.schema)

    // then
    expect(actual).to(equal(expected))
  }

  // MARK: OperationsFileOutput.inSchemaModule
  //
  // Operations/Fragments written to <schema types path>/<subtype>/file.swift
  // Schema Types written to <schema types path>/Schema/<subtype>/file.swift

  func test_resolvePath_givenOperationsInSchemaModule_shouldOutputSchemaObjectToSchemaSubpath() throws {
    // given
    buildOutputConfig(operations: .inSchemaModule)

    let expected: String = directoryURL.appendingPathComponent("Schema/Objects").path

    //when
    let actual = config.resolvePath(.object)

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsInSchemaModule_shouldOutputSchemaEnumToSchemaSubpath() throws {
    // given
    buildOutputConfig(operations: .inSchemaModule)

    let expected: String = directoryURL.appendingPathComponent("Schema/Enums").path

    //when
    let actual = config.resolvePath(.enum)

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsInSchemaModule_shouldOutputSchemaInterfaceToSchemaSubpath() throws {
    // given
    buildOutputConfig(operations: .inSchemaModule)

    let expected: String = directoryURL.appendingPathComponent("Schema/Interfaces").path

    //when
    let actual = config.resolvePath(.interface)

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsInSchemaModule_shouldOutputSchemaUnionToSchemaSubpath() throws {
    // given
    buildOutputConfig(operations: .inSchemaModule)

    let expected: String = directoryURL.appendingPathComponent("Schema/Unions").path

    //when
    let actual = config.resolvePath(.union)

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsInSchemaModule_shouldOutputSchemaInputObjectToSchemaSubpath() throws {
    // given
    buildOutputConfig(operations: .inSchemaModule)

    let expected: String = directoryURL.appendingPathComponent("Schema/InputObjects").path

    //when
    let actual = config.resolvePath(.inputObject)

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsInSchemaModule_shouldOutputQueryOperationToSubpath() throws {
    // given
    buildOutputConfig(operations: .inSchemaModule)

    let operation = CompilationResult.OperationDefinition.mock(
      type: .query,
      path: directoryURL.appendingPathComponent("Sources").path
    )

    let expected: String = directoryURL.appendingPathComponent("Operations").path

    //when
    let actual = config.resolvePath(.operation(operation))

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsInSchemaModule_shouldOutputMutationOperationToSubpath() throws {
    // given
    buildOutputConfig(operations: .inSchemaModule)

    let operation = CompilationResult.OperationDefinition.mock(
      type: .mutation,
      path: directoryURL.appendingPathComponent("Sources").path
    )

    let expected: String = directoryURL.appendingPathComponent("Operations").path

    //when
    let actual = config.resolvePath(.operation(operation))

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsInSchemaModule_shouldOutputSubscriptionOperationToSubpath() throws {
    // given
    buildOutputConfig(operations: .inSchemaModule)

    let operation = CompilationResult.OperationDefinition.mock(
      type: .subscription,
      path: directoryURL.appendingPathComponent("Sources").path
    )

    let expected: String = directoryURL.appendingPathComponent("Operations").path

    //when
    let actual = config.resolvePath(.operation(operation))

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsInSchemaModule_shouldOutputFragmentOperationToSubpath() throws {
    // given
    buildOutputConfig(operations: .inSchemaModule)

    let fragment = CompilationResult.FragmentDefinition.mock(
      "TestFragment",
      path: directoryURL.appendingPathComponent("Sources").path
    )

    let expected: String = directoryURL.appendingPathComponent("Operations").path

    //when
    let actual = config.resolvePath(.fragment(fragment))

    // then
    expect(actual).to(equal(expected))
  }

  func test_resolvePath_givenOperationsInSchemaModule_shouldOutputSchemaToSubpath() throws {
    // given
    buildOutputConfig(operations: .inSchemaModule)

    let expected: String = directoryURL.appendingPathComponent("Schema").path

    //when
    let actual = config.resolvePath(.schema)

    // then
    expect(actual).to(equal(expected))
  }
}
