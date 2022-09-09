import XCTest
@testable import ApolloCodegenLib
import Nimble

class SwiftPackageManagerModuleTemplateTests: XCTestCase {
  var subject: SwiftPackageManagerModuleTemplate!

  override func tearDown() {
    super.tearDown()
    subject = nil
  }

  // MARK: Helpers

  private func buildSubject(
    moduleName: String = "testModule",
    testMockConfig: ApolloCodegenConfiguration.TestMockFileOutput = .none,
    config: ApolloCodegenConfiguration = .mock()
  ) {
    subject = .init(
      moduleName: moduleName,
      testMockConfig: testMockConfig,
      config: .init(config: config)
    )
  }

  private func renderSubject() -> String {
    subject.template.description
  }

  // MARK: Boilerplate Tests

  func test__boilerplate__generatesCorrectSwiftToolsVersion() {
    // given
    buildSubject()

    let expected = """
    // swift-tools-version:5.3
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__boilerplate__generatesRequiredImports() {
    // given
    buildSubject()

    let expected = """
    import PackageDescription
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 3, ignoringExtraLines: true))
  }

  // MARK: PackageDescription tests

  func test__packageDescription__generatesPackageDefinition() {
    // given
    buildSubject()

    let expected = """
    let package = Package(
      name: "TestModule",
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 5, ignoringExtraLines: true))
  }

  func test__packageDescription__generatesPlatforms() {
    // given
    buildSubject()

    let expected = """
      platforms: [
        .iOS(.v12),
        .macOS(.v10_14),
        .tvOS(.v12),
        .watchOS(.v5),
      ],
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 7, ignoringExtraLines: true))
  }

  func test__packageDescription__generatesProducts() {
    // given
    buildSubject()

    let expected = """
      products: [
        .library(name: "TestModule", targets: ["TestModule"]),
      ],
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 13, ignoringExtraLines: true))
  }

  func test__packageDescription__generatesNoDependencies() {
    // given
    buildSubject()

    let expected = """
      dependencies: [
        .package(url: "https://github.com/apollographql/apollo-ios.git", from: "1.0.0-beta.4"),
      ],
    """
    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 16, ignoringExtraLines: true))
  }

  func test__packageDescription__givenTestMockConfig_none_generatesTargets() {
    // given
    buildSubject()

    let expected = """
      targets: [
        .target(
          name: "TestModule",
          dependencies: [
            .product(name: "ApolloAPI", package: "apollo-ios"),
          ],
          path: "./Sources"
        ),
      ]
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 19, ignoringExtraLines: true))
  }

  func test__packageDescription__givenTestMockConfig_absolute_generatesTargets() {
    // given
    buildSubject(testMockConfig: .absolute(path: "path"))

    let expected = """
      targets: [
        .target(
          name: "TestModule",
          dependencies: [
            .product(name: "ApolloAPI", package: "apollo-ios"),
          ],
          path: "./Sources"
        ),
      ]
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 19, ignoringExtraLines: true))
  }

  func test__packageDescription__givenTestMockConfig_swiftPackage_noTargetName_generatesTargets() {
    // given
    buildSubject(testMockConfig: .swiftPackage())

    let expected = """
      targets: [
        .target(
          name: "TestModule",
          dependencies: [
            .product(name: "ApolloAPI", package: "apollo-ios"),
          ],
          path: "./Sources"
        ),
        .target(
          name: "TestModuleTestMocks",
          dependencies: [
            .product(name: "ApolloTestSupport", package: "apollo-ios"),
            .target(name: "TestModule"),
          ],
          path: "./TestMocks"
        ),
      ]
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 19, ignoringExtraLines: true))
  }

  func test__packageDescription__givenTestMockConfig_swiftPackage_withTargetName_generatesTargets() {
    // given
    buildSubject(testMockConfig: .swiftPackage(targetName: "CustomMocks"))

    let expected = """
      targets: [
        .target(
          name: "TestModule",
          dependencies: [
            .product(name: "ApolloAPI", package: "apollo-ios"),
          ],
          path: "./Sources"
        ),
        .target(
          name: "CustomMocks",
          dependencies: [
            .product(name: "ApolloTestSupport", package: "apollo-ios"),
            .target(name: "TestModule"),
          ],
          path: "./CustomMocks"
        ),
      ]
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 19, ignoringExtraLines: true))
  }

}
