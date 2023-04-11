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
  // These tests ensure that when given double quotes in SDL the generation of Swift code works as
  // expected from frontend parsing all the way to rendering of attributes, comments andwarnings.
  // There is a test here for all the places that the GraphQL schema supports the @deprecated
  // directive.

  func test__field__givenSDLDeprecationMessageWithInnerDoubleQuotes_shouldEscapeDoubleQuotes() throws {
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

  func test__inputField_givenSDLDeprecationMessageWithInnerDoubleQuotes_shouldEscapeDoubleQuotes() throws {
    // given
    let schemaSDL = #"""
      type Query {
        animal(filter: Filter): Animal
      }

      type Animal {
        name: String
      }

      input Filter {
        genus: String @deprecated(reason: "not supported, use \"species\" instead.")
      }
      """#

    let document = """
      query GetAnimal($filter: Filter) {
        animal(filter: $filter) {
          name
        }
      }
      """

    let ir = try IR.mock(schema: schemaSDL, document: document)
    let inputObject = ir.schema.referencedTypes.inputObjects[0]

    let subject = InputObjectTemplate(graphqlInputObject: inputObject, config: config)

    let expected = #"""
          @available(*, deprecated, message: "not supported, use \"species\" instead.")
      """#

    // then
    let actual = subject.render()

    expect(actual).to(equalLineByLine(expected, atLine: 23, ignoringExtraLines: true))
  }

  func test__enum__givenSDLDeprecationMessageWithInnerDoubleQuotes_shouldNotEscapeDoubleQuotes() throws {
    // given
    let schemaSDL = #"""
      type Query {
        animal: Animal
      }

      type Animal {
        name: String
        size: Size
      }

      enum Size {
        tiny @deprecated(reason: "not supported, use \"small\" instead.")
        small
        large
      }
      """#

    let document = """
      query GetAnimal {
        animal {
          name
          size
        }
      }
      """

    let ir = try IR.mock(schema: schemaSDL, document: document)
    let `enum` = ir.schema.referencedTypes.enums[0]

    let subject = EnumTemplate(graphqlEnum: `enum`, config: config)

    let expected = #"""
          /// **Deprecated**: not supported, use "small" instead.
      """#

    // then
    let actual = subject.render()

    expect(actual).to(equalLineByLine(expected, atLine: 8, ignoringExtraLines: true))
  }

}
