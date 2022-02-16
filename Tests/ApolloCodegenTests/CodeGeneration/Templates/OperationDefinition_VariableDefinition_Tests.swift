import XCTest
import Nimble
@testable import ApolloCodegenLib

class OperationDefinition_VariableDefinition_Render_Tests: XCTestCase {

  var subject: CompilationResult.VariableDefinition!

  override func setUp() {
    super.setUp()
  }

  override func tearDown() {
    subject = nil

    super.tearDown()
  }

  func test__renderInputValueType_includeDefaultTrue__givenAllInputFieldTypes_nilDefaultValues__generatesCorrectParametersWithoutInitializer() throws {
    // given
    let tests: [(variable: CompilationResult.VariableDefinition, expected: String)] = [
      (
        .mock(
          "stringField",
          type: .scalar(.string()),
          defaultValue: nil
        ),
        "GraphQLNullable<String>"
      ),
      (
        .mock(
          "intField",
          type: .scalar(.integer()),
          defaultValue: nil
        ),
        "GraphQLNullable<Int>"
      ),
      (
        .mock(
          "boolField",
          type: .scalar(.boolean()),
          defaultValue: nil
        ),
        "GraphQLNullable<Bool>"
      ),
      (
        .mock(
          "floatField",
          type: .scalar(.float()),
          defaultValue: nil
        ),
        "GraphQLNullable<Float>"
      ),
      (
        .mock(
          "enumField",
          type: .enum(.mock(name: "EnumValue")),
          defaultValue: nil
        ),
        "GraphQLNullable<GraphQLEnum<EnumValue>>"
      ),
      (
        .mock(
          "inputField",
          type: .inputObject(.mock(
            "InnerInputObject",
            fields: [
              GraphQLInputField.mock("innerStringField", type: .scalar(.string()), defaultValue: nil)
            ]
          )),
          defaultValue: nil
        ),
        "GraphQLNullable<InnerInputObject>"
      ),
      (
        .mock(
          "listField",
          type: .list(.scalar(.string())),
          defaultValue: nil
        ),
        "GraphQLNullable<[String?]>"
      )
    ]

    for test in tests {
      // when
      let actual = test.variable.renderInputValueType(includeDefault: true)

      // then
      expect(actual).to(equal(test.expected))
    }
  }

  func test__renderInputValueType_includeDefaultTrue__givenAllInputFieldTypes_withDefaultValues__generatesCorrectParametersWithInitializer() throws {
    // given
    let tests: [(variable: CompilationResult.VariableDefinition, expected: String)] = [
      (
        .mock(
          "stringField",
          type: .scalar(.string()),
          defaultValue: .string("Value")
        ),
        "GraphQLNullable<String> = \"Value\""
      ),
      (
        .mock(
          "stringFieldNullDefaultValue",
          type: .scalar(.string()),
          defaultValue: .null
        ),
        "GraphQLNullable<String> = .null"
      ),
      (
        .mock(
          "intField",
          type: .scalar(.integer()),
          defaultValue: .int(300)
        ),
        "GraphQLNullable<Int> = 300"
      ),
      (
        .mock(
          "boolField",
          type: .scalar(.boolean()),
          defaultValue: .boolean(true)
        ),
        "GraphQLNullable<Bool> = true"
      ),
      (
        .mock(
          "boolField",
          type: .scalar(.boolean()),
          defaultValue: .boolean(false)
        ),
        "GraphQLNullable<Bool> = false"
      ),
      (
        .mock(
          "floatField",
          type: .scalar(.float()),
          defaultValue: .float(12.3943)
        ),
        "GraphQLNullable<Float> = 12.3943"
      ),
      (
        .mock(
          "enumField",
          type: .enum(.mock(name: "EnumValue")),
          defaultValue: .enum("CaseONE")
        ),
        "GraphQLNullable<GraphQLEnum<EnumValue>> = .init(\"CaseONE\")"
      ),
      (
        .mock(
          "inputField",
          type: .inputObject(.mock(
            "InnerInputObject",
            fields: [
              .mock("innerStringField", type: .scalar(.string()), defaultValue: nil)
            ]
          )),
          defaultValue: .object(["innerStringField": .string("Value")])
        ),
        """
        GraphQLNullable<InnerInputObject> = ["innerStringField": "Value"]
        """
      ),
      (
        .mock(
          "listField",
          type: .list(.scalar(.string())),
          defaultValue: .list([.string("1"), .string("2")])
        ),
        """
        GraphQLNullable<[String?]> = ["1", "2"]
        """
      )
    ]

    for test in tests {
      // when
      let actual = test.variable.renderInputValueType(includeDefault: true)

      // then
      expect(actual).to(equal(test.expected))
    }
  }

