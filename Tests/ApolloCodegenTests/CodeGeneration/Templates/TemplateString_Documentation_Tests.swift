import XCTest
import Nimble
@testable import ApolloCodegenLib

class TemplateString_Documentation_Tests: XCTestCase {

  // MARK: Helpers

  override func tearDown() {
    super.tearDown()
  }

  func test__appendInterpolation_documentation__givenSingleLineString_returnsStringInDocComment() throws {
    // given
    let documentation = "This is some great documentation!"

    let expected = """
    /// This is some great documentation!
    var test: String = "Test"
    """

    // when
    let actual = TemplateString("""
    \(documentation: documentation)
    var test: String = "Test"
    """).description

    // then
    expect(actual).to(equalLineByLine(expected))
  }

  func test__appendInterpolation_documentation__givenDocumentationIndented_returnsStringInDocComment() throws {
    // given
    let documentation = "This is some great documentation!"

    let expected = """
      /// This is some great documentation!
    var test: String = "Test"
    """

    // when
    let actual = TemplateString("""
      \(documentation: documentation)
    var test: String = "Test"
    """).description

    // then
    expect(actual).to(equalLineByLine(expected))
  }

  func test__appendInterpolation_documentation__givenNil_removesDocumentationLine() throws {
    // given
    let expected = """
    var testA: String = "TestA"
    var testB: String = "TestB"
    """

    // when
    let actual = TemplateString("""
    var testA: String = "TestA"
    \(documentation: nil)
    var testB: String = "TestB"
    """).description

    // then
    expect(actual).to(equalLineByLine(expected))
  }

  func test__appendInterpolation_documentation__givenEmpty_removesDocumentationLine() throws {
    // given
    let expected = """
    var testA: String = "TestA"
    var testB: String = "TestB"
    """

    // when
    let actual = TemplateString("""
    var testA: String = "TestA"
    \(documentation: "")
    var testB: String = "TestB"
    """).description

    // then
    expect(actual).to(equalLineByLine(expected))
  }

  func test__appendInterpolation_documentation__givenStringWithNewlineCharacter_returnsStringInMultilineDocComment() throws {
    // given
    let documentation = "This is some great documentation!\nWith two lines!"

    let expected = """
    /// This is some great documentation!
    /// With two lines!
    var test: String = "Test"
    """

    // when
    let actual = TemplateString("""
    \(documentation: documentation)
    var test: String = "Test"
    """).description

    // then
    expect(actual).to(equalLineByLine(expected))
  }

  func test__appendInterpolation_documentation__givenMultilineString_returnsStringInMultilineDocComment() throws {
    // given
    let documentation = """
    This is some great documentation!
    With two lines!
    """

    let expected = """
    /// This is some great documentation!
    /// With two lines!
    var test: String = "Test"
    """

    // when
    let actual = TemplateString("""
    \(documentation: documentation)
    var test: String = "Test"
    """).description

    // then
    expect(actual).to(equalLineByLine(expected))
  }

  func test__appendInterpolation_documentation__givenMultilineStringWithIndentedLine_returnsStringInMultilineDocComment() throws {
    // given
    let documentation = """
    This is some great documentation!
      With two lines!
    """

    let expected = """
    /// This is some great documentation!
    ///   With two lines!
    var test: String = "Test"
    """

    // when
    let actual = TemplateString("""
    \(documentation: documentation)
    var test: String = "Test"
    """).description

    // then
    expect(actual).to(equalLineByLine(expected))
  }

  func test__appendInterpolation_documentation__givenMultilineStringWithEmptyLine_returnsStringInMultilineDocComment() throws {
    // given
    let documentation = """
    This is some great documentation!

    With empty line!
    """

    let expected = """
    /// This is some great documentation!
    ///
    /// With empty line!
    var test: String = "Test"
    """

    // when
    let actual = TemplateString("""
    \(documentation: documentation)
    var test: String = "Test"
    """).description

    // then
    expect(actual).to(equalLineByLine(expected))
  }

}
