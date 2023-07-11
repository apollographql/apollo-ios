import XCTest
import Nimble
@testable import ApolloCodegenLib
import Apollo

class InputObjectTemplateTests: XCTestCase {
  var subject: InputObjectTemplate!

  override func tearDown() {
    subject = nil
    super.tearDown()
  }

  private func buildSubject(
    name: String = "MockInput",
    fields: [GraphQLInputField] = [],
    documentation: String? = nil,
    config: ApolloCodegenConfiguration = .mock(.swiftPackageManager)
  ) {
    subject = InputObjectTemplate(
      graphqlInputObject: GraphQLInputObjectType.mock(
        name,
        fields: fields,
        documentation: documentation
      ),
      config: ApolloCodegen.ConfigurationContext(config: config)
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
    public struct MockInput: InputObject {
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

  // MARK: Access Level Tests

  func test_render_givenInputObjectWithValidAndDeprecatedFields_whenModuleType_swiftPackageManager_generatesAllWithPublicAccess() {
    // given
    buildSubject(
      fields: [
        GraphQLInputField.mock(
          "fieldOne",
          type: .nonNull(.string()),
          defaultValue: nil,
          deprecationReason: "Not used anymore!"
        ),
        GraphQLInputField.mock(
          "fieldTwo",
          type: .nonNull(.string()),
          defaultValue: nil
        )
      ],
      config: .mock(.swiftPackageManager)
    )

    let expected = """
    public struct MockInput: InputObject {
      public private(set) var __data: InputDict

      public init(_ data: InputDict) {
        __data = data
      }

      public init(
        fieldTwo: String
      ) {
        __data = InputDict([
          "fieldTwo": fieldTwo
        ])
      }

      @available(*, deprecated, message: "Argument 'fieldOne' is deprecated.")
      public init(
        fieldOne: String,
        fieldTwo: String
      ) {
        __data = InputDict([
          "fieldOne": fieldOne,
          "fieldTwo": fieldTwo
        ])
      }

      @available(*, deprecated, message: "Not used anymore!")
      public var fieldOne: String {
        get { __data["fieldOne"] }
        set { __data["fieldOne"] = newValue }
      }

      public var fieldTwo: String {
        get { __data["fieldTwo"] }
        set { __data["fieldTwo"] = newValue }
      }
    }

    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected))
  }

  func test_render_givenInputObjectWithValidAndDeprecatedFields_whenModuleType_other_generatesAllWithPublicAccess() {
    // given
    buildSubject(
      fields: [
        GraphQLInputField.mock(
          "fieldOne",
          type: .nonNull(.string()),
          defaultValue: nil,
          deprecationReason: "Not used anymore!"
        ),
        GraphQLInputField.mock(
          "fieldTwo",
          type: .nonNull(.string()),
          defaultValue: nil
        )
      ],
      config: .mock(.other)
    )

    let expected = """
    public struct MockInput: InputObject {
      public private(set) var __data: InputDict

      public init(_ data: InputDict) {
        __data = data
      }

      public init(
        fieldTwo: String
      ) {
        __data = InputDict([
          "fieldTwo": fieldTwo
        ])
      }

      @available(*, deprecated, message: "Argument 'fieldOne' is deprecated.")
      public init(
        fieldOne: String,
        fieldTwo: String
      ) {
        __data = InputDict([
          "fieldOne": fieldOne,
          "fieldTwo": fieldTwo
        ])
      }

      @available(*, deprecated, message: "Not used anymore!")
      public var fieldOne: String {
        get { __data["fieldOne"] }
        set { __data["fieldOne"] = newValue }
      }

      public var fieldTwo: String {
        get { __data["fieldTwo"] }
        set { __data["fieldTwo"] = newValue }
      }
    }
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test_render_givenInputObjectWithValidAndDeprecatedFields_whenModuleType_embeddedInTarget_withPublicAccessModifier_generatesAllWithPublicAccess() {
    // given
    buildSubject(
      fields: [
        GraphQLInputField.mock(
          "fieldOne",
          type: .nonNull(.string()),
          defaultValue: nil,
          deprecationReason: "Not used anymore!"
        ),
        GraphQLInputField.mock(
          "fieldTwo",
          type: .nonNull(.string()),
          defaultValue: nil
        )
      ],
      config: .mock(.embeddedInTarget(name: "TestTarget", accessModifier: .public))
    )

    let expected = """
    struct MockInput: InputObject {
      public private(set) var __data: InputDict

      public init(_ data: InputDict) {
        __data = data
      }

      public init(
        fieldTwo: String
      ) {
        __data = InputDict([
          "fieldTwo": fieldTwo
        ])
      }

      @available(*, deprecated, message: "Argument 'fieldOne' is deprecated.")
      public init(
        fieldOne: String,
        fieldTwo: String
      ) {
        __data = InputDict([
          "fieldOne": fieldOne,
          "fieldTwo": fieldTwo
        ])
      }

      @available(*, deprecated, message: "Not used anymore!")
      public var fieldOne: String {
        get { __data["fieldOne"] }
        set { __data["fieldOne"] = newValue }
      }

      public var fieldTwo: String {
        get { __data["fieldTwo"] }
        set { __data["fieldTwo"] = newValue }
      }
    }
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test_render_givenInputObjectWithValidAndDeprecatedFields_whenModuleType_embeddedInTarget_withInternalAccessModifier_generatesAllWithInternalAccess() {
    // given
    buildSubject(
      fields: [
        GraphQLInputField.mock(
          "fieldOne",
          type: .nonNull(.string()),
          defaultValue: nil,
          deprecationReason: "Not used anymore!"
        ),
        GraphQLInputField.mock(
          "fieldTwo",
          type: .nonNull(.string()),
          defaultValue: nil
        )
      ],
      config: .mock(.embeddedInTarget(name: "TestTarget", accessModifier: .internal))
    )

    let expected = """
    struct MockInput: InputObject {
      private(set) var __data: InputDict

      init(_ data: InputDict) {
        __data = data
      }

      init(
        fieldTwo: String
      ) {
        __data = InputDict([
          "fieldTwo": fieldTwo
        ])
      }

      @available(*, deprecated, message: "Argument 'fieldOne' is deprecated.")
      init(
        fieldOne: String,
        fieldTwo: String
      ) {
        __data = InputDict([
          "fieldOne": fieldOne,
          "fieldTwo": fieldTwo
        ])
      }

      @available(*, deprecated, message: "Not used anymore!")
      var fieldOne: String {
        get { __data["fieldOne"] }
        set { __data["fieldOne"] = newValue }
      }

      var fieldTwo: String {
        get { __data["fieldTwo"] }
        set { __data["fieldTwo"] = newValue }
      }
    }
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

    let expected = "public struct MockInput: InputObject {"

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

    let expected = "public struct MOCKInput: InputObject {"

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

    let expected = "public struct MOcK_Input: InputObject {"

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
        get { __data["field"] }
        set { __data["field"] = newValue }
      }
    }
    
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 8, ignoringExtraLines: false))
  }
  
