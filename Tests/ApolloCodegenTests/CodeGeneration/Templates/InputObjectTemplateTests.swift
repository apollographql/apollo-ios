import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloUtils

class InputObjectTemplateTests: XCTestCase {
  var subject: InputObjectTemplate!

  override func setUp() {
    super.setUp()
  }

  override func tearDown() {
    subject = nil
    super.tearDown()
  }

  private func buildSubject(
    name: String = "MockInput",
    fields: [GraphQLInputField] = [],
    config: ApolloCodegenConfiguration = .mock()
  ) {
    let schema = IR.Schema(name: "TestSchema", referencedTypes: .init([]))
    subject = InputObjectTemplate(
      graphqlInputObject: GraphQLInputObjectType.mock(name, fields: fields),
      schema: schema,
      config: ReferenceWrapped(value: config)
    )
  }

  private func renderSubject() -> String {
    subject.template.description
  }

  // MARK: Definition Tests

  func test__render__generatesInputObject_withInputDictVariableAndInitializer() throws {
    // given
    buildSubject(
      name: "mockInput",
      fields: [GraphQLInputField.mock("field", type: .scalar(.integer()), defaultValue: nil)]
    )

    let expected = """
    struct MockInput: InputObject {
      public private(set) var __data: InputDict

      public init(_ data: InputDict) {
        __data = data
      }
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test_render_givenModuleType_swiftPackageManager_generatesInputObject_withPublicModifier() {
    // given
    buildSubject(config: .mock(.swiftPackageManager))

    let expected = """
    public struct MockInput: InputObject {
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test_render_givenModuleType_other_generatesInputObject_withPublicModifier() {
    // given
    buildSubject(config: .mock(.other))

    let expected = """
    public struct MockInput: InputObject {
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test_render_givenModuleType_embeddedInTarget_generatesInputObject_noPublicModifier() {
    // given
    buildSubject(config: .mock(.embeddedInTarget(name: "TestTarget")))

    let expected = """
    struct MockInput: InputObject {
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
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
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__render__givenUppercasedInputObjectField__generatesCorrectlyCasedSwiftDefinition() throws {
    // given
    buildSubject(
      name: "MOCKInput",
      fields: [GraphQLInputField.mock("field", type: .scalar(.integer()), defaultValue: nil)]
    )

    let expected = "struct MOCKInput: InputObject {"

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__render__givenMixedCaseInputObjectField__generatesCorrectlyCasedSwiftDefinition() throws {
    // given
    buildSubject(
      name: "mOcK_Input",
      fields: [GraphQLInputField.mock("field", type: .scalar(.integer()), defaultValue: nil)]
    )

    let expected = "struct MOcK_Input: InputObject {"

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  // MARK: Field Type Tests

  func test__render__givenSingleFieldType__generatesCorrectParameterAndInitializer_withClosingBrace() throws {
    // given
    buildSubject(fields: [
      GraphQLInputField.mock("field", type: .scalar(.string()), defaultValue: nil)
    ])

    let expected = """
      public init(
        field: GraphQLNullable<String> = nil
      ) {
        __data = InputDict([
          "field": field
        ])
      }

      public var field: GraphQLNullable<String> {
        get { __data.field }
        set { __data.field = newValue }
      }
    }
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 8, ignoringExtraLines: false))
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
      public init(
        stringField: GraphQLNullable<String> = nil,
        intField: GraphQLNullable<Int> = nil,
        boolField: GraphQLNullable<Bool> = nil,
        floatField: GraphQLNullable<Double> = nil,
        enumField: GraphQLNullable<GraphQLEnum<MockSchemaTypes.EnumValue>> = nil,
        inputField: GraphQLNullable<InnerInputObject> = nil,
        listField: GraphQLNullable<[String?]> = nil
      ) {
        __data = InputDict([
          "stringField": stringField,
          "intField": intField,
          "boolField": boolField,
          "floatField": floatField,
          "enumField": enumField,
          "inputField": inputField,
          "listField": listField
        ])
      }

      public var stringField: GraphQLNullable<String> {
        get { __data.stringField }
        set { __data.stringField = newValue }
      }

      public var intField: GraphQLNullable<Int> {
        get { __data.intField }
        set { __data.intField = newValue }
      }

      public var boolField: GraphQLNullable<Bool> {
        get { __data.boolField }
        set { __data.boolField = newValue }
      }

      public var floatField: GraphQLNullable<Double> {
        get { __data.floatField }
        set { __data.floatField = newValue }
      }

      public var enumField: GraphQLNullable<GraphQLEnum<EnumValue>> {
        get { __data.enumField }
        set { __data.enumField = newValue }
      }

      public var inputField: GraphQLNullable<InnerInputObject> {
        get { __data.inputField }
        set { __data.inputField = newValue }
      }

      public var listField: GraphQLNullable<[String?]> {
        get { __data.listField }
        set { __data.listField = newValue }
      }
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 8, ignoringExtraLines: true))
  }

  // MARK: Nullable Field Tests

  func test__render__given_NullableField_NoDefault__generates_NullableParameter_InitializerNilDefault() throws {
    // given
    buildSubject(fields: [
      GraphQLInputField.mock("nullable", type: .scalar(.integer()), defaultValue: nil)
    ])

    let expected = """
      public init(
        nullable: GraphQLNullable<Int> = nil
      ) {
        __data = InputDict([
          "nullable": nullable
        ])
      }

      public var nullable: GraphQLNullable<Int> {
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 8, ignoringExtraLines: true))
  }

  func test__render__given_NullableField_WithDefault__generates_NullableParameter_NoInitializerDefault() throws {
    // given
    buildSubject(fields: [
      GraphQLInputField.mock("nullableWithDefault", type: .scalar(.integer()), defaultValue: .int(3))
    ])

    let expected = """
      public init(
        nullableWithDefault: GraphQLNullable<Int>
      ) {
        __data = InputDict([
          "nullableWithDefault": nullableWithDefault
        ])
      }

      public var nullableWithDefault: GraphQLNullable<Int> {
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 8, ignoringExtraLines: true))
  }

  func test__render__given_NonNullableField_NoDefault__generates_NonNullableNonOptionalParameter_NoInitializerDefault() throws {
    // given
    buildSubject(fields: [
      GraphQLInputField.mock("nonNullable", type: .nonNull(.scalar(.integer())), defaultValue: nil)
    ])

    let expected = """
      public init(
        nonNullable: Int
      ) {
        __data = InputDict([
          "nonNullable": nonNullable
        ])
      }

      public var nonNullable: Int {
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 8, ignoringExtraLines: true))
  }

  func test__render__given_NonNullableField_WithDefault__generates_OptionalParameter_NoInitializerDefault() throws {
    // given
    buildSubject(fields: [
      GraphQLInputField.mock("nonNullableWithDefault", type: .nonNull(.scalar(.integer())), defaultValue: .int(3))
    ])

    let expected = """
      public init(
        nonNullableWithDefault: Int?
      ) {
        __data = InputDict([
          "nonNullableWithDefault": nonNullableWithDefault
        ])
      }

      public var nonNullableWithDefault: Int? {
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 8, ignoringExtraLines: true))
  }

  func test__render__given_NullableList_NullableItem_NoDefault__generates_NullableParameter_OptionalItem_InitializerNilDefault() throws {
    // given
    buildSubject(fields: [
      GraphQLInputField.mock("nullableListNullableItem", type: .list(.scalar(.string())), defaultValue: nil)
    ])

    let expected = """
      public init(
        nullableListNullableItem: GraphQLNullable<[String?]> = nil
      ) {
        __data = InputDict([
          "nullableListNullableItem": nullableListNullableItem
        ])
      }

      public var nullableListNullableItem: GraphQLNullable<[String?]> {
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 8, ignoringExtraLines: true))
  }

  func test__render__given_NullableList_NullableItem_WithDefault__generates_NullableParameter_OptionalItem_NoInitializerDefault() throws {
    // given
    buildSubject(fields: [
      GraphQLInputField.mock("nullableListNullableItemWithDefault",
                             type: .list(.scalar(.string())),
                             defaultValue: .list([.string("val")]))
    ])

    let expected = """
      public init(
        nullableListNullableItemWithDefault: GraphQLNullable<[String?]>
      ) {
        __data = InputDict([
          "nullableListNullableItemWithDefault": nullableListNullableItemWithDefault
        ])
      }

      public var nullableListNullableItemWithDefault: GraphQLNullable<[String?]> {
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 8, ignoringExtraLines: true))
  }

  func test__render__given_NullableList_NonNullableItem_NoDefault__generates_NullableParameter_NonOptionalItem_InitializerNilDefault() throws {
    // given
    buildSubject(fields: [
      GraphQLInputField.mock("nullableListNonNullableItem", type: .list(.nonNull(.scalar(.string()))), defaultValue: nil)
    ])

    let expected = """
      public init(
        nullableListNonNullableItem: GraphQLNullable<[String]> = nil
      ) {
        __data = InputDict([
          "nullableListNonNullableItem": nullableListNonNullableItem
        ])
      }

      public var nullableListNonNullableItem: GraphQLNullable<[String]> {
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 8, ignoringExtraLines: true))
  }

  func test__render__given_NullableList_NonNullableItem_WithDefault__generates_NullableParameter_NonOptionalItem_NoInitializerDefault() throws {
    // given
    buildSubject(fields: [
      GraphQLInputField.mock("nullableListNonNullableItemWithDefault",
                             type: .list(.nonNull(.scalar(.string()))),
                             defaultValue: .list([.string("val")]))
    ])

    let expected = """
      public init(
        nullableListNonNullableItemWithDefault: GraphQLNullable<[String]>
      ) {
        __data = InputDict([
          "nullableListNonNullableItemWithDefault": nullableListNonNullableItemWithDefault
        ])
      }

      public var nullableListNonNullableItemWithDefault: GraphQLNullable<[String]> {
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 8, ignoringExtraLines: true))
  }

  func test__render__given_NonNullableList_NullableItem_NoDefault__generates_NonNullableNonOptionalParameter_OptionalItem_NoInitializerDefault() throws {
    // given
    buildSubject(fields: [
      GraphQLInputField.mock("nonNullableListNullableItem", type: .nonNull(.list(.scalar(.string()))), defaultValue: nil)
    ])

    let expected = """
      public init(
        nonNullableListNullableItem: [String?]
      ) {
        __data = InputDict([
          "nonNullableListNullableItem": nonNullableListNullableItem
        ])
      }

      public var nonNullableListNullableItem: [String?] {
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 8, ignoringExtraLines: true))
  }

  func test__render__given_NonNullableList_NullableItem_WithDefault__generates_OptionalParameter_OptionalItem_NoInitializerDefault() throws {
    // given
    buildSubject(fields: [
      GraphQLInputField.mock("nonNullableListNullableItemWithDefault",
                             type: .nonNull(.list(.scalar(.string()))),
                             defaultValue: .list([.string("val")]))
    ])

    let expected = """
      public init(
        nonNullableListNullableItemWithDefault: [String?]?
      ) {
        __data = InputDict([
          "nonNullableListNullableItemWithDefault": nonNullableListNullableItemWithDefault
        ])
      }

      public var nonNullableListNullableItemWithDefault: [String?]? {
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 8, ignoringExtraLines: true))
  }

  func test__render__given_NonNullableList_NonNullableItem_NoDefault__generates_NonNullableNonOptionalParameter_NonOptionalItem_NoInitializerDefault() throws {
    // given
    buildSubject(fields: [
      GraphQLInputField.mock("nonNullableListNonNullableItem", type: .nonNull(.list(.nonNull(.scalar(.string())))), defaultValue: nil)
    ])

    let expected = """
      public init(
        nonNullableListNonNullableItem: [String]
      ) {
        __data = InputDict([
          "nonNullableListNonNullableItem": nonNullableListNonNullableItem
        ])
      }

      public var nonNullableListNonNullableItem: [String] {
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 8, ignoringExtraLines: true))
  }