  func test__renderInputValueType_includeDefaultTrue__givenNestedInputObject_withDefaultValues__generatesCorrectParametersWithInitializer() throws {
    // given
    subject = .mock(
      "inputField",
      type: .inputObject(.mock(
        "InputObject",
        fields: [
          .mock("innerStringField", type: .scalar(.string()), defaultValue: nil),
          .mock("innerIntField", type: .scalar(.integer()), defaultValue: nil),
          .mock("innerFloatField", type: .scalar(.float()), defaultValue: nil),
          .mock("innerBoolField", type: .scalar(.boolean()), defaultValue: nil),
          .mock("innerListField", type: .list(.scalar(.string())), defaultValue: nil),
          .mock("innerEnumField", type: .enum(.mock(name: "EnumValue")), defaultValue: nil),
          .mock("innerInputObject",
                type: .inputObject(.mock(
                  "InnerInputObject",
                  fields: [
                    .mock("innerStringField", type: .scalar(.string()), defaultValue: nil),
                    .mock("innerListField", type: .list(.scalar(.string())), defaultValue: nil),
                    .mock("innerIntField", type: .scalar(.integer()), defaultValue: nil),
                    .mock("innerEnumField", type: .enum(.mock(name: "EnumValue")), defaultValue: nil),
                  ]
                )),
                defaultValue: nil
               )
        ]
      )),
      defaultValue: .object([
        "innerStringField": .string("ABCD"),
        "innerIntField": .int(123),
        "innerFloatField": .float(12.3456),
        "innerBoolField": .boolean(true),
        "innerListField": .list([.string("A"), .string("B")]),
        "innerEnumField": .enum("CaseONE"),
        "innerInputObject": .object([
          "innerStringField": .string("EFGH"),
          "innerListField": .list([.string("C"), .string("D")]),
        ])
      ])
    )

    let expected = """
    GraphQLNullable<InputObject> = [
      "innerStringField": "ABCD",
      "innerIntField": 123,
      "innerFloatField": 12.3456,
      "innerBoolField": true,
      "innerListField": ["A", "B"],
      "innerEnumField": GraphQLEnum("CaseONE"),
      "innerInputObject": [
        "innerStringField": "EFGH",
        "innerListField": ["C", "D"],
      ]
    ]
    """

    // when
    let actual = subject.renderInputValueType(includeDefault: true)

    // then
    expect(actual).to(equal(expected))
  }

  // MARK: Nullable Field Tests

  func test__renderInputValueType__given_NullableField_NoDefault__generates_NullableParameter_Initializer() throws {
    // given
    subject = .mock("nullable", type: .scalar(.integer()), defaultValue: nil)

    let expected = "GraphQLNullable<Int>"

    // when
    let actual = subject.renderInputValueType(includeDefault: true)

    // then
    expect(actual).to(equal(expected))
  }

  func test__renderInputValueType__given_NullableField_WithDefault__generates_NullableParameter_NoInitializerDefault() throws {
    // given
    subject = .mock("nullableWithDefault", type: .scalar(.integer()), defaultValue: .int(3))

    let expected = "GraphQLNullable<Int> = 3"

    // when
    let actual = subject.renderInputValueType(includeDefault: true)

    // then
    expect(actual).to(equal(expected))
  }

  func test__renderInputValueType_includeDefaultFalse_givenDefaultValue_generatesCorrectParameterNoInitializerDefault() throws {
    // given
    subject = .mock("variable", type: .scalar(.string()), defaultValue: .string("Value"))

    let expected = "GraphQLNullable<String>"

    // when
    let actual = subject.renderInputValueType(includeDefault: false)

    // then
    expect(actual).to(equal(expected))
  }


  func test__renderInputValueType__given_NonNullableField_NoDefault__generates_NonNullableNonOptionalParameter_NoInitializerDefault() throws {
    // given
    subject = .mock("nonNullable", type: .nonNull(.scalar(.integer())), defaultValue: nil)

    let expected = "Int"

    // when
    let actual = subject.renderInputValueType(includeDefault: true)

    // then
    expect(actual).to(equal(expected))
  }

  func test__renderInputValueType__given_NonNullableField_WithDefault__generates_NonNullableNonOptionalParameter_NoInitializerDefault() throws {
    // given
    subject = .mock("nonNullableWithDefault", type: .nonNull(.scalar(.integer())), defaultValue: .int(3))

    let expected = "Int = 3"
    
    // when
    let actual = subject.renderInputValueType(includeDefault: true)

    // then
    expect(actual).to(equal(expected))
  }

