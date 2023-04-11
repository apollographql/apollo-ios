import XCTest
import Nimble
@testable import ApolloCodegenLib

final class TemplateString_DeprecationMessage_Tests: XCTestCase {

  let config = ApolloCodegen.ConfigurationContext(config: .mock(
    options: .init(
      warningsOnDeprecatedUsage: .include
    )
  ))

  // MARK: - Swift @available Attribute Tests

  func test__availableAttribute__givenSingleLineDeprecationMessageWithInnerDoubleQuotes_shouldEscapeDoubleQuotes() throws {
    // given
    let subject = TemplateString("""
      \(deprecationReason: "not supported, use \"another thing\" instead.", config: config)
      """)

    let expected = #"""
      @available(*, deprecated, message: "not supported, use \"another thing\" instead.")
      """#

    // then
    let actual = subject.description

    expect(actual).to(equalLineByLine(expected))
  }

  func test__availableAttribute__givenMultiLineDeprecationMessageWithInnerDoubleQuotes_shouldEscapeDoubleQuotes() throws {
    // given
    let subject = TemplateString("""
      \(deprecationReason: "not supported\nuse \"another thing\" instead.", config: config)
      """)

    let expected = #"""
      @available(*, deprecated, message: """
        not supported
        use \"another thing\" instead.
        """)
      """#

    // then
    let actual = subject.description

    expect(actual).to(equalLineByLine(expected))
  }

  // MARK: SDL-to-Generation Test
  //
  // These tests ensure that when given double quotes in SDL the generation of Swift code along with
  // all attributes and warnings are generated as expected.

  func test__render__givenSDLDeprecationMessageWithInnerDoubleQuotes_shouldEscapeDoubleQuotes() throws {
    // given
    let schemaSDL = #"""
      type Query {
        animal: Animal
      }

      type Animal {
        genus: String @deprecated(reason: "not supported, use \"species\" instead.")
        species: String
      }
      """#

    let document = """
      query GetAnimal {
        animal {
          genus
        }
      }
      """

    let ir = try IR.mock(schema: schemaSDL, document: document)
    let operation = ir.build(operation: try XCTUnwrap(ir.compilationResult[operation: "GetAnimal"]))
    let subject = SelectionSetTemplate(generateInitializers: true, config: config)

    let expected = #"""
          @available(*, deprecated, message: "not supported, use \"species\" instead.")
      """#

    // then
    let actual = subject.render(for: operation)

    expect(actual).to(equalLineByLine(expected, atLine: 37, ignoringExtraLines: true))
  }

}
