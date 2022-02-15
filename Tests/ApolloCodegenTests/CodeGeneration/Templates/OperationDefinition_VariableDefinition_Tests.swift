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

  func test__renderInputValueType__givenScalar__generatesCorrectParameterAndInitializer() throws {
    // given
    subject = .mock("variable", type: .scalar(.string()), defaultValue: nil)

    let expected = "GraphQLNullable<String> = nil"

    // when
    let actual = subject.renderInputValueType(includeDefault: true)

    // then
    expect(actual).to(equal(expected))
  }

  func test__renderInputValueType__givenIncludeDefaultFalse__generatesCorrectParameter() throws {
    // given
    subject = .mock("variable", type: .scalar(.string()), defaultValue: nil)

    let expected = "GraphQLNullable<String>"

    // when
    let actual = subject.renderInputValueType(includeDefault: false)

    // then
    expect(actual).to(equal(expected))
  }

  func test__renderInputValueType__givenAllPossibleSchemaInputFieldTypes__generatesCorrectParametersAndInitializer() throws {
    // given
    let tests: [(variable: CompilationResult.VariableDefinition, expected: String)] = [
      (
        .mock(
          "stringField",
          type: .scalar(.string()),
          defaultValue: nil
        ),
        "GraphQLNullable<String> = nil"
      ),
      (
        .mock(
          "intField",
          type: .scalar(.integer()),
          defaultValue: nil
        ),
        "GraphQLNullable<Int> = nil"
      ),
      (
        .mock(
          "boolField",
          type: .scalar(.boolean()),
          defaultValue: nil
        ),
        "GraphQLNullable<Bool> = nil"
      ),
      (
        .mock(
          "floatField",
          type: .scalar(.float()),
          defaultValue: nil
        ),
        "GraphQLNullable<Float> = nil"
      ),
      (
        .mock(
          "enumField",
          type: .enum(.mock(name: "EnumValue")),
          defaultValue: nil
        ),
        "GraphQLNullable<GraphQLEnum<EnumValue>> = nil"
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
        "GraphQLNullable<InnerInputObject> = nil"
      ),
      (
        .mock(
          "listField",
          type: .list(.scalar(.string())),
          defaultValue: nil
        ),
        "GraphQLNullable<[String?]> = nil"
      )
    ]

    for test in tests {
      // when
      let actual = test.variable.renderInputValueType(includeDefault: true)

      // then
      expect(actual).to(equal(test.expected))
    }
  }

  // MARK: Nullable Field Tests

  func test__renderInputValueType__given_NullableField_NoDefault__generates_NullableParameter_InitializerNilDefault() throws {
    // given
    subject = .mock("nullable", type: .scalar(.integer()), defaultValue: nil)

    let expected = "GraphQLNullable<Int> = nil"

    // when
    let actual = subject.renderInputValueType(includeDefault: true)

    // then
    expect(actual).to(equal(expected))
  }

  func test__renderInputValueType__given_NullableField_WithDefault__generates_NullableParameter_NoInitializerDefault() throws {
    // given
    subject = .mock("nullableWithDefault", type: .scalar(.integer()), defaultValue: .int(3))

    let expected = "GraphQLNullable<Int>"

    // when
    let actual = subject.renderInputValueType(includeDefault: true)

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

  func test__renderInputValueType__given_NonNullableField_WithDefault__generates_OptionalParameter_NoInitializerDefault() throws {
    // given
    subject = .mock("nonNullableWithDefault", type: .nonNull(.scalar(.integer())), defaultValue: .int(3))

    let expected = "Int?"
    
    // when
    let actual = subject.renderInputValueType(includeDefault: true)

    // then
    expect(actual).to(equal(expected))
  }

  func test__renderInputValueType__given_NullableList_NullableItem_NoDefault__generates_NullableParameter_OptionalItem_InitializerNilDefault() throws {
    // given
    subject = .mock("nullableListNullableItem", type: .list(.scalar(.string())), defaultValue: nil)

    let expected = "GraphQLNullable<[String?]> = nil"

    // when
    let actual = subject.renderInputValueType(includeDefault: true)

    // then
    expect(actual).to(equal(expected))
  }

  func test__renderInputValueType__given_NullableList_NullableItem_WithDefault__generates_NullableParameter_OptionalItem_NoInitializerDefault() throws {
    // given
    subject = .mock("nullableListNullableItemWithDefault", type: .list(.scalar(.string())), defaultValue: .string("val"))

    let expected = "GraphQLNullable<[String?]>"

    // when
    let actual = subject.renderInputValueType(includeDefault: true)

    // then
    expect(actual).to(equal(expected))
  }

  func test__renderInputValueType__given_NullableList_NonNullableItem_NoDefault__generates_NullableParameter_NonOptionalItem_InitializerNilDefault() throws {
    // given
    subject = .mock("nullableListNonNullableItem", type: .list(.nonNull(.scalar(.string()))), defaultValue: nil)

    let expected = "GraphQLNullable<[String]> = nil"

    // when
    let actual = subject.renderInputValueType(includeDefault: true)

    // then
    expect(actual).to(equal(expected))
  }

  func test__renderInputValueType__given_NullableList_NonNullableItem_WithDefault__generates_NullableParameter_NonOptionalItem_NoInitializerDefault() throws {
    // given
    subject = .mock("nullableListNonNullableItemWithDefault", type: .list(.nonNull(.scalar(.string()))), defaultValue: .string("val"))

    let expected = "GraphQLNullable<[String]>"

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

  func test__renderInputValueType__given_NonNullableList_NullableItem_WithDefault__generates_OptionalParameter_OptionalItem_NoInitializerDefault() throws {
    // given
    subject = .mock("nonNullableListNullableItemWithDefault", type: .nonNull(.list(.scalar(.string()))), defaultValue: .string("val"))

    let expected = "[String?]?"

    // when
    let actual = subject.renderInputValueType(includeDefault: true)

    // then
    expect(actual).to(equal(expected))
  }

  func test__renderInputValueType__given_NonNullableList_NonNullableItem_NoDefault__generates_NonNullableNonOptionalParameter_NonOptionalItem_NoInitializerDefault() throws {
    // given
    subject = .mock("nonNullableListNonNullableItem", type: .nonNull(.list(.nonNull(.scalar(.string())))), defaultValue: nil)

    let expected = "[String]"

    // when
    let actual = subject.renderInputValueType(includeDefault: true)

    // then
    expect(actual).to(equal(expected))
  }

  func test__renderInputValueType__given_NonNullableList_NonNullableItem_WithDefault__generates_OptionalParameter_NonOptionalItem_NoInitializerDefault() throws {
    // given
    subject = .mock("nonNullableListNonNullableItemWithDefault", type: .nonNull(.list(.nonNull(.scalar(.string())))), defaultValue: .string("val"))

    let expected = "[String]?"

    // when
    let actual = subject.renderInputValueType(includeDefault: true)

    // then
    expect(actual).to(equal(expected))
  }

  func test__renderInputValueType__given_NullableListOfNullableEnum_NoDefault__generates_NullableParameter_OptionalItem_InitializerNilDefault() throws {
    // given
    subject = .mock("nullableListNullableItem",
                    type: .list(.enum(.mock(name: "EnumValue"))),
                    defaultValue: nil)

    let expected = "GraphQLNullable<[GraphQLEnum<EnumValue>?]> = nil"

    // when
    let actual = subject.renderInputValueType(includeDefault: true)

    // then
    expect(actual).to(equal(expected))
  }

}