  func test__render__given_NonNullableList_NonNullableItem_WithDefault__generates_OptionalParameter_NonOptionalItem_NoInitializerDefault() throws {
    // given
    buildSubject(fields: [
      GraphQLInputField.mock("nonNullableListNonNullableItemWithDefault",
                             type: .nonNull(.list(.nonNull(.scalar(.string())))),
                             defaultValue: .list([.string("val")]))
    ])

    let expected = """
      public init(
        nonNullableListNonNullableItemWithDefault: [String]?
      ) {
        __data = InputDict([
          "nonNullableListNonNullableItemWithDefault": nonNullableListNonNullableItemWithDefault
        ])
      }

      public var nonNullableListNonNullableItemWithDefault: [String]? {
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 8, ignoringExtraLines: true))
  }

  func test__render__given_NullableListOfNullableEnum_NoDefault__generates_NullableParameter_OptionalItem_InitializerNilDefault() throws {
    // given
    buildSubject(fields: [
      GraphQLInputField.mock("nullableListNullableItem",
                             type: .list(.enum(.mock(name: "EnumValue"))),
                             defaultValue: nil)
    ])

    let expected = """
      public init(
        nullableListNullableItem: GraphQLNullable<[GraphQLEnum<MockSchemaTypes.EnumValue>?]> = nil
      ) {
        __data = InputDict([
          "nullableListNullableItem": nullableListNullableItem
        ])
      }

      public var nullableListNullableItem: GraphQLNullable<[GraphQLEnum<MockSchemaTypes.EnumValue>?]> {
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 8, ignoringExtraLines: true))
  }
}
