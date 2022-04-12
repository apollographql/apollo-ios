import XCTest
import Nimble
@testable import ApolloCodegenLib

class OperationDefinition_VariableDefinition_Tests: XCTestCase {

  var subject: CompilationResult.VariableDefinition!

  var template: OperationDefinitionTemplate!

  override func setUp() {
    super.setUp()

    let schema = IR.Schema(name: "TestSchema", referencedTypes: .init([]))

    template = OperationDefinitionTemplate(
      operation: .mock(),
      schema: schema,
      config: .init(value: .mock()))
  }

  override func tearDown() {
    subject = nil
    template = nil

    super.tearDown()
  }

  func test__renderOperationVariableProperty_givenDefaultValue_generatesCorrectParameterNoInitializerDefault() throws {
    // given
    subject = .mock("variable", type: .scalar(.string()), defaultValue: .string("Value"))

    let expected = "public var variable: GraphQLNullable<String>"

    // when
    let actual = template.VariableProperties([subject]).description

    // then
    expect(actual).to(equal(expected))
  }

  func test__renderOperationVariableParameter_includeDefaultTrue__givenAllInputFieldTypes_nilDefaultValues__generatesCorrectParametersWithoutInitializer() throws {
    // given
    let tests: [(variable: CompilationResult.VariableDefinition, expected: String)] = [
      (
        .mock(
          "stringField",
          type: .scalar(.string()),
          defaultValue: nil
        ),
        "stringField: GraphQLNullable<String>"
      ),
      (
        .mock(
          "intField",
          type: .scalar(.integer()),
          defaultValue: nil
        ),
        "intField: GraphQLNullable<Int>"
      ),
      (
        .mock(
          "boolField",
          type: .scalar(.boolean()),
          defaultValue: nil
        ),
        "boolField: GraphQLNullable<Bool>"
      ),
      (
        .mock(
          "floatField",
          type: .scalar(.float()),
          defaultValue: nil
        ),
        "floatField: GraphQLNullable<Float>"
      ),
      (
        .mock(
          "enumField",
          type: .enum(.mock(name: "EnumValue")),
          defaultValue: nil
        ),
        "enumField: GraphQLNullable<GraphQLEnum<EnumValue>>"
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
        "inputField: GraphQLNullable<InnerInputObject>"
      ),
      (
        .mock(
          "listField",
          type: .list(.scalar(.string())),
          defaultValue: nil
        ),
        "listField: GraphQLNullable<[String?]>"
      )
    ]

    for test in tests {
      // when
      let actual = template.VariableParameter(test.variable).description

      // then
      expect(actual).to(equal(test.expected))
    }
  }

