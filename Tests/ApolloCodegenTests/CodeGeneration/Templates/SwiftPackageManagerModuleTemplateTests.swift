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

  private func renderSubject() -> String {
    subject.template.description
  }

  // MARK: Boilerplate Tests

  func test__boilerplate__generatesCorrectSwiftToolsVersion() {
    // given
    subject = .init(moduleName: "testModule", testMockConfig: .none)

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
    subject = .init(moduleName: "testModule", testMockConfig: .none)

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
    subject = .init(moduleName: "testModule", testMockConfig: .none)

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
    subject = .init(moduleName: "testModule", testMockConfig: .none)

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
    subject = .init(moduleName: "testModule", testMockConfig: .none)

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
    subject = .init(moduleName: "testModule", testMockConfig: .none)

    let expected = """
      dependencies: [
        .package(url: "https://github.com/apollographql/apollo-ios.git", from: "1.0.0-alpha.7"),
      ],
    """
    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 16, ignoringExtraLines: true))
  }

  func test__packageDescription__givenTestMockConfig_none_generatesTargets() {
    // given
    subject = .init(moduleName: "testModule", testMockConfig: .none)

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
    subject = .init(moduleName: "testModule", testMockConfig: .absolute(path: "path"))

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
    subject = .init(moduleName: "testModule", testMockConfig: .swiftPackage())

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
    subject = .init(moduleName: "testModule", testMockConfig: .swiftPackage(targetName: "CustomMocks"))

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