  func test__render__givenSingleFieldTypeInMixedCase__generatesParameterAndInitializerWithCorrectCasing() throws {
    // given
    buildSubject(fields: [
      GraphQLInputField.mock("Field", type: .scalar(.string()), defaultValue: nil)
    ])

    let expected = """
      public init(
        field: GraphQLNullable<String> = nil
      ) {
        __data = InputDict([
          "Field": field
        ])
      }

      public var field: GraphQLNullable<String> {
        get { __data["Field"] }
        set { __data["Field"] = newValue }
      }
    }
    
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 8, ignoringExtraLines: false))
  }
  
  func test__render__givenSingleFieldTypeInAllUppercase__generatesParameterAndInitializerWithCorrectCasing() throws {
    // given
    buildSubject(fields: [
      GraphQLInputField.mock("FIELDNAME", type: .scalar(.string()), defaultValue: nil)
    ])

    let expected = """
      public init(
        fieldname: GraphQLNullable<String> = nil
      ) {
        __data = InputDict([
          "FIELDNAME": fieldname
        ])
      }

      public var fieldname: GraphQLNullable<String> {
        get { __data["FIELDNAME"] }
        set { __data["FIELDNAME"] = newValue }
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
        "customScalarField",
        type: .scalar(.mock(name: "CustomScalar")),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "lowercaseCustomScalarField",
        type: .scalar(.mock(name: "lowercaseCustomScalar")),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "enumField",
        type: .enum(.mock(name: "EnumType")),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "lowercaseEnumField",
        type: .enum(.mock(name: "lowercaseEnumType")),
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
        "lowercaseInputField",
        type: .inputObject(.mock(
          "lowercaseInnerInputObject",
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
    ], config: .mock(.swiftPackageManager, schemaNamespace: "TestSchema"))

    let expected = """
      public init(
        stringField: GraphQLNullable<String> = nil,
        intField: GraphQLNullable<Int> = nil,
        boolField: GraphQLNullable<Bool> = nil,
        floatField: GraphQLNullable<Double> = nil,
        customScalarField: GraphQLNullable<CustomScalar> = nil,
        lowercaseCustomScalarField: GraphQLNullable<LowercaseCustomScalar> = nil,
        enumField: GraphQLNullable<GraphQLEnum<EnumType>> = nil,
        lowercaseEnumField: GraphQLNullable<GraphQLEnum<LowercaseEnumType>> = nil,
        inputField: GraphQLNullable<InnerInputObject> = nil,
        lowercaseInputField: GraphQLNullable<LowercaseInnerInputObject> = nil,
        listField: GraphQLNullable<[String?]> = nil
      ) {
        __data = InputDict([
          "stringField": stringField,
          "intField": intField,
          "boolField": boolField,
          "floatField": floatField,
          "customScalarField": customScalarField,
          "lowercaseCustomScalarField": lowercaseCustomScalarField,
          "enumField": enumField,
          "lowercaseEnumField": lowercaseEnumField,
          "inputField": inputField,
          "lowercaseInputField": lowercaseInputField,
          "listField": listField
        ])
      }

      public var stringField: GraphQLNullable<String> {
        get { __data["stringField"] }
        set { __data["stringField"] = newValue }
      }

      public var intField: GraphQLNullable<Int> {
        get { __data["intField"] }
        set { __data["intField"] = newValue }
      }

      public var boolField: GraphQLNullable<Bool> {
        get { __data["boolField"] }
        set { __data["boolField"] = newValue }
      }

      public var floatField: GraphQLNullable<Double> {
        get { __data["floatField"] }
        set { __data["floatField"] = newValue }
      }

      public var customScalarField: GraphQLNullable<CustomScalar> {
        get { __data["customScalarField"] }
        set { __data["customScalarField"] = newValue }
      }

      public var lowercaseCustomScalarField: GraphQLNullable<LowercaseCustomScalar> {
        get { __data["lowercaseCustomScalarField"] }
        set { __data["lowercaseCustomScalarField"] = newValue }
      }

      public var enumField: GraphQLNullable<GraphQLEnum<EnumType>> {
        get { __data["enumField"] }
        set { __data["enumField"] = newValue }
      }

      public var lowercaseEnumField: GraphQLNullable<GraphQLEnum<LowercaseEnumType>> {
        get { __data["lowercaseEnumField"] }
        set { __data["lowercaseEnumField"] = newValue }
      }

      public var inputField: GraphQLNullable<InnerInputObject> {
        get { __data["inputField"] }
        set { __data["inputField"] = newValue }
      }

      public var lowercaseInputField: GraphQLNullable<LowercaseInnerInputObject> {
        get { __data["lowercaseInputField"] }
        set { __data["lowercaseInputField"] = newValue }
      }

      public var listField: GraphQLNullable<[String?]> {
        get { __data["listField"] }
        set { __data["listField"] = newValue }
      }
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 8, ignoringExtraLines: true))
  }

  func test__render__givenSchemaModuleInputFieldTypes__generatesCorrectParametersAndInitializer_withNamespaceWhenRequired() throws {
    // given
    let fields: [GraphQLInputField] = [
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
      )
    ]

    let expectedNoNamespace = """
      public init(
        enumField: GraphQLNullable<GraphQLEnum<EnumValue>> = nil,
        inputField: GraphQLNullable<InnerInputObject> = nil
      ) {
        __data = InputDict([
          "enumField": enumField,
          "inputField": inputField
        ])
      }

      public var enumField: GraphQLNullable<GraphQLEnum<EnumValue>> {
        get { __data["enumField"] }
        set { __data["enumField"] = newValue }
      }

      public var inputField: GraphQLNullable<InnerInputObject> {
        get { __data["inputField"] }
        set { __data["inputField"] = newValue }
      }
    """

    let expectedWithNamespace = """
      public init(
        enumField: GraphQLNullable<GraphQLEnum<TestSchema.EnumValue>> = nil,
        inputField: GraphQLNullable<TestSchema.InnerInputObject> = nil
      ) {
        __data = InputDict([
          "enumField": enumField,
          "inputField": inputField
        ])
      }

      public var enumField: GraphQLNullable<GraphQLEnum<TestSchema.EnumValue>> {
        get { __data["enumField"] }
        set { __data["enumField"] = newValue }
      }

      public var inputField: GraphQLNullable<TestSchema.InnerInputObject> {
        get { __data["inputField"] }
        set { __data["inputField"] = newValue }
      }
    """

    let tests: [(config: ApolloCodegenConfiguration.FileOutput, expected: String)] = [
      (.mock(moduleType: .swiftPackageManager, operations: .relative(subpath: nil)), expectedWithNamespace),
      (.mock(moduleType: .swiftPackageManager, operations: .absolute(path: "custom")), expectedWithNamespace),
      (.mock(moduleType: .swiftPackageManager, operations: .inSchemaModule), expectedNoNamespace),
      (.mock(moduleType: .other, operations: .relative(subpath: nil)), expectedWithNamespace),
      (.mock(moduleType: .other, operations: .absolute(path: "custom")), expectedWithNamespace),
      (.mock(moduleType: .other, operations: .inSchemaModule), expectedNoNamespace),
      (.mock(moduleType: .embeddedInTarget(name: "CustomTarget", accessModifier: .public), operations: .relative(subpath: nil)), expectedWithNamespace),
      (.mock(moduleType: .embeddedInTarget(name: "CustomTarget", accessModifier: .public), operations: .absolute(path: "custom")), expectedWithNamespace),
      (.mock(moduleType: .embeddedInTarget(name: "CustomTarget", accessModifier: .public), operations: .inSchemaModule), expectedNoNamespace)
    ]

    for test in tests {
      // given
      buildSubject(fields: fields, config: .mock(output: test.config))

      // when
      let actual = renderSubject()

      // then
      expect(actual).to(equalLineByLine(test.expected, atLine: 8, ignoringExtraLines: true))
    }
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
      GraphQLInputField.mock(
        "nullableListNullableItem",
        type: .list(.enum(.mock(name: "EnumValue"))),
        defaultValue: nil)
    ])

    let expected = """
      public init(
        nullableListNullableItem: GraphQLNullable<[GraphQLEnum<EnumValue>?]> = nil
      ) {
        __data = InputDict([
          "nullableListNullableItem": nullableListNullableItem
        ])
      }

      public var nullableListNullableItem: GraphQLNullable<[GraphQLEnum<EnumValue>?]> {
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 8, ignoringExtraLines: true))
  }

