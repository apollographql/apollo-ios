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
    testMockConfig: ApolloCodegenConfiguration.TestMockFileOutput = .none,
    config: ApolloCodegenConfiguration = .mock(schemaNamespace: "TestModule")
  ) {
    subject = .init(
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
    // swift-tools-version:5.7
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

  func test__packageDescription__givenLowercaseSchemaName_generatesPackageDefinitionWithCapitalizedName() {
    // given
    buildSubject(config: .mock(schemaNamespace: "module"))

    let expected = """
    let package = Package(
      name: "Module",
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 5, ignoringExtraLines: true))
  }

  func test__packageDescription__givenUppercaseSchemaName_generatesPackageDefinitionWithUppercasedName() {
    // given
    buildSubject(config: .mock(schemaNamespace: "MODULE"))

    let expected = """
    let package = Package(
      name: "MODULE",
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 5, ignoringExtraLines: true))
  }

  func test__packageDescription__givenCapitalizedSchemaName_generatesPackageDefinitionWithCapitalizedName() {
    // given
    buildSubject(config: .mock(schemaNamespace: "NewModule"))

    let expected = """
    let package = Package(
      name: "NewModule",
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

  func test__packageDescription__givenLowercasedSchemaName_generatesProductWithCapitalizedName() {
    // given
    buildSubject(config: .mock(schemaNamespace: "newmodule"))

    let expected = """
      products: [
        .library(name: "Newmodule", targets: ["Newmodule"]),
      ],
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 13, ignoringExtraLines: true))
  }

  func test__packageDescription__givenUppercasedSchemaName_generatesProductWithUppercasedName() {
    // given
    buildSubject(config: .mock(schemaNamespace: "NEWMODULE"))

    let expected = """
      products: [
        .library(name: "NEWMODULE", targets: ["NEWMODULE"]),
      ],
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 13, ignoringExtraLines: true))
  }

  func test__packageDescription__givenCapitalizedSchemaName_generatesProductWithCapitalizedName() {
    // given
    buildSubject(config: .mock(schemaNamespace: "NewModule"))

    let expected = """
      products: [
        .library(name: "NewModule", targets: ["NewModule"]),
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
        .package(url: "https://github.com/apollographql/apollo-ios.git", from: "1.0.0"),
      ],
    """
    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 16, ignoringExtraLines: true))
  }

  func test__packageDescription__givenTestMockConfigNone_withLowercaseSchemaName_generatesTargetWithCapitalizedName() {
    // given
    buildSubject(config: .mock(schemaNamespace: "testmodule"))

    let expected = """
      targets: [
        .target(
          name: "Testmodule",
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

  func test__packageDescription__givenTestMockConfigNone_withUppercaseSchemaName_generatesTargetWithUppercasedName() {
    // given
    buildSubject(config: .mock(schemaNamespace: "TEST"))

    let expected = """
      targets: [
        .target(
          name: "TEST",
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

  func test__packageDescription__givenTestMockConfigNone_withCapitalizedSchemaName_generatesTargetWithCapitalizedName() {
    // given
    buildSubject(config: .mock(schemaNamespace: "TestModule"))

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
  
  func test__packageDescription__givenTestMockConfig_swiftPackage_noTargetName_generatesProduct() {
    // given
    buildSubject(testMockConfig: .swiftPackage())

    let expected = """
      products: [
        .library(name: "TestModule", targets: ["TestModule"]),
        .library(name: "TestModuleTestMocks", targets: ["TestModuleTestMocks"]),
      ],
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 13, ignoringExtraLines: true))
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
    expect(actual).to(equalLineByLine(expected, atLine: 20, ignoringExtraLines: true))
  }
  
  func test__packageDescription__givenTestMockConfig_swiftPackage_withTargetName_generatesProduct() {
    // given
    buildSubject(testMockConfig: .swiftPackage(targetName: "CustomMocks"))

    let expected = """
      products: [
        .library(name: "TestModule", targets: ["TestModule"]),
        .library(name: "CustomMocks", targets: ["CustomMocks"]),
      ],
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 13, ignoringExtraLines: true))
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
    expect(actual).to(equalLineByLine(expected, atLine: 20, ignoringExtraLines: true))
  }

  func test__packageDescription__givenTestMockConfig_withLowercaseSchemaName_generatesTestMockTargetWithCapitalizedTargetDependency() {
    // given
    buildSubject(
      testMockConfig: .swiftPackage(targetName: "CustomMocks"),
      config: .mock(schemaNamespace: "testmodule"))

    let expected = """
            .target(name: "Testmodule"),
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 32, ignoringExtraLines: true))
  }

  func test__packageDescription__givenTestMockConfig_withUppercaseSchemaName_generatesTestMockTargetWithUppercaseTargetDependency() {
    // given
    buildSubject(
      testMockConfig: .swiftPackage(targetName: "CustomMocks"),
      config: .mock(schemaNamespace: "MODULE"))

    let expected = """
            .target(name: "MODULE"),
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 32, ignoringExtraLines: true))
  }

  func test__packageDescription__givenTestMockConfig_withCapitalizedSchemaName_generatesTestMockTargetWithCapitalizedTargetDependency() {
    // given
    buildSubject(
      testMockConfig: .swiftPackage(targetName: "CustomMocks"),
      config: .mock(schemaNamespace: "MyModule"))

    let expected = """
            .target(name: "MyModule"),
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 32, ignoringExtraLines: true))
  }

}
