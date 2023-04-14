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

  func test__availableAttribute__givenDeprecationMessageWithNullCharacter_shouldEscapeNullCharacter() throws {
    // given
    let subject = TemplateString("""
      \(deprecationReason: "message with \0 (escaped null character)", config: config)
      """)

    let expected = #"""
      @available(*, deprecated, message: "message with \0 (escaped null character)")
      """#

    // then
    let actual = subject.description

    expect(actual).to(equalLineByLine(expected))
  }

  func test__availableAttribute__givenDeprecationMessageWithBackslash_shouldEscapeBackslash() throws {
    // given
    let subject = TemplateString("""
      \(deprecationReason: "message with \\ (escaped backslash)", config: config)
      """)

    let expected = #"""
      @available(*, deprecated, message: "message with \\ (escaped backslash)")
      """#

    // then
    let actual = subject.description

    expect(actual).to(equalLineByLine(expected))
  }

  func test__availableAttribute__givenDeprecationMessageWithHorizontalTab_shouldEscapeHorizontalTab() throws {
    // given
    let subject = TemplateString("""
      \(deprecationReason: "message with \t (escaped horizontal tab)", config: config)
      """)

    let expected = #"""
      @available(*, deprecated, message: "message with \t (escaped horizontal tab)")
      """#

    // then
    let actual = subject.description

    expect(actual).to(equalLineByLine(expected))
  }

  func test__availableAttribute__givenDeprecationMessageWithLineFeed_shouldEscapeLineFeed() throws {
    // given
    let subject = TemplateString("""
      \(deprecationReason: "message with \n (escaped line feed)", config: config)
      """)

    let expected = #"""
      @available(*, deprecated, message: "message with \n (escaped line feed)")
      """#

    // then
    let actual = subject.description

    expect(actual).to(equalLineByLine(expected))
  }

  func test__availableAttribute__givenDeprecationMessageWithCarriageReturn_shouldEscapeCarriageReturn() throws {
    // given
    let subject = TemplateString("""
      \(deprecationReason: "message with \r (escaped carriage return)", config: config)
      """)

    let expected = #"""
      @available(*, deprecated, message: "message with \r (escaped carriage return)")
      """#

    // then
    let actual = subject.description

    expect(actual).to(equalLineByLine(expected))
  }

  func test__availableAttribute__givenDeprecationMessageWithDoubleQuote_shouldEscapeDoubleQuote() throws {
    // given
    let subject = TemplateString("""
      \(deprecationReason: "message with \" (escaped double quote)", config: config)
      """)

    let expected = #"""
      @available(*, deprecated, message: "message with \" (escaped double quote)")
      """#

    // then
    let actual = subject.description

    expect(actual).to(equalLineByLine(expected))
  }

  func test__availableAttribute__givenDeprecationMessageWithSingleQuote_shouldEscapeSingleQuote() throws {
    // given
    let subject = TemplateString("""
      \(deprecationReason: "message with \' (escaped single quote)", config: config)
      """)

    let expected = #"""
      @available(*, deprecated, message: "message with \' (escaped single quote)")
      """#

    // then
    let actual = subject.description

    expect(actual).to(equalLineByLine(expected))
  }

  // MARK: Swift #warning Directive Tests

  func test__warningDirective__givenDeprecationMessageWithNullCharacter_shouldEscapeNullCharacter() throws {
    // given
    let subject = TemplateString("""
      \(field: "fieldOne", argument: "argOne", warningReason: "message with \0 (escaped null character)")
      """)

    let expected = #"""
      #warning("Argument 'argOne' of field 'fieldOne' is deprecated. Reason: 'message with \0 (escaped null character)'")
      """#

    // then
    let actual = subject.description

    expect(actual).to(equalLineByLine(expected))
  }

  func test__warningDirective__givenDeprecationMessageWithBackslash_shouldEscapeBackslash() throws {
    // given
    let subject = TemplateString("""
      \(field: "fieldOne", argument: "argOne", warningReason: "message with \\ (escaped backslash)")
      """)

    let expected = #"""
      #warning("Argument 'argOne' of field 'fieldOne' is deprecated. Reason: 'message with \\ (escaped backslash)'")
      """#

    // then
    let actual = subject.description

    expect(actual).to(equalLineByLine(expected))
  }

  func test__warningDirective__givenDeprecationMessageWithHorizontalTab_shouldEscapeHorizontalTab() throws {
    // given
    let subject = TemplateString("""
      \(field: "fieldOne", argument: "argOne", warningReason: "message with \t (escaped horizontal tab)")
      """)

    let expected = #"""
      #warning("Argument 'argOne' of field 'fieldOne' is deprecated. Reason: 'message with \t (escaped horizontal tab)'")
      """#

    // then
    let actual = subject.description

    expect(actual).to(equalLineByLine(expected))
  }

  func test__warningDirective__givenDeprecationMessageWithLineFeed_shouldEscapeLineFeed() throws {
    // given
    let subject = TemplateString("""
      \(field: "fieldOne", argument: "argOne", warningReason: "message with \n (escaped line feed)")
      """)

    let expected = #"""
      #warning("Argument 'argOne' of field 'fieldOne' is deprecated. Reason: 'message with \n (escaped line feed)'")
      """#

    // then
    let actual = subject.description

    expect(actual).to(equalLineByLine(expected))
  }

  func test__warningDirective__givenDeprecationMessageWithCarriageReturn_shouldEscapeCarriageReturn() throws {
    // given
    let subject = TemplateString("""
      \(field: "fieldOne", argument: "argOne", warningReason: "message with \r (escaped carriage return)")
      """)

    let expected = #"""
      #warning("Argument 'argOne' of field 'fieldOne' is deprecated. Reason: 'message with \r (escaped carriage return)'")
      """#

    // then
    let actual = subject.description

    expect(actual).to(equalLineByLine(expected))
  }

  func test__warningDirective__givenDeprecationMessageWithDoubleQuote_shouldEscapeDoubleQuote() throws {
    // given
    let subject = TemplateString("""
      \(field: "fieldOne", argument: "argOne", warningReason: "message with \" (escaped double quote)")
      """)

    let expected = #"""
      #warning("Argument 'argOne' of field 'fieldOne' is deprecated. Reason: 'message with \" (escaped double quote)'")
      """#

    // then
    let actual = subject.description

    expect(actual).to(equalLineByLine(expected))
  }

  func test__warningDirective__givenDeprecationMessageWithSingleQuote_shouldEscapeSingleQuote() throws {
    // given
    let subject = TemplateString("""
      \(field: "fieldOne", argument: "argOne", warningReason: "message with \' (escaped single quote)")
      """)

    let expected = #"""
      #warning("Argument 'argOne' of field 'fieldOne' is deprecated. Reason: 'message with \' (escaped single quote)'")
      """#

    // then
    let actual = subject.description

    expect(actual).to(equalLineByLine(expected))
  }

  // MARK: SDL-to-Generation Test
  //
  // These tests ensure that when given escaped characters in SDL the generation of Swift code works as
  // expected from frontend parsing all the way to rendering of attributes, comments and warnings.
  // There is a test here for all the places that the GraphQL schema supports the @deprecated
  // directive.

  func test__field__givenSDLDeprecationMessageWithDoubleQuotes_shouldEscapeDoubleQuotes() throws {
    // given
    let schemaSDL = #"""
      type Query {
        animal: Animal
      }

      type Animal {
        genus: String @deprecated(reason: "message with all allowed escape characters: \\ and \" and \t and \n and \r.")
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
    let subject = SelectionSetTemplate(
      definition: .operation(operation),
      generateInitializers: true,
      config: config
    )

    let expected = #"""
      @available(*, deprecated, message: "message with all allowed escape characters: \\ and \" and \t and \n and \r.")
    """#

    // then
    let animal = try XCTUnwrap(
      operation[field: "query"]?[field: "animal"] as? IR.EntityField
    )

    let actual = subject.render(field: animal)

    expect(actual).to(equalLineByLine(expected, atLine: 14, ignoringExtraLines: true))
  }

  func test__inputField_givenSDLDeprecationMessageWithDoubleQuotes_shouldEscapeDoubleQuotes() throws {
    // given
    let schemaSDL = #"""
      type Query {
        animal(filter: Filter): Animal
      }

      type Animal {
        name: String
      }

      input Filter {
        genus: String @deprecated(reason: "message with all allowed escape characters: \\ and \" and \t and \n and \r.")
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
          @available(*, deprecated, message: "message with all allowed escape characters: \\ and \" and \t and \n and \r.")
      """#

    // then
    let actual = subject.render()

    expect(actual).to(equalLineByLine(expected, atLine: 23, ignoringExtraLines: true))
  }

  func test__enum__givenSDLDeprecationMessageWithDoubleQuotes_shouldNotEscapeDoubleQuotes() throws {
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
        tiny @deprecated(reason: "message with all allowed escape characters: \\ and \" and \t and \n and \r.")
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
          /// **Deprecated**: message with all allowed escape characters: \\ and \" and \t and \n and \r.
      """#

    // then
    let actual = subject.render()

    expect(actual).to(equalLineByLine(expected, atLine: 8, ignoringExtraLines: true))
  }

  func test__argument__givenSDLDeprecationMessageWithDoubleQuotes_shouldEscapeDoubleQuotes() throws {
    // given
    let schemaSDL = #"""
      type Query {
        animal: Animal
      }

      type Animal {
        species: String
        predators(genus: String @deprecated(reason: "message with all allowed escape characters: \\ and \" and \t and \n and \r."), species: String): Animal
      }
      """#

    let document = """
      query GetAnimal($genus: String) {
        animal {
          species
          predators(genus: $genus) {
            species
          }
        }
      }
      """

    let ir = try IR.mock(schema: schemaSDL, document: document)
    let operation = ir.build(operation: try XCTUnwrap(ir.compilationResult[operation: "GetAnimal"]))
    let subject = SelectionSetTemplate(
      definition: .operation(operation),
      generateInitializers: true,
      config: config
    )

    let expected = #"""
      #warning("Argument 'genus' of field 'predators' is deprecated. Reason: 'message with all allowed escape characters: \\ and \" and \t and \n and \r.'")
    """#

    // then
    let animal = try XCTUnwrap(
      operation[field: "query"]?[field: "animal"] as? IR.EntityField
    )
    let actual = subject.render(field: animal)

    expect(actual).to(equalLineByLine(expected, atLine: 9, ignoringExtraLines: true))
  }

}