  // MARK: Documentation Tests

  func test__render__givenSchemaDocumentation_include_hasDocumentation_shouldGenerateDocumentationComment() throws {
    // given
    let documentation = "This is some great documentation!"
    buildSubject(
      fields: [
        GraphQLInputField.mock("fieldOne",
                               type: .nonNull(.string()),
                               defaultValue: nil,
                               documentation: "Field Documentation!")
      ],
      documentation: documentation,
      config: .mock(.swiftPackageManager, options: .init(schemaDocumentation: .include))
    )

    let expected = """
    /// \(documentation)
    public struct MockInput: InputObject {
      public private(set) var __data: InputDict

      public init(_ data: InputDict) {
        __data = data
      }

      public init(
        fieldOne: String
      ) {
        __data = InputDict([
          "fieldOne": fieldOne
        ])
      }

      /// Field Documentation!
      public var fieldOne: String {
    """

    // when
    let rendered = renderSubject()

    // then
    expect(rendered).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__render__givenSchemaDocumentation_exclude_hasDocumentation_shouldNotGenerateDocumentationComment() throws {
    // given
    let documentation = "This is some great documentation!"
    buildSubject(
      fields: [
        GraphQLInputField.mock("fieldOne",
                               type: .nonNull(.string()),
                               defaultValue: nil,
                               documentation: "Field Documentation!")
      ],
      documentation: documentation,
      config: .mock(.swiftPackageManager, options: .init(schemaDocumentation: .exclude))
    )

    let expected = """
    public struct MockInput: InputObject {
      public private(set) var __data: InputDict

      public init(_ data: InputDict) {
        __data = data
      }

      public init(
        fieldOne: String
      ) {
        __data = InputDict([
          "fieldOne": fieldOne
        ])
      }

      public var fieldOne: String {
    """

    // when
    let rendered = renderSubject()

    // then
    expect(rendered).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  // MARK: Deprecation Tests

  func test__render__givenDeprecatedField_includeDeprecationWarnings_shouldGenerateWarning() throws {
    // given
    buildSubject(
      fields: [
        GraphQLInputField.mock(
          "fieldOne",
          type: .nonNull(.string()),
          defaultValue: nil,
          deprecationReason: "Not used anymore!"
        )
      ],
      config: .mock(
        .swiftPackageManager,
        options: .init(schemaDocumentation: .include, warningsOnDeprecatedUsage: .include)
      )
    )

    let expected = """
      @available(*, deprecated, message: "Argument 'fieldOne' is deprecated.")
      public init(
        fieldOne: String
      ) {
        __data = InputDict([
          "fieldOne": fieldOne
        ])
      }

      @available(*, deprecated, message: "Not used anymore!")
      public var fieldOne: String {
    """

    // when
    let rendered = renderSubject()

    // then
    expect(rendered).to(equalLineByLine(expected, atLine: 8, ignoringExtraLines: true))
  }

  func test__render__givenOnlyDeprecatedFields_includeDeprecationWarnings_shouldGenerateWarning_withoutValidInitializer() throws {
    // given
    buildSubject(
      fields: [
        GraphQLInputField.mock(
          "fieldOne",
          type: .nonNull(.string()),
          defaultValue: nil,
          deprecationReason: "Not used anymore!"
        )
      ],
      config: .mock(
        .swiftPackageManager,
        options: .init(schemaDocumentation: .include,warningsOnDeprecatedUsage: .include)
      )
    )

    let expected = """
    public struct MockInput: InputObject {
      public private(set) var __data: InputDict

      public init(_ data: InputDict) {
        __data = data
      }

      @available(*, deprecated, message: "Argument 'fieldOne' is deprecated.")
      public init(
        fieldOne: String
      ) {
        __data = InputDict([
          "fieldOne": fieldOne
        ])
      }

      @available(*, deprecated, message: "Not used anymore!")
      public var fieldOne: String {
    """

    // when
    let rendered = renderSubject()

    // then
    expect(rendered).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__render__givenDeprecatedField_excludeDeprecationWarnings_shouldNotGenerateWarning() throws {
    // given
    buildSubject(
      fields: [
        GraphQLInputField.mock(
          "fieldOne",
          type: .nonNull(.string()),
          defaultValue: nil,
          deprecationReason: "Not used anymore!"
        )
      ],
      config: .mock(
        .swiftPackageManager,
        options: .init(schemaDocumentation: .include,warningsOnDeprecatedUsage: .exclude)
      )
    )

    let expected = """
      public init(
        fieldOne: String
      ) {
        __data = InputDict([
          "fieldOne": fieldOne
        ])
      }

      public var fieldOne: String {
    """

    // when
    let rendered = renderSubject()

    // then
    expect(rendered).to(equalLineByLine(expected, atLine: 8, ignoringExtraLines: true))
  }

  func test__render__givenDeprecatedField_andDocumentation_includeDeprecationWarnings_shouldGenerateWarning_afterDocumentation() throws {
    // given
    let documentation = "This is some great documentation!"
    buildSubject(
      fields: [
        GraphQLInputField.mock(
          "fieldOne",
          type: .nonNull(.string()),
          defaultValue: nil,
          documentation: "Field Documentation!",
          deprecationReason: "Not used anymore!"
        )
      ],
      documentation: documentation,
      config: .mock(
        .swiftPackageManager,
        options: .init(schemaDocumentation: .include,warningsOnDeprecatedUsage: .include)
      )
    )

    let expected = """
    /// This is some great documentation!
    public struct MockInput: InputObject {
      public private(set) var __data: InputDict

      public init(_ data: InputDict) {
        __data = data
      }

      @available(*, deprecated, message: "Argument 'fieldOne' is deprecated.")
      public init(
        fieldOne: String
      ) {
        __data = InputDict([
          "fieldOne": fieldOne
        ])
      }

      /// Field Documentation!
      @available(*, deprecated, message: "Not used anymore!")
      public var fieldOne: String {
    """

    // when
    let rendered = renderSubject()

    // then
    expect(rendered).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__render__givenDeprecatedField_andDocumentation_excludeDeprecationWarnings_shouldNotGenerateWarning_afterDocumentation() throws {
    // given
    let documentation = "This is some great documentation!"
    buildSubject(
      fields: [
        GraphQLInputField.mock(
          "fieldOne",
          type: .nonNull(.string()),
          defaultValue: nil,
          documentation: "Field Documentation!")
      ],
      documentation: documentation,
      config: .mock(
        .swiftPackageManager,
        options: .init(schemaDocumentation: .include,warningsOnDeprecatedUsage: .exclude)
      )
    )

    let expected = """
    /// This is some great documentation!
    public struct MockInput: InputObject {
      public private(set) var __data: InputDict

      public init(_ data: InputDict) {
        __data = data
      }

      public init(
        fieldOne: String
      ) {
        __data = InputDict([
          "fieldOne": fieldOne
        ])
      }

      /// Field Documentation!
      public var fieldOne: String {
    """

    // when
    let rendered = renderSubject()

    // then
    expect(rendered).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__render__givenDeprecatedAndValidFields_includeDeprecationWarnings_shouldGenerateWarnings_withValidInitializer() throws {
    // given
    buildSubject(
      fields: [
        GraphQLInputField.mock(
          "fieldOne",
          type: .nonNull(.string()),
          defaultValue: nil,
          deprecationReason: "Not used anymore!"
        ),
        GraphQLInputField.mock(
          "fieldTwo",
          type: .nonNull(.string()),
          defaultValue: nil
        ),
        GraphQLInputField.mock(
          "fieldThree",
          type: .nonNull(.string()),
          defaultValue: nil
        ),
        GraphQLInputField.mock(
          "fieldFour",
          type: .nonNull(.string()),
          defaultValue: nil,
          deprecationReason: "Stop using this field!"
        )
      ],
      config: .mock(
        .swiftPackageManager,
        options: .init(schemaDocumentation: .include,warningsOnDeprecatedUsage: .include)
      )
    )

    let expected = """
    public struct MockInput: InputObject {
      public private(set) var __data: InputDict

      public init(_ data: InputDict) {
        __data = data
      }

      public init(
        fieldTwo: String,
        fieldThree: String
      ) {
        __data = InputDict([
          "fieldTwo": fieldTwo,
          "fieldThree": fieldThree
        ])
      }

      @available(*, deprecated, message: "Arguments 'fieldOne, fieldFour' are deprecated.")
      public init(
        fieldOne: String,
        fieldTwo: String,
        fieldThree: String,
        fieldFour: String
      ) {
        __data = InputDict([
          "fieldOne": fieldOne,
          "fieldTwo": fieldTwo,
          "fieldThree": fieldThree,
          "fieldFour": fieldFour
        ])
      }

      @available(*, deprecated, message: "Not used anymore!")
      public var fieldOne: String {
        get { __data["fieldOne"] }
        set { __data["fieldOne"] = newValue }
      }

      public var fieldTwo: String {
        get { __data["fieldTwo"] }
        set { __data["fieldTwo"] = newValue }
      }

      public var fieldThree: String {
        get { __data["fieldThree"] }
        set { __data["fieldThree"] = newValue }
      }

      @available(*, deprecated, message: "Stop using this field!")
      public var fieldFour: String {
        get { __data["fieldFour"] }
        set { __data["fieldFour"] = newValue }
      }
    """

    // when
    let rendered = renderSubject()

    // then
    expect(rendered).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__render__givenDeprecatedAndValidFields_excludeDeprecationWarnings_shouldNotGenerateWarning_afterDocumentation_withOnlyOneInitializer() throws {
    // given
    buildSubject(
      fields: [
        GraphQLInputField.mock(
          "fieldOne",
          type: .nonNull(.string()),
          defaultValue: nil,
          deprecationReason: "Not used anymore!"
        ),
        GraphQLInputField.mock(
          "fieldTwo",
          type: .nonNull(.string()),
          defaultValue: nil
        ),
        GraphQLInputField.mock(
          "fieldThree",
          type: .nonNull(.string()),
          defaultValue: nil,
          deprecationReason: "Stop using this field!"
        )
      ],
      config: .mock(
        .swiftPackageManager,
        options: .init(schemaDocumentation: .include,warningsOnDeprecatedUsage: .exclude)
      )
    )

    let expected = """
    public struct MockInput: InputObject {
      public private(set) var __data: InputDict

      public init(_ data: InputDict) {
        __data = data
      }

      public init(
        fieldOne: String,
        fieldTwo: String,
        fieldThree: String
      ) {
        __data = InputDict([
          "fieldOne": fieldOne,
          "fieldTwo": fieldTwo,
          "fieldThree": fieldThree
        ])
      }

      public var fieldOne: String {
        get { __data["fieldOne"] }
        set { __data["fieldOne"] = newValue }
      }

      public var fieldTwo: String {
        get { __data["fieldTwo"] }
        set { __data["fieldTwo"] = newValue }
      }

      public var fieldThree: String {
        get { __data["fieldThree"] }
        set { __data["fieldThree"] = newValue }
      }
    """

    // when
    let rendered = renderSubject()

    // then
    expect(rendered).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  // MARK: Reserved Keywords + Special Names

  func test__render__givenFieldsUsingReservedNames__generatesPropertiesAndInitializerWithEscaping() throws {
    // given
    let fields = [
      GraphQLInputField.mock(
        "associatedtype",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "class",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "deinit",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "enum",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "extension",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "fileprivate",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "func",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "import",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "init",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "inout",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "internal",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "let",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "operator",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "private",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "precedencegroup",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "protocol",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "public",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "rethrows",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "static",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "struct",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "subscript",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "typealias",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "var",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "break",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "case",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "catch",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "continue",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "default",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "defer",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "do",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "else",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "fallthrough",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "for",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "guard",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "if",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "in",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "repeat",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "return",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "throw",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "switch",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "where",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "while",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "as",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "false",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "is",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "nil",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "self",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "super",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "throws",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "true",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "try",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
      GraphQLInputField.mock(
        "_",
        type: .nonNull(.string()),
        defaultValue: nil
      ),
    ]

    buildSubject(
      fields: fields,
      config: .mock(.swiftPackageManager, schemaNamespace: "TestSchema")
    )

    let expected = """
      public init(
        `associatedtype`: String,
        `class`: String,
        `deinit`: String,
        `enum`: String,
        `extension`: String,
        `fileprivate`: String,
        `func`: String,
        `import`: String,
        `init`: String,
        `inout`: String,
        `internal`: String,
        `let`: String,
        `operator`: String,
        `private`: String,
        `precedencegroup`: String,
        `protocol`: String,
        `public`: String,
        `rethrows`: String,
        `static`: String,
        `struct`: String,
        `subscript`: String,
        `typealias`: String,
        `var`: String,
        `break`: String,
        `case`: String,
        `catch`: String,
        `continue`: String,
        `default`: String,
        `defer`: String,
        `do`: String,
        `else`: String,
        `fallthrough`: String,
        `for`: String,
        `guard`: String,
        `if`: String,
        `in`: String,
        `repeat`: String,
        `return`: String,
        `throw`: String,
        `switch`: String,
        `where`: String,
        `while`: String,
        `as`: String,
        `false`: String,
        `is`: String,
        `nil`: String,
        `self`: String,
        `super`: String,
        `throws`: String,
        `true`: String,
        `try`: String,
        `_`: String
      ) {
        __data = InputDict([
          "associatedtype": `associatedtype`,
          "class": `class`,
          "deinit": `deinit`,
          "enum": `enum`,
          "extension": `extension`,
          "fileprivate": `fileprivate`,
          "func": `func`,
          "import": `import`,
          "init": `init`,
          "inout": `inout`,
          "internal": `internal`,
          "let": `let`,
          "operator": `operator`,
          "private": `private`,
          "precedencegroup": `precedencegroup`,
          "protocol": `protocol`,
          "public": `public`,
          "rethrows": `rethrows`,
          "static": `static`,
          "struct": `struct`,
          "subscript": `subscript`,
          "typealias": `typealias`,
          "var": `var`,
          "break": `break`,
          "case": `case`,
          "catch": `catch`,
          "continue": `continue`,
          "default": `default`,
          "defer": `defer`,
          "do": `do`,
          "else": `else`,
          "fallthrough": `fallthrough`,
          "for": `for`,
          "guard": `guard`,
          "if": `if`,
          "in": `in`,
          "repeat": `repeat`,
          "return": `return`,
          "throw": `throw`,
          "switch": `switch`,
          "where": `where`,
          "while": `while`,
          "as": `as`,
          "false": `false`,
          "is": `is`,
          "nil": `nil`,
          "self": `self`,
          "super": `super`,
          "throws": `throws`,
          "true": `true`,
          "try": `try`,
          "_": `_`
        ])
      }

      public var `associatedtype`: String {
        get { __data["associatedtype"] }
        set { __data["associatedtype"] = newValue }
      }

      public var `class`: String {
        get { __data["class"] }
        set { __data["class"] = newValue }
      }

      public var `deinit`: String {
        get { __data["deinit"] }
        set { __data["deinit"] = newValue }
      }

      public var `enum`: String {
        get { __data["enum"] }
        set { __data["enum"] = newValue }
      }

      public var `extension`: String {
        get { __data["extension"] }
        set { __data["extension"] = newValue }
      }

      public var `fileprivate`: String {
        get { __data["fileprivate"] }
        set { __data["fileprivate"] = newValue }
      }

      public var `func`: String {
        get { __data["func"] }
        set { __data["func"] = newValue }
      }

      public var `import`: String {
        get { __data["import"] }
        set { __data["import"] = newValue }
      }

      public var `init`: String {
        get { __data["init"] }
        set { __data["init"] = newValue }
      }

      public var `inout`: String {
        get { __data["inout"] }
        set { __data["inout"] = newValue }
      }

      public var `internal`: String {
        get { __data["internal"] }
        set { __data["internal"] = newValue }
      }

      public var `let`: String {
        get { __data["let"] }
        set { __data["let"] = newValue }
      }

      public var `operator`: String {
        get { __data["operator"] }
        set { __data["operator"] = newValue }
      }

      public var `private`: String {
        get { __data["private"] }
        set { __data["private"] = newValue }
      }

      public var `precedencegroup`: String {
        get { __data["precedencegroup"] }
        set { __data["precedencegroup"] = newValue }
      }

      public var `protocol`: String {
        get { __data["protocol"] }
        set { __data["protocol"] = newValue }
      }

      public var `public`: String {
        get { __data["public"] }
        set { __data["public"] = newValue }
      }

      public var `rethrows`: String {
        get { __data["rethrows"] }
        set { __data["rethrows"] = newValue }
      }

      public var `static`: String {
        get { __data["static"] }
        set { __data["static"] = newValue }
      }

      public var `struct`: String {
        get { __data["struct"] }
        set { __data["struct"] = newValue }
      }

      public var `subscript`: String {
        get { __data["subscript"] }
        set { __data["subscript"] = newValue }
      }

      public var `typealias`: String {
        get { __data["typealias"] }
        set { __data["typealias"] = newValue }
      }

      public var `var`: String {
        get { __data["var"] }
        set { __data["var"] = newValue }
      }

      public var `break`: String {
        get { __data["break"] }
        set { __data["break"] = newValue }
      }

      public var `case`: String {
        get { __data["case"] }
        set { __data["case"] = newValue }
      }

      public var `catch`: String {
        get { __data["catch"] }
        set { __data["catch"] = newValue }
      }

      public var `continue`: String {
        get { __data["continue"] }
        set { __data["continue"] = newValue }
      }

      public var `default`: String {
        get { __data["default"] }
        set { __data["default"] = newValue }
      }

      public var `defer`: String {
        get { __data["defer"] }
        set { __data["defer"] = newValue }
      }

      public var `do`: String {
        get { __data["do"] }
        set { __data["do"] = newValue }
      }

      public var `else`: String {
        get { __data["else"] }
        set { __data["else"] = newValue }
      }

      public var `fallthrough`: String {
        get { __data["fallthrough"] }
        set { __data["fallthrough"] = newValue }
      }

      public var `for`: String {
        get { __data["for"] }
        set { __data["for"] = newValue }
      }

      public var `guard`: String {
        get { __data["guard"] }
        set { __data["guard"] = newValue }
      }

      public var `if`: String {
        get { __data["if"] }
        set { __data["if"] = newValue }
      }

      public var `in`: String {
        get { __data["in"] }
        set { __data["in"] = newValue }
      }

      public var `repeat`: String {
        get { __data["repeat"] }
        set { __data["repeat"] = newValue }
      }

      public var `return`: String {
        get { __data["return"] }
        set { __data["return"] = newValue }
      }

      public var `throw`: String {
        get { __data["throw"] }
        set { __data["throw"] = newValue }
      }

      public var `switch`: String {
        get { __data["switch"] }
        set { __data["switch"] = newValue }
      }

      public var `where`: String {
        get { __data["where"] }
        set { __data["where"] = newValue }
      }

      public var `while`: String {
        get { __data["while"] }
        set { __data["while"] = newValue }
      }

      public var `as`: String {
        get { __data["as"] }
        set { __data["as"] = newValue }
      }

      public var `false`: String {
        get { __data["false"] }
        set { __data["false"] = newValue }
      }

      public var `is`: String {
        get { __data["is"] }
        set { __data["is"] = newValue }
      }

      public var `nil`: String {
        get { __data["nil"] }
        set { __data["nil"] = newValue }
      }

      public var `self`: String {
        get { __data["self"] }
        set { __data["self"] = newValue }
      }

      public var `super`: String {
        get { __data["super"] }
        set { __data["super"] = newValue }
      }

      public var `throws`: String {
        get { __data["throws"] }
        set { __data["throws"] = newValue }
      }

      public var `true`: String {
        get { __data["true"] }
        set { __data["true"] = newValue }
      }

      public var `try`: String {
        get { __data["try"] }
        set { __data["try"] = newValue }
      }

      public var `_`: String {
        get { __data["_"] }
        set { __data["_"] = newValue }
      }
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 8, ignoringExtraLines: true))
  }

  // MARK: Casing Tests

  func test__casing__givenSchemaNameLowercased_nonListField_generatesWithFirstUppercasedNamespace() throws {
    // given
    let fields: [GraphQLInputField] = [
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
      )
    ]

    buildSubject(
      fields: fields,
      config: .mock(schemaNamespace: "testschema", output: .mock(
        moduleType: .swiftPackageManager,
        operations: .relative(subpath: nil)))
    )

    let expected = """
      public init(
        enumField: GraphQLNullable<GraphQLEnum<Testschema.EnumValue>> = nil,
        inputField: GraphQLNullable<Testschema.InnerInputObject> = nil
      ) {
        __data = InputDict([
          "enumField": enumField,
          "inputField": inputField
        ])
      }

      public var enumField: GraphQLNullable<GraphQLEnum<Testschema.EnumValue>> {
        get { __data["enumField"] }
        set { __data["enumField"] = newValue }
      }

      public var inputField: GraphQLNullable<Testschema.InnerInputObject> {
        get { __data["inputField"] }
        set { __data["inputField"] = newValue }
      }
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 8, ignoringExtraLines: true))
  }

  func test__casing__givenUppercasedSchemaName_nonListField_generatesWithUppercasedNamespace() throws {
    // given
    let fields: [GraphQLInputField] = [
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
      )
    ]

    buildSubject(
      fields: fields,
      config: .mock(schemaNamespace: "TESTSCHEMA", output: .mock(
        moduleType: .swiftPackageManager,
        operations: .relative(subpath: nil)))
    )

    let expected = """
      public init(
        enumField: GraphQLNullable<GraphQLEnum<TESTSCHEMA.EnumValue>> = nil,
        inputField: GraphQLNullable<TESTSCHEMA.InnerInputObject> = nil
      ) {
        __data = InputDict([
          "enumField": enumField,
          "inputField": inputField
        ])
      }

      public var enumField: GraphQLNullable<GraphQLEnum<TESTSCHEMA.EnumValue>> {
        get { __data["enumField"] }
        set { __data["enumField"] = newValue }
      }

      public var inputField: GraphQLNullable<TESTSCHEMA.InnerInputObject> {
        get { __data["inputField"] }
        set { __data["inputField"] = newValue }
      }
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 8, ignoringExtraLines: true))
  }

  func test__casing__givenCapitalizedSchemaName_nonListField_generatesWithCapitalizedNamespace() throws {
    // given
    let fields: [GraphQLInputField] = [
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
      )
    ]

    buildSubject(
      fields: fields,
      config: .mock(schemaNamespace: "TestSchema", output: .mock(
        moduleType: .swiftPackageManager,
        operations: .relative(subpath: nil)))
    )

    let expected = """
      public init(
        enumField: GraphQLNullable<GraphQLEnum<TestSchema.EnumValue>> = nil,
        inputField: GraphQLNullable<TestSchema.InnerInputObject> = nil
      ) {
        __data = InputDict([
          "enumField": enumField,
          "inputField": inputField
        ])
      }

      public var enumField: GraphQLNullable<GraphQLEnum<TestSchema.EnumValue>> {
        get { __data["enumField"] }
        set { __data["enumField"] = newValue }
      }

      public var inputField: GraphQLNullable<TestSchema.InnerInputObject> {
        get { __data["inputField"] }
        set { __data["inputField"] = newValue }
      }
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 8, ignoringExtraLines: true))
  }

  func test__casing__givenLowercasedSchemaName_listField_generatesWithFirstUppercasedNamespace() throws {
    // given
    buildSubject(
      fields: [GraphQLInputField.mock(
        "nullableListNullableItem",
        type: .list(.enum(.mock(name: "EnumValue"))),
        defaultValue: nil)],
      config: .mock(
        schemaNamespace: "testschema",
        output: .mock(moduleType: .swiftPackageManager, operations: .relative(subpath: nil))
      )
    )

    let expected = """
      public init(
        nullableListNullableItem: GraphQLNullable<[GraphQLEnum<Testschema.EnumValue>?]> = nil
      ) {
        __data = InputDict([
          "nullableListNullableItem": nullableListNullableItem
        ])
      }

      public var nullableListNullableItem: GraphQLNullable<[GraphQLEnum<Testschema.EnumValue>?]> {
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 8, ignoringExtraLines: true))
  }

  func test__casing__givenUppercasedSchemaName_listField_generatesWithUppercasedNamespace() throws {
    // given
    buildSubject(
      fields: [GraphQLInputField.mock(
        "nullableListNullableItem",
        type: .list(.enum(.mock(name: "EnumValue"))),
        defaultValue: nil)],
      config: .mock(
        schemaNamespace: "TESTSCHEMA",
        output: .mock(moduleType: .swiftPackageManager, operations: .relative(subpath: nil))
      )
    )

    let expected = """
      public init(
        nullableListNullableItem: GraphQLNullable<[GraphQLEnum<TESTSCHEMA.EnumValue>?]> = nil
      ) {
        __data = InputDict([
          "nullableListNullableItem": nullableListNullableItem
        ])
      }

      public var nullableListNullableItem: GraphQLNullable<[GraphQLEnum<TESTSCHEMA.EnumValue>?]> {
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 8, ignoringExtraLines: true))
  }

  func test__casing__givenCapitalizedSchemaName_listField_generatesWithCapitalizedNamespace() throws {
    // given
    buildSubject(
      fields: [GraphQLInputField.mock(
        "nullableListNullableItem",
        type: .list(.enum(.mock(name: "EnumValue"))),
        defaultValue: nil)],
      config: .mock(
        schemaNamespace: "TestSchema",
        output: .mock(moduleType:.swiftPackageManager ,operations: .relative(subpath: nil))
      )
    )

    let expected = """
      public init(
        nullableListNullableItem: GraphQLNullable<[GraphQLEnum<TestSchema.EnumValue>?]> = nil
      ) {
        __data = InputDict([
          "nullableListNullableItem": nullableListNullableItem
        ])
      }

      public var nullableListNullableItem: GraphQLNullable<[GraphQLEnum<TestSchema.EnumValue>?]> {
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 8, ignoringExtraLines: true))
  }
  
  // MARK: - Reserved Keyword Tests
  
  func test__render__generatesInputObject_usingReservedKeyword_asEscapedType() throws {
    let keywords = ["Type", "type"]
    
    keywords.forEach { keyword in
      // given
      buildSubject(
        name: keyword,
        fields: [GraphQLInputField.mock("field", type: .scalar(.integer()), defaultValue: nil)]
      )

      let expected = """
      public struct \(keyword.firstUppercased)_InputObject: InputObject {
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
  }
  
}
