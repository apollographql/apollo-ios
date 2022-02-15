import XCTest
import Nimble
@testable import ApolloCodegenLib
import JavaScriptCore

class InputObjectTemplateTests: XCTestCase {
  var jsVM: JSVirtualMachine!
  var jsContext: JSContext!
  var subject: InputObjectTemplate!

  override func setUp() {
    super.setUp()

    jsVM = JSVirtualMachine()
    jsContext = JSContext(virtualMachine: jsVM)
  }

  override func tearDown() {
    subject = nil
    jsContext = nil
    jsVM = nil

    super.tearDown()
  }

  private func buildSubject(name: String = "MockInput", fields: [GraphQLInputField] = []) {
    subject = InputObjectTemplate(
      graphqlInputObject: GraphQLInputObjectType.mock(name, fields: fields)
    )
  }

  // MARK: Boilerplate Tests

  func test_render_generatesHeaderComment() {
    // given
    buildSubject(fields: [
      GraphQLInputField.mock("field", type: .scalar(.integer()), defaultValue: nil)
    ])

    let expected = """
    // @generated
    // This file was automatically generated and should not be edited.
    
    """

    // when
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test_render_generatesImportStatement() {
    // given
    buildSubject(fields: [
      GraphQLInputField.mock("field", type: .scalar(.integer()), defaultValue: nil)
    ])

    let expected = """
    import ApolloAPI

    """

    // when
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 4, ignoringExtraLines: true))
  }

  // MARK: Casing Tests

  func test__render__givenLowercasedInputObjectField__generatesCorrectlyCasedSwiftDefinition() throws {
    // given
    buildSubject(
      name: "mockInput",
      fields: [GraphQLInputField.mock("field", type: .scalar(.integer()), defaultValue: nil)]
    )

    let expected = "struct MockInput: InputObject {"

    // when
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 6, ignoringExtraLines: true))
  }

  func test__render__givenUppercasedInputObjectField__generatesCorrectlyCasedSwiftDefinition() throws {
    // given
    buildSubject(
      name: "MOCKInput",
      fields: [GraphQLInputField.mock("field", type: .scalar(.integer()), defaultValue: nil)]
    )

    let expected = "struct MOCKInput: InputObject {"

    // when
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 6, ignoringExtraLines: true))
  }

  func test__render__givenMixedCaseInputObjectField__generatesCorrectlyCasedSwiftDefinition() throws {
    // given
    buildSubject(
      name: "mOcK_Input",
      fields: [GraphQLInputField.mock("field", type: .scalar(.integer()), defaultValue: nil)]
    )

    let expected = "struct MOcK_Input: InputObject {"

    // when
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 6, ignoringExtraLines: true))
  }

  // MARK: Field Type Tests

  func test__render__givenSingleFieldType__generatesCorrectParameterAndInitializer_withClosingBrace() throws {
    // given
    buildSubject(fields: [
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
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 9, ignoringExtraLines: false))
  }

  func test__render__givenAllPossibleSchemaInputFieldTypes__generatesCorrectParametersAndInitializer() throws {
    // given
    buildSubject(fields: [
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
        enumField: GraphQLNullable<GraphQLEnum<EnumValue>> = nil,
        inputField: GraphQLNullable<InnerInputObject> = nil,
        listField: GraphQLNullable<[String?]> = nil
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

      var enumField: GraphQLNullable<GraphQLEnum<EnumValue>> {
        get { dict["enumField"] }
        set { dict["enumField"] = newValue }
      }

      var inputField: GraphQLNullable<InnerInputObject> {
        get { dict["inputField"] }
        set { dict["inputField"] = newValue }
      }

      var listField: GraphQLNullable<[String?]> {
        get { dict["listField"] }
        set { dict["listField"] = newValue }
      }
    """

    // when
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 9, ignoringExtraLines: true))
  }

  // MARK: Nullable Field Tests

  func test__render__given_NullableField_NoDefault__generates_NullableParameter_InitializerNilDefault() throws {
    // given
    buildSubject(fields: [
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
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 9, ignoringExtraLines: true))
  }

  func test__render__given_NullableField_WithDefault__generates_NullableParameter_NoInitializerDefault() throws {
    // given
    buildSubject(fields: [
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
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 9, ignoringExtraLines: true))
  }

  func test__render__given_NonNullableField_NoDefault__generates_NonNullableNonOptionalParameter_NoInitializerDefault() throws {
    // given
    buildSubject(fields: [
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
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 9, ignoringExtraLines: true))
  }

  func test__render__given_NonNullableField_WithDefault__generates_OptionalParameter_NoInitializerDefault() throws {
    // given
    buildSubject(fields: [
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
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 9, ignoringExtraLines: true))
  }

  func test__render__given_NullableList_NullableItem_NoDefault__generates_NullableParameter_OptionalItem_InitializerNilDefault() throws {
    // given
    buildSubject(fields: [
      GraphQLInputField.mock("nullableListNullableItem", type: .list(.scalar(.string())), defaultValue: nil)
    ])

    let expected = """
      init(
        nullableListNullableItem: GraphQLNullable<[String?]> = nil
      ) {
        dict = InputDict([
          "nullableListNullableItem": nullableListNullableItem
        ])
      }

      var nullableListNullableItem: GraphQLNullable<[String?]> {
    """

    // when
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 9, ignoringExtraLines: true))
  }

  func test__render__given_NullableList_NullableItem_WithDefault__generates_NullableParameter_OptionalItem_NoInitializerDefault() throws {
    // given
    buildSubject(fields: [
      GraphQLInputField.mock("nullableListNullableItemWithDefault", type: .list(.scalar(.string())), defaultValue: JSValue(object: ["val"], in: jsContext))
    ])

    let expected = """
      init(
        nullableListNullableItemWithDefault: GraphQLNullable<[String?]>
      ) {
        dict = InputDict([
          "nullableListNullableItemWithDefault": nullableListNullableItemWithDefault
        ])
      }

      var nullableListNullableItemWithDefault: GraphQLNullable<[String?]> {
    """

    // when
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 9, ignoringExtraLines: true))
  }

  func test__render__given_NullableList_NonNullableItem_NoDefault__generates_NullableParameter_NonOptionalItem_InitializerNilDefault() throws {
    // given
    buildSubject(fields: [
      GraphQLInputField.mock("nullableListNonNullableItem", type: .list(.nonNull(.scalar(.string()))), defaultValue: nil)
    ])

    let expected = """
      init(
        nullableListNonNullableItem: GraphQLNullable<[String]> = nil
      ) {
        dict = InputDict([
          "nullableListNonNullableItem": nullableListNonNullableItem
        ])
      }

      var nullableListNonNullableItem: GraphQLNullable<[String]> {
    """

    // when
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 9, ignoringExtraLines: true))
  }

  func test__render__given_NullableList_NonNullableItem_WithDefault__generates_NullableParameter_NonOptionalItem_NoInitializerDefault() throws {
    // given
    buildSubject(fields: [
      GraphQLInputField.mock("nullableListNonNullableItemWithDefault", type: .list(.nonNull(.scalar(.string()))), defaultValue: JSValue(object: ["val"], in: jsContext))
    ])

    let expected = """
      init(
        nullableListNonNullableItemWithDefault: GraphQLNullable<[String]>
      ) {
        dict = InputDict([
          "nullableListNonNullableItemWithDefault": nullableListNonNullableItemWithDefault
        ])
      }

      var nullableListNonNullableItemWithDefault: GraphQLNullable<[String]> {
    """

    // when
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 9, ignoringExtraLines: true))
  }

  func test__render__given_NonNullableList_NullableItem_NoDefault__generates_NonNullableNonOptionalParameter_OptionalItem_NoInitializerDefault() throws {
    // given
    buildSubject(fields: [
      GraphQLInputField.mock("nonNullableListNullableItem", type: .nonNull(.list(.scalar(.string()))), defaultValue: nil)
    ])

    let expected = """
      init(
        nonNullableListNullableItem: [String?]
      ) {
        dict = InputDict([
          "nonNullableListNullableItem": nonNullableListNullableItem
        ])
      }

      var nonNullableListNullableItem: [String?] {
    """

    // when
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 9, ignoringExtraLines: true))
  }

  func test__render__given_NonNullableList_NullableItem_WithDefault__generates_OptionalParameter_OptionalItem_NoInitializerDefault() throws {
    // given
    buildSubject(fields: [
      GraphQLInputField.mock("nonNullableListNullableItemWithDefault", type: .nonNull(.list(.scalar(.string()))), defaultValue: JSValue(object: ["val"], in: jsContext))
    ])

    let expected = """
      init(
        nonNullableListNullableItemWithDefault: [String?]?
      ) {
        dict = InputDict([
          "nonNullableListNullableItemWithDefault": nonNullableListNullableItemWithDefault
        ])
      }

      var nonNullableListNullableItemWithDefault: [String?]? {
    """

    // when
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 9, ignoringExtraLines: true))
  }

  func test__render__given_NonNullableList_NonNullableItem_NoDefault__generates_NonNullableNonOptionalParameter_NonOptionalItem_NoInitializerDefault() throws {
    // given
    buildSubject(fields: [
      GraphQLInputField.mock("nonNullableListNonNullableItem", type: .nonNull(.list(.nonNull(.scalar(.string())))), defaultValue: nil)
    ])

    let expected = """
      init(
        nonNullableListNonNullableItem: [String]
      ) {
        dict = InputDict([
          "nonNullableListNonNullableItem": nonNullableListNonNullableItem
        ])
      }

      var nonNullableListNonNullableItem: [String] {
    """

    // when
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 9, ignoringExtraLines: true))
  }

  func test__render__given_NonNullableList_NonNullableItem_WithDefault__generates_OptionalParameter_NonOptionalItem_NoInitializerDefault() throws {
    // given
    buildSubject(fields: [
      GraphQLInputField.mock("nonNullableListNonNullableItemWithDefault", type: .nonNull(.list(.nonNull(.scalar(.string())))), defaultValue: JSValue(object: ["val"], in: jsContext))
    ])

    let expected = """
      init(
        nonNullableListNonNullableItemWithDefault: [String]?
      ) {
        dict = InputDict([
          "nonNullableListNonNullableItemWithDefault": nonNullableListNonNullableItemWithDefault
        ])
      }

      var nonNullableListNonNullableItemWithDefault: [String]? {
    """

    // when
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 9, ignoringExtraLines: true))
  }

  func test__render__given_NullableListOfNullableEnum_NoDefault__generates_NullableParameter_OptionalItem_InitializerNilDefault() throws {
    // given
    buildSubject(fields: [
      GraphQLInputField.mock("nullableListNullableItem",
                             type: .list(.enum(.mock(name: "EnumValue"))),
                             defaultValue: nil)
    ])

    let expected = """
      init(
        nullableListNullableItem: GraphQLNullable<[GraphQLEnum<EnumValue>?]> = nil
      ) {
        dict = InputDict([
          "nullableListNullableItem": nullableListNullableItem
        ])
      }

      var nullableListNullableItem: GraphQLNullable<[GraphQLEnum<EnumValue>?]> {
    """

    // when
    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 9, ignoringExtraLines: true))
  }
}
