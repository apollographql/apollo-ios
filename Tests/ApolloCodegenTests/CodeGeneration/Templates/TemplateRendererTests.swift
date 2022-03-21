import XCTest
@testable import ApolloCodegenLib
@testable import ApolloCodegenTestSupport
import ApolloUtils
import Nimble

class TemplateRendererTests: XCTestCase {
  private var config: ReferenceWrapped<ApolloCodegenConfiguration>!

  override func tearDown() {
    config = nil

    super.tearDown()
  }

  // MARK: Helpers

  private func buildConfig(
    moduleType: ApolloCodegenConfiguration.SchemaTypesFileOutput.ModuleType,
    schemaName: String = "TestSchema"
  ) {
    config = ReferenceWrapped(
      value: ApolloCodegenConfiguration.mock(moduleType, schemaName: schemaName)
    )
  }

  // MARK: Render Tests - Module .swiftPackageManager

  func test__render__givenTemplate_moduleSwiftPackageManager_shouldIncludeHeaderComment() {
    // given
    let template = MockTemplate()

    buildConfig(moduleType: .swiftPackageManager)

    let expected = """
    // @generated
    // This file was automatically generated and should not be edited.

    """

    // when
    let actual = template.render(forConfig: config)

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__render__givenTemplate_moduleSwiftPackageManager_shouldIncludeImportStatement() {
    // given
    let template = MockTemplate()

    buildConfig(moduleType: .swiftPackageManager)

    let expected = """
    import ApolloAPI

    """

    // when
    let actual = template.render(forConfig: config)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 4, ignoringExtraLines: true))
  }

  func test__render__givenTemplate_moduleSwiftPackageManager_shouldIncludeTemplate_notWrappedInNamespace() {
    // given
    let template = MockTemplate()

    buildConfig(moduleType: .swiftPackageManager)

    let expected = """
    root {
      nested
    }
    """

    // when
    let actual = template.render(forConfig: config)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 6, ignoringExtraLines: true))
  }

  // MARK: Render Tests - Module .other

  func test__render__givenTemplate_moduleOther_shouldIncludeHeaderComment() {
    // given
    let template = MockTemplate()

    buildConfig(moduleType: .other)

    let expected = """
    // @generated
    // This file was automatically generated and should not be edited.

    """

    // when
    let actual = template.render(forConfig: config)

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__render__givenTemplate_moduleOther_shouldIncludeImportStatement() {
    // given
    let template = MockTemplate()

    buildConfig(moduleType: .other)

    let expected = """
    import ApolloAPI

    """

    // when
    let actual = template.render(forConfig: config)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 4, ignoringExtraLines: true))
  }

  func test__render__givenTemplate_moduleOther_shouldIncludeTemplate_notWrappedInNamespace() {
    // given
    let template = MockTemplate()

    buildConfig(moduleType: .other)

    let expected = """
    root {
      nested
    }
    """

    // when
    let actual = template.render(forConfig: config)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 6, ignoringExtraLines: true))
  }

  // MARK: Namespace Rendered Tests - Module .none

  func test__render__givenTemplate_moduleNone_shouldIncludeHeaderComment() {
    // given
    let template = MockTemplate()

    buildConfig(moduleType: .none)

    let expected = """
    // @generated
    // This file was automatically generated and should not be edited.

    """

    // when
    let actual = template.render(forConfig: config)

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__render__givenTemplate_moduleNone_shouldIncludeImportStatement() {
    // given
    let template = MockTemplate()

    buildConfig(moduleType: .none)

    let expected = """
    import ApolloAPI

    """

    // when
    let actual = template.render(forConfig: config)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 4, ignoringExtraLines: true))
  }

  func test__render__givenTemplate_moduleNone_shouldIncludeTemplate_wrappedInNamespace() {
    // given
    let template = MockTemplate()

    buildConfig(moduleType: .none)

    let expected = """
    public extension TestSchema {
      root {
        nested
      }
    }
    """

    // when
    let actual = template.render(forConfig: config)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 6, ignoringExtraLines: true))
  }
}
