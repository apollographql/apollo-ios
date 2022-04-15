import XCTest
@testable import ApolloCodegenLib
import Nimble

class SwiftPackageManagerModuleTemplateTests: XCTestCase {
  let subject = SwiftPackageManagerModuleTemplate(moduleName: "testModule")

  // MARK: Helpers

  private func renderSubject() -> String {
    subject.template.description
  }

  // MARK: Boilerplate Tests

  func test__boilerplate__generatesCorrectSwiftToolsVersion() {
    // given
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
    let expected = """
      dependencies: [
        .package(url: "https://github.com/apollographql/apollo-ios.git", from: "1.0.0-alpha.3"),
      ],
    """
    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 16, ignoringExtraLines: true))
  }

  func test__packageDescription__generatesTargets() {
    // given
    let expected = """
      targets: [
        .target(
          name: "TestModule",
          dependencies: [
            .product(name: "ApolloAPI", package: "apollo-ios"),
          ],
          path: "."
        ),
      ]
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 19, ignoringExtraLines: true))
  }
}