  func test__renderOperationVariableParameter__givenAllInputFieldTypes_withDefaultValues__generatesCorrectParametersWithInitializer() throws {
    // given
    let tests: [(variable: CompilationResult.VariableDefinition, expected: String)] = [
      (
        .mock(
          "stringField",
          type: .scalar(.string()),
          defaultValue: .string("Value")
        ),
        "stringField: GraphQLNullable<String> = \"Value\""
      ),
      (
        .mock(
          "stringFieldNullDefaultValue",
          type: .scalar(.string()),
          defaultValue: .null
        ),
        "stringFieldNullDefaultValue: GraphQLNullable<String> = .null"
      ),
      (
        .mock(
          "intField",
          type: .scalar(.integer()),
          defaultValue: .int(300)
        ),
        "intField: GraphQLNullable<Int> = 300"
      ),
      (
        .mock(
          "boolField",
          type: .scalar(.boolean()),
          defaultValue: .boolean(true)
        ),
        "boolField: GraphQLNullable<Bool> = true"
      ),
      (
        .mock(
          "boolField",
          type: .scalar(.boolean()),
          defaultValue: .boolean(false)
        ),
        "boolField: GraphQLNullable<Bool> = false"
      ),
      (
        .mock(
          "floatField",
          type: .scalar(.float()),
          defaultValue: .float(12.3943)
        ),
        "floatField: GraphQLNullable<Float> = 12.3943"
      ),
      (
        .mock(
          "enumField",
          type: .enum(.mock(name: "EnumValue")),
          defaultValue: .enum("CaseONE")
        ),
        "enumField: GraphQLNullable<GraphQLEnum<EnumValue>> = .init(.CaseONE)"
      ),
      (
        .mock(
          "enumField",
          type: .nonNull(.enum(.mock(name: "EnumValue"))),
          defaultValue: .enum("CaseONE")
        ),
        "enumField: GraphQLEnum<EnumValue> = .init(.CaseONE)"
      ),
      (
        .mock(
          "listField",
          type: .list(.scalar(.string())),
          defaultValue: .list([.string("1"), .string("2")])
        ),
        """
        listField: GraphQLNullable<[String?]> = ["1", "2"]
        """
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
        inputField: GraphQLNullable<InnerInputObject> = .init(
          InnerInputObject(innerStringField: "Value")
        )
        """
      ),
    ]

    for test in tests {
      // when
      let actual = template.VariableParameter(test.variable).description

      // then
      expect(actual).to(equal(test.expected))
    }
  }

  func test__renderOperationVariableParameter_includeDefaultTrue__givenNullable_nestedInputObject_withDefaultValues__generatesCorrectParametersWithInitializer() throws {
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
                    .mock("innerListField", type: .list(.enum(.mock(name: "EnumList"))), defaultValue: nil),
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
          "innerListField": .list([.enum("CaseTwo"), .enum("CaseThree")]),
        ])
      ])
    )

    let expected = """
    inputField: GraphQLNullable<InputObject> = .init(
      InputObject(
        innerStringField: "ABCD",
        innerIntField: 123,
        innerFloatField: 12.3456,
        innerBoolField: true,
        innerListField: ["A", "B"],
        innerEnumField: .init(.CaseONE),
        innerInputObject: .init(
          InnerInputObject(
            innerStringField: "EFGH",
            innerListField: [.init(.CaseTwo), .init(.CaseThree)]
          )
        )
      )
    )
    """

    // when
    let actual = template.VariableParameter(subject).description

    // then
    expect(actual).to(equalLineByLine(expected))
  }

  func test__renderOperationVariableParameter_includeDefaultTrue__givenNotNullable_nestedInputObject_withDefaultValues__generatesCorrectParametersWithInitializer() throws {
    // given
    subject = .mock(
      "inputField",
      type: .nonNull(.inputObject(.mock(
        "InputObject",
        fields: [
          .mock("innerStringField", type: .scalar(.string()), defaultValue: nil),
          .mock("innerIntField", type: .scalar(.integer()), defaultValue: nil),
          .mock("innerFloatField", type: .scalar(.float()), defaultValue: nil),
          .mock("innerBoolField", type: .scalar(.boolean()), defaultValue: nil),
          .mock("innerListField", type: .list(.scalar(.string())), defaultValue: nil),
          .mock("innerEnumField", type: .enum(.mock(name: "EnumValue")), defaultValue: nil),
          .mock("innerInputObject",
                type: .nonNull(.inputObject(.mock(
                  "InnerInputObject",
                  fields: [
                    .mock("innerStringField", type: .scalar(.string()), defaultValue: nil),
                    .mock("innerListField", type: .list(.enum(.mock(name: "EnumList"))), defaultValue: nil),
                    .mock("innerIntField", type: .scalar(.integer()), defaultValue: nil),
                    .mock("innerEnumField", type: .enum(.mock(name: "EnumValue")), defaultValue: nil),
                  ]
                ))),
                defaultValue: nil
               )
        ]
      ))),
      defaultValue: .object([
        "innerStringField": .string("ABCD"),
        "innerIntField": .int(123),
        "innerFloatField": .float(12.3456),
        "innerBoolField": .boolean(true),
        "innerListField": .list([.string("A"), .string("B")]),
        "innerEnumField": .enum("CaseONE"),
        "innerInputObject": .object([
          "innerStringField": .string("EFGH"),
          "innerListField": .list([.enum("CaseTwo"), .enum("CaseThree")]),
        ])
      ])
    )

    let expected = """
    inputField: InputObject = InputObject(
      innerStringField: "ABCD",
      innerIntField: 123,
      innerFloatField: 12.3456,
      innerBoolField: true,
      innerListField: ["A", "B"],
      innerEnumField: .init(.CaseONE),
      innerInputObject: InnerInputObject(
        innerStringField: "EFGH",
        innerListField: [.init(.CaseTwo), .init(.CaseThree)]
      )
    )
    """

    // when
    let actual = template.VariableParameter(subject).description

    // then
    expect(actual).to(equalLineByLine(expected))
  }

  // MARK: Nullable Field Tests

  func test__renderOperationVariableParameter__given_NullableField_NoDefault__generates_NullableParameter_Initializer() throws {
    // given
    subject = .mock("nullable", type: .scalar(.integer()), defaultValue: nil)

    let expected = "nullable: GraphQLNullable<Int>"

    // when
    let actual = template.VariableParameter(subject).description

    // then
    expect(actual).to(equal(expected))
  }

  func test__renderOperationVariableParameter__given_NullableField_WithDefault__generates_NullableParameter_NoInitializerDefault() throws {
    // given
    subject = .mock("nullableWithDefault", type: .scalar(.integer()), defaultValue: .int(3))

    let expected = "nullableWithDefault: GraphQLNullable<Int> = 3"

    // when
    let actual = template.VariableParameter(subject).description

    // then
    expect(actual).to(equal(expected))
  }

  func test__renderOperationVariableParameter__given_NonNullableField_NoDefault__generates_NonNullableNonOptionalParameter_NoInitializerDefault() throws {
    // given
    subject = .mock("nonNullable", type: .nonNull(.scalar(.integer())), defaultValue: nil)

    let expected = "nonNullable: Int"

    // when
    let actual = template.VariableParameter(subject).description

    // then
    expect(actual).to(equal(expected))
  }

  func test__renderOperationVariableParameter__given_NonNullableField_WithDefault__generates_NonNullableNonOptionalParameter_WithInitializerDefault() throws {
    // given
    subject = .mock("nonNullableWithDefault", type: .nonNull(.scalar(.integer())), defaultValue: .int(3))

    let expected = "nonNullableWithDefault: Int = 3"
    
    // when
    let actual = template.VariableParameter(subject).description

    // then
    expect(actual).to(equal(expected))
  }

  func test__renderOperationVariableParameter__given_NullableList_NullableItem_NoDefault__generates_NullableParameter_OptionalItem_NoInitializerDefault() throws {
    // given
    subject = .mock("nullableListNullableItem", type: .list(.scalar(.string())), defaultValue: nil)

    let expected = "nullableListNullableItem: GraphQLNullable<[String?]>"

    // when
    let actual = template.VariableParameter(subject).description

    // then
    expect(actual).to(equal(expected))
  }

  func test__renderOperationVariableParameter__given_NullableList_NullableItem_WithDefault__generates_NullableParameter_OptionalItem_WithInitializerDefault() throws {
    // given
    subject = .mock("nullableListNullableItemWithDefault",
                    type: .list(.scalar(.string())),
                    defaultValue: .list([.string("val")]))

    let expected = "nullableListNullableItemWithDefault: GraphQLNullable<[String?]> = [\"val\"]"

    // when
    let actual = template.VariableParameter(subject).description

    // then
    expect(actual).to(equal(expected))
  }

  func test__renderOperationVariableParameter__given_NullableList_NullableItem_WithDefault_includingNullElement_generates_NullableParameter_OptionalItem_WithInitializerDefault() throws {
    // given
    subject = .mock("nullableListNullableItemWithDefault",
                    type: .list(.scalar(.string())),
                    defaultValue: .list([.string("val"), .null]))

    let expected = "nullableListNullableItemWithDefault: GraphQLNullable<[String?]> = [\"val\", nil]"

    // when
    let actual = template.VariableParameter(subject).description

    // then
    expect(actual).to(equal(expected))
  }

  func test__renderOperationVariableParameter__given_NullableList_NonNullableItem_NoDefault__generates_NullableParameter_NonOptionalItem_NoInitializerDefault() throws {
    // given
    subject = .mock("nullableListNonNullableItem",
                    type: .list(.nonNull(.scalar(.string()))),
                    defaultValue: nil)

    let expected = "nullableListNonNullableItem: GraphQLNullable<[String]>"

    // when
    let actual = template.VariableParameter(subject).description

    // then
    expect(actual).to(equal(expected))
  }

  func test__renderOperationVariableParameter__given_NullableList_NonNullableItem_WithDefault__generates_NullableParameter_NonOptionalItem_WithInitializerDefault() throws {
    // given
    subject = .mock("nullableListNonNullableItemWithDefault", type: .list(.nonNull(.scalar(.string()))), defaultValue: .list([.string("val")]))

    let expected = "nullableListNonNullableItemWithDefault: GraphQLNullable<[String]> = [\"val\"]"

    // when
    let actual = template.VariableParameter(subject).description

    // then
    expect(actual).to(equal(expected))
  }

  func test__renderOperationVariableParameter__given_NonNullableList_NullableItem_NoDefault__generates_NonNullableNonOptionalParameter_OptionalItem_NoInitializerDefault() throws {
    // given
    subject = .mock("nonNullableListNullableItem", type: .nonNull(.list(.scalar(.string()))), defaultValue: nil)

    let expected = "nonNullableListNullableItem: [String?]"

    // when
    let actual = template.VariableParameter(subject).description

    // then
    expect(actual).to(equal(expected))
  }

  func test__renderOperationVariableParameter__given_NonNullableList_NullableItem_WithDefault__generates_OptionalParameter_OptionalItem_WithInitializerDefault() throws {
    // given
    subject = .mock("nonNullableListNullableItemWithDefault",
                    type: .nonNull(.list(.scalar(.string()))),
                    defaultValue: .list([.string("val")]))

    let expected = "nonNullableListNullableItemWithDefault: [String?] = [\"val\"]"

    // when
    let actual = template.VariableParameter(subject).description

    // then
    expect(actual).to(equal(expected))
  }

  func test__renderOperationVariableParameter__given_NonNullableList_NonNullableItem_NoDefault__generates_NonNullableNonOptionalParameter_NonOptionalItem_NoInitializerDefault() throws {
    // given
    subject = .mock("nonNullableListNonNullableItem",
                    type: .nonNull(.list(.nonNull(.scalar(.string())))),
                    defaultValue: nil)

    let expected = "nonNullableListNonNullableItem: [String]"

    // when
    let actual = template.VariableParameter(subject).description

    // then
    expect(actual).to(equal(expected))
  }

  func test__renderOperationVariableParameter__given_NonNullableList_NonNullableItem_WithDefault__generates_OptionalParameter_NonOptionalItem_WithInitializerDefault() throws {
    // given
    subject = .mock("nonNullableListNonNullableItemWithDefault",
                    type: .nonNull(.list(.nonNull(.scalar(.string())))),
                    defaultValue: .list([.string("val")]))

    let expected = "nonNullableListNonNullableItemWithDefault: [String] = [\"val\"]"

    // when
    let actual = template.VariableParameter(subject).description

    // then
    expect(actual).to(equal(expected))
  }

  func test__renderOperationVariableParameter__given_NullableListOfNullableEnum_NoDefault__generates_NullableParameter_OptionalItem_NoInitializerNilDefault() throws {
    // given
    subject = .mock("nullableListNullableItem",
                    type: .list(.enum(.mock(name: "EnumValue"))),
                    defaultValue: nil)

    let expected = "nullableListNullableItem: GraphQLNullable<[GraphQLEnum<EnumValue>?]>"

    // when
    let actual = template.VariableParameter(subject).description

    // then
    expect(actual).to(equal(expected))
  }

}