  func test__renderInputValueType__given_NullableList_NullableItem_NoDefault__generates_NullableParameter_OptionalItem_NoInitializerDefault() throws {
    // given
    subject = .mock("nullableListNullableItem", type: .list(.scalar(.string())), defaultValue: nil)

    let expected = "GraphQLNullable<[String?]>"

    // when
    let actual = subject.renderInputValueType(includeDefault: true)

    // then
    expect(actual).to(equal(expected))
  }

  func test__renderInputValueType__given_NullableList_NullableItem_WithDefault__generates_NullableParameter_OptionalItem_WithInitializerDefault() throws {
    // given
    subject = .mock("nullableListNullableItemWithDefault",
                    type: .list(.scalar(.string())),
                    defaultValue: .list([.string("val")]))

    let expected = "GraphQLNullable<[String?]> = [\"val\"]"

    // when
    let actual = subject.renderInputValueType(includeDefault: true)

    // then
    expect(actual).to(equal(expected))
  }

  func test__renderInputValueType__given_NullableList_NonNullableItem_NoDefault__generates_NullableParameter_NonOptionalItem_NoInitializerDefault() throws {
    // given
    subject = .mock("nullableListNonNullableItem",
                    type: .list(.nonNull(.scalar(.string()))),
                    defaultValue: nil)

    let expected = "GraphQLNullable<[String]>"

    // when
    let actual = subject.renderInputValueType(includeDefault: true)

    // then
    expect(actual).to(equal(expected))
  }

  func test__renderInputValueType__given_NullableList_NonNullableItem_WithDefault__generates_NullableParameter_NonOptionalItem_WithInitializerDefault() throws {
    // given
    subject = .mock("nullableListNonNullableItemWithDefault", type: .list(.nonNull(.scalar(.string()))), defaultValue: .list([.string("val")]))

    let expected = "GraphQLNullable<[String]> = [\"val\"]"

    // when
    let actual = subject.renderInputValueType(includeDefault: true)

    // then
    expect(actual).to(equal(expected))
  }

  func test__renderInputValueType__given_NonNullableList_NullableItem_NoDefault__generates_NonNullableNonOptionalParameter_OptionalItem_NoInitializerDefault() throws {
    // given
    subject = .mock("nonNullableListNullableItem", type: .nonNull(.list(.scalar(.string()))), defaultValue: nil)

    let expected = "[String?]"

    // when
    let actual = subject.renderInputValueType(includeDefault: true)

    // then
    expect(actual).to(equal(expected))
  }

  func test__renderInputValueType__given_NonNullableList_NullableItem_WithDefault__generates_OptionalParameter_OptionalItem_WithInitializerDefault() throws {
    // given
    subject = .mock("nonNullableListNullableItemWithDefault",
                    type: .nonNull(.list(.scalar(.string()))),
                    defaultValue: .list([.string("val")]))

    let expected = "[String?]? = [\"val\"]"

    // when
    let actual = subject.renderInputValueType(includeDefault: true)

    // then
    expect(actual).to(equal(expected))
  }

  func test__renderInputValueType__given_NonNullableList_NonNullableItem_NoDefault__generates_NonNullableNonOptionalParameter_NonOptionalItem_NoInitializerDefault() throws {
    // given
    subject = .mock("nonNullableListNonNullableItem",
                    type: .nonNull(.list(.nonNull(.scalar(.string())))),
                    defaultValue: nil)

    let expected = "[String]"

    // when
    let actual = subject.renderInputValueType(includeDefault: true)

    // then
    expect(actual).to(equal(expected))
  }

  func test__renderInputValueType__given_NonNullableList_NonNullableItem_WithDefault__generates_OptionalParameter_NonOptionalItem_WithInitializerDefault() throws {
    // given
    subject = .mock("nonNullableListNonNullableItemWithDefault",
                    type: .nonNull(.list(.nonNull(.scalar(.string())))),
                    defaultValue: .list([.string("val")]))

    let expected = "[String]? = [\"val\"]"

    // when
    let actual = subject.renderInputValueType(includeDefault: true)

    // then
    expect(actual).to(equal(expected))
  }

  func test__renderInputValueType__given_NullableListOfNullableEnum_NoDefault__generates_NullableParameter_OptionalItem_NoInitializerNilDefault() throws {
    // given
    subject = .mock("nullableListNullableItem",
                    type: .list(.enum(.mock(name: "EnumValue"))),
                    defaultValue: nil)

    let expected = "GraphQLNullable<[GraphQLEnum<EnumValue>?]>"

    // when
    let actual = subject.renderInputValueType(includeDefault: true)

    // then
    expect(actual).to(equal(expected))
  }

}
