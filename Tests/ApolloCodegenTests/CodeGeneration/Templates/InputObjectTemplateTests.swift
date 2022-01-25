import XCTest
import Nimble
@testable import ApolloCodegenLib
import JavaScriptCore

class InputObjectTemplateTests: XCTestCase {
  var jsVM: JSVirtualMachine!
  var jsContext: JSContext!

  override func setUp() {
    super.setUp()

    jsVM = JSVirtualMachine()
    jsContext = JSContext(virtualMachine: jsVM)
  }

  override func tearDown() {
    jsContext = nil
    jsVM = nil

    super.tearDown()
  }

  // MARK: Casing Tests

  func test_render_givenLowercasedInputObjectField_generatesCorrectlyCasedSwiftDefinition() throws {
    // given
    let graphqlInputObject = GraphQLInputObjectType.mock("mockInput", fields: [
      GraphQLInputField.mock("field", type: .scalar(.integer()), defaultValue: nil)
    ])

    let expected = "struct MockInput: InputObject {"

    // when
    let actual = InputObjectTemplate(graphqlInputObject: graphqlInputObject).render()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test_render_givenUppercasedInputObjectField_generatesCorrectlyCasedSwiftDefinition() throws {
    // given
    let graphqlInputObject = GraphQLInputObjectType.mock("MOCKInput", fields: [
      GraphQLInputField.mock("field", type: .scalar(.integer()), defaultValue: nil)
    ])

    let expected = "struct MOCKInput: InputObject {"

    // when
    let actual = InputObjectTemplate(graphqlInputObject: graphqlInputObject).render()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test_render_givenMixedCaseInputObjectField_generatesCorrectlyCasedSwiftDefinition() throws {
    // given
    let graphqlInputObject = GraphQLInputObjectType.mock("mOcK_Input", fields: [
      GraphQLInputField.mock("field", type: .scalar(.integer()), defaultValue: nil)
    ])

    let expected = "struct MOcK_Input: InputObject {"

    // when
    let actual = InputObjectTemplate(graphqlInputObject: graphqlInputObject).render()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  // MARK: Field Type Tests

  func test_render_givenSingleFieldType_generatesCorrectParameterAndInitializer_withClosingBrace() throws {
    // given
    let graphqlInputObject = GraphQLInputObjectType.mock("MockInput", fields: [
      GraphQLInputField.mock("field", type: .scalar(.string()), defaultValue: nil)
    ])

    let expected = """
      init(
        field: GraphQLNullable<String> = nil
      ) {
        dict = InputDict([
          "field": field
        ])
      }

      var field: GraphQLNullable<String> {
        get { dict["field"] }
        set { dict["field"] = newValue }
      }
    }
    """

    // when
    let actual = InputObjectTemplate(graphqlInputObject: graphqlInputObject).render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 4, ignoringExtraLines: false))
  }

  func test_render_givenAllPossibleSchemaInputFieldTypes_generatesCorrectParametersAndInitializer() throws {
    // given
    let graphqlInputObject = GraphQLInputObjectType.mock("MockInput", fields: [
      GraphQLInputField.mock(
        "stringField",
        type: .scalar(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "intField",
        type: .scalar(.integer()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "boolField",
        type: .scalar(.boolean()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "floatField",
        type: .scalar(.float()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "enumField",
        type: .enum(.mock(name: "EnumValue")),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "inputField",
        type: .inputObject(.mock(
          "InnerInputObject",
          fields: [
            GraphQLInputField.mock("innerStringField", type: .scalar(.string()), defaultValue: nil)
          ]
        )),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "listField",
        type: .list(.scalar(.string())),
        defaultValue: nil
      )
    ])

    let expected = """
      init(
        stringField: GraphQLNullable<String> = nil,
        intField: GraphQLNullable<Int> = nil,
        boolField: GraphQLNullable<Bool> = nil,
        floatField: GraphQLNullable<Float> = nil,
        enumField: GraphQLNullable<EnumValue> = nil,
        inputField: GraphQLNullable<InnerInputObject> = nil,
        listField: GraphQLNullable<[GraphQLNullable<String>]> = nil
      ) {
        dict = InputDict([
          "stringField": stringField,
          "intField": intField,
          "boolField": boolField,
          "floatField": floatField,
          "enumField": enumField,
          "inputField": inputField,
          "listField": listField
        ])
      }

      var stringField: GraphQLNullable<String> {
        get { dict["stringField"] }
        set { dict["stringField"] = newValue }
      }

      var intField: GraphQLNullable<Int> {
        get { dict["intField"] }
        set { dict["intField"] = newValue }
      }

      var boolField: GraphQLNullable<Bool> {
        get { dict["boolField"] }
        set { dict["boolField"] = newValue }
      }

      var floatField: GraphQLNullable<Float> {
        get { dict["floatField"] }
        set { dict["floatField"] = newValue }
      }

      var enumField: GraphQLNullable<EnumValue> {
        get { dict["enumField"] }
        set { dict["enumField"] = newValue }
      }

      var inputField: GraphQLNullable<InnerInputObject> {
        get { dict["inputField"] }
        set { dict["inputField"] = newValue }
      }

      var listField: GraphQLNullable<[GraphQLNullable<String>]> {
        get { dict["listField"] }
        set { dict["listField"] = newValue }
      }
    """

    // when
    let actual = InputObjectTemplate(graphqlInputObject: graphqlInputObject).render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 4, ignoringExtraLines: true))
  }

  // MARK: Nullable Field Tests

  func test_render_givenNullableFieldNoDefault_generatesNullableParameterWithInitializerNilDefault() throws {
    // given
    let graphqlInputObject = GraphQLInputObjectType.mock("MockInput", fields: [
      GraphQLInputField.mock("nullable", type: .scalar(.integer()), defaultValue: nil)
    ])

    let expected = """
      init(
        nullable: GraphQLNullable<Int> = nil
      ) {
        dict = InputDict([
          "nullable": nullable
        ])
      }

      var nullable: GraphQLNullable<Int> {
    """

    // when
    let actual = InputObjectTemplate(graphqlInputObject: graphqlInputObject).render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 4, ignoringExtraLines: true))
  }

  func test_render_givenNullableFieldWithDefault_generatesNullableParameterWithoutInitializerDefault() throws {
    // given
    let graphqlInputObject = GraphQLInputObjectType.mock("MockInput", fields: [
      GraphQLInputField.mock("nullableWithDefault", type: .scalar(.integer()), defaultValue: JSValue(int32: 3, in: jsContext))
    ])

    let expected = """
      init(
        nullableWithDefault: GraphQLNullable<Int>
      ) {
        dict = InputDict([
          "nullableWithDefault": nullableWithDefault
        ])
      }

      var nullableWithDefault: GraphQLNullable<Int> {
    """

    // when
    let actual = InputObjectTemplate(graphqlInputObject: graphqlInputObject).render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 4, ignoringExtraLines: true))
  }

  func test_render_givenNonNullableFieldNoDefault_generatesNonNullableNonOptionalParameterWithoutInitializerDefault() throws {
    // given
    let graphqlInputObject = GraphQLInputObjectType.mock("MockInput", fields: [
      GraphQLInputField.mock("nonNullable", type: .nonNull(.scalar(.integer())), defaultValue: nil)
    ])

    let expected = """
      init(
        nonNullable: Int
      ) {
        dict = InputDict([
          "nonNullable": nonNullable
        ])
      }

      var nonNullable: Int {
    """

    // when
    let actual = InputObjectTemplate(graphqlInputObject: graphqlInputObject).render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 4, ignoringExtraLines: true))
  }

  func test_render_givenNonNullableFieldWithDefault_generatesOptionalParameterWithoutInitializerDefault() throws {
    // given
    let graphqlInputObject = GraphQLInputObjectType.mock("MockInput", fields: [
      GraphQLInputField.mock("nonNullableWithDefault", type: .nonNull(.scalar(.integer())), defaultValue: JSValue(int32: 3, in: jsContext))
    ])

    let expected = """
      init(
        nonNullableWithDefault: Int?
      ) {
        dict = InputDict([
          "nonNullableWithDefault": nonNullableWithDefault
        ])
      }

      var nonNullableWithDefault: Int? {
    """

    // when
    let actual = InputObjectTemplate(graphqlInputObject: graphqlInputObject).render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 4, ignoringExtraLines: true))
  }
}
