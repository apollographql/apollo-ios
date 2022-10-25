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
    config: ApolloCodegenConfiguration = .mock()
  ) {
    let schema = IR.Schema(name: "TestSchema", referencedTypes: .init([]))
    subject = InputObjectTemplate(
      graphqlInputObject: GraphQLInputObjectType.mock(
        name,
        fields: fields,
        documentation: documentation
      ),
      schema: schema,
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
        get { __data[dynamicMember: "field"] }
        set { __data[dynamicMember: "field"] = newValue }
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
    ], config: .mock(schemaName: "TestSchema"))

    let expected = """
      public init(
        stringField: GraphQLNullable<String> = nil,
        intField: GraphQLNullable<Int> = nil,
        boolField: GraphQLNullable<Bool> = nil,
        floatField: GraphQLNullable<Double> = nil,
        customScalarField: GraphQLNullable<TestSchema.CustomScalar> = nil,
        lowercaseCustomScalarField: GraphQLNullable<TestSchema.LowercaseCustomScalar> = nil,
        enumField: GraphQLNullable<GraphQLEnum<TestSchema.EnumType>> = nil,
        lowercaseEnumField: GraphQLNullable<GraphQLEnum<TestSchema.LowercaseEnumType>> = nil,
        inputField: GraphQLNullable<TestSchema.InnerInputObject> = nil,
        lowercaseInputField: GraphQLNullable<TestSchema.LowercaseInnerInputObject> = nil,
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
        get { __data[dynamicMember: "stringField"] }
        set { __data[dynamicMember: "stringField"] = newValue }
      }

      public var intField: GraphQLNullable<Int> {
        get { __data[dynamicMember: "intField"] }
        set { __data[dynamicMember: "intField"] = newValue }
      }

      public var boolField: GraphQLNullable<Bool> {
        get { __data[dynamicMember: "boolField"] }
        set { __data[dynamicMember: "boolField"] = newValue }
      }

      public var floatField: GraphQLNullable<Double> {
        get { __data[dynamicMember: "floatField"] }
        set { __data[dynamicMember: "floatField"] = newValue }
      }

      public var customScalarField: GraphQLNullable<TestSchema.CustomScalar> {
        get { __data[dynamicMember: "customScalarField"] }
        set { __data[dynamicMember: "customScalarField"] = newValue }
      }

      public var lowercaseCustomScalarField: GraphQLNullable<TestSchema.LowercaseCustomScalar> {
        get { __data[dynamicMember: "lowercaseCustomScalarField"] }
        set { __data[dynamicMember: "lowercaseCustomScalarField"] = newValue }
      }

      public var enumField: GraphQLNullable<GraphQLEnum<TestSchema.EnumType>> {
        get { __data[dynamicMember: "enumField"] }
        set { __data[dynamicMember: "enumField"] = newValue }
      }

      public var lowercaseEnumField: GraphQLNullable<GraphQLEnum<TestSchema.LowercaseEnumType>> {
        get { __data[dynamicMember: "lowercaseEnumField"] }
        set { __data[dynamicMember: "lowercaseEnumField"] = newValue }
      }

      public var inputField: GraphQLNullable<TestSchema.InnerInputObject> {
        get { __data[dynamicMember: "inputField"] }
        set { __data[dynamicMember: "inputField"] = newValue }
      }

      public var lowercaseInputField: GraphQLNullable<TestSchema.LowercaseInnerInputObject> {
        get { __data[dynamicMember: "lowercaseInputField"] }
        set { __data[dynamicMember: "lowercaseInputField"] = newValue }
      }

      public var listField: GraphQLNullable<[String?]> {
        get { __data[dynamicMember: "listField"] }
        set { __data[dynamicMember: "listField"] = newValue }
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
        get { __data[dynamicMember: "enumField"] }
        set { __data[dynamicMember: "enumField"] = newValue }
      }

      public var inputField: GraphQLNullable<InnerInputObject> {
        get { __data[dynamicMember: "inputField"] }
        set { __data[dynamicMember: "inputField"] = newValue }
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
        get { __data[dynamicMember: "enumField"] }
        set { __data[dynamicMember: "enumField"] = newValue }
      }

      public var inputField: GraphQLNullable<TestSchema.InnerInputObject> {
        get { __data[dynamicMember: "inputField"] }
        set { __data[dynamicMember: "inputField"] = newValue }
      }
    """

    let tests: [(config: ApolloCodegenConfiguration.FileOutput, expected: String)] = [
      (.mock(moduleType: .swiftPackageManager, operations: .relative(subpath: nil)), expectedWithNamespace),
      (.mock(moduleType: .swiftPackageManager, operations: .absolute(path: "custom")), expectedWithNamespace),
      (.mock(moduleType: .swiftPackageManager, operations: .inSchemaModule), expectedNoNamespace),
      (.mock(moduleType: .other, operations: .relative(subpath: nil)), expectedWithNamespace),
      (.mock(moduleType: .other, operations: .absolute(path: "custom")), expectedWithNamespace),
      (.mock(moduleType: .other, operations: .inSchemaModule), expectedNoNamespace),
      (.mock(moduleType: .embeddedInTarget(name: "CustomTarget"), operations: .relative(subpath: nil)), expectedWithNamespace),
      (.mock(moduleType: .embeddedInTarget(name: "CustomTarget"), operations: .absolute(path: "custom")), expectedWithNamespace),
      (.mock(moduleType: .embeddedInTarget(name: "CustomTarget"), operations: .inSchemaModule), expectedNoNamespace)
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
      GraphQLInputField.mock("nullableListNullableItem",
                             type: .list(.enum(.mock(name: "EnumValue"))),
                             defaultValue: nil)
    ])

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
      config: .mock(options: .init(schemaDocumentation: .include))
    )

    let expected = """
    /// \(documentation)
    struct MockInput: InputObject {
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
      config: .mock(options: .init(schemaDocumentation: .exclude))
    )

    let expected = """
    struct MockInput: InputObject {
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
      config: .mock(options: .init(
        schemaDocumentation: .include,
        warningsOnDeprecatedUsage: .include
      ))
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
      config: .mock(options: .init(
        schemaDocumentation: .include,
        warningsOnDeprecatedUsage: .include
      ))
    )

    let expected = """
    struct MockInput: InputObject {
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
      config: .mock(options: .init(
        schemaDocumentation: .include,
        warningsOnDeprecatedUsage: .exclude
      ))
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
      config: .mock(options: .init(
        schemaDocumentation: .include,
        warningsOnDeprecatedUsage: .include
      ))
    )

    let expected = """
    /// This is some great documentation!
    struct MockInput: InputObject {
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
      config: .mock(options: .init(
        schemaDocumentation: .include,
        warningsOnDeprecatedUsage: .exclude
      ))
    )

    let expected = """
    /// This is some great documentation!
    struct MockInput: InputObject {
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
      config: .mock(options: .init(
        schemaDocumentation: .include,
        warningsOnDeprecatedUsage: .include
      ))
    )

    let expected = """
    struct MockInput: InputObject {
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
        get { __data[dynamicMember: "fieldOne"] }
        set { __data[dynamicMember: "fieldOne"] = newValue }
      }

      public var fieldTwo: String {
        get { __data[dynamicMember: "fieldTwo"] }
        set { __data[dynamicMember: "fieldTwo"] = newValue }
      }

      public var fieldThree: String {
        get { __data[dynamicMember: "fieldThree"] }
        set { __data[dynamicMember: "fieldThree"] = newValue }
      }

      @available(*, deprecated, message: "Stop using this field!")
      public var fieldFour: String {
        get { __data[dynamicMember: "fieldFour"] }
        set { __data[dynamicMember: "fieldFour"] = newValue }
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
      config: .mock(options: .init(
        schemaDocumentation: .include,
        warningsOnDeprecatedUsage: .exclude
      ))
    )

    let expected = """
    struct MockInput: InputObject {
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
        get { __data[dynamicMember: "fieldOne"] }
        set { __data[dynamicMember: "fieldOne"] = newValue }
      }

      public var fieldTwo: String {
        get { __data[dynamicMember: "fieldTwo"] }
        set { __data[dynamicMember: "fieldTwo"] = newValue }
      }

      public var fieldThree: String {
        get { __data[dynamicMember: "fieldThree"] }
        set { __data[dynamicMember: "fieldThree"] = newValue }
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
      )
    ]

    buildSubject(fields: fields, config: .mock(schemaName: "TestSchema"))

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
        `try`: String
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
          "try": `try`
        ])
      }

      public var `associatedtype`: String {
        get { __data[dynamicMember: "`associatedtype`"] }
        set { __data[dynamicMember: "`associatedtype`"] = newValue }
      }

      public var `class`: String {
        get { __data[dynamicMember: "`class`"] }
        set { __data[dynamicMember: "`class`"] = newValue }
      }

      public var `deinit`: String {
        get { __data[dynamicMember: "`deinit`"] }
        set { __data[dynamicMember: "`deinit`"] = newValue }
      }

      public var `enum`: String {
        get { __data[dynamicMember: "`enum`"] }
        set { __data[dynamicMember: "`enum`"] = newValue }
      }

      public var `extension`: String {
        get { __data[dynamicMember: "`extension`"] }
        set { __data[dynamicMember: "`extension`"] = newValue }
      }

      public var `fileprivate`: String {
        get { __data[dynamicMember: "`fileprivate`"] }
        set { __data[dynamicMember: "`fileprivate`"] = newValue }
      }

      public var `func`: String {
        get { __data[dynamicMember: "`func`"] }
        set { __data[dynamicMember: "`func`"] = newValue }
      }

      public var `import`: String {
        get { __data[dynamicMember: "`import`"] }
        set { __data[dynamicMember: "`import`"] = newValue }
      }

      public var `init`: String {
        get { __data[dynamicMember: "`init`"] }
        set { __data[dynamicMember: "`init`"] = newValue }
      }

      public var `inout`: String {
        get { __data[dynamicMember: "`inout`"] }
        set { __data[dynamicMember: "`inout`"] = newValue }
      }

      public var `internal`: String {
        get { __data[dynamicMember: "`internal`"] }
        set { __data[dynamicMember: "`internal`"] = newValue }
      }

      public var `let`: String {
        get { __data[dynamicMember: "`let`"] }
        set { __data[dynamicMember: "`let`"] = newValue }
      }

      public var `operator`: String {
        get { __data[dynamicMember: "`operator`"] }
        set { __data[dynamicMember: "`operator`"] = newValue }
      }

      public var `private`: String {
        get { __data[dynamicMember: "`private`"] }
        set { __data[dynamicMember: "`private`"] = newValue }
      }

      public var `precedencegroup`: String {
        get { __data[dynamicMember: "`precedencegroup`"] }
        set { __data[dynamicMember: "`precedencegroup`"] = newValue }
      }

      public var `protocol`: String {
        get { __data[dynamicMember: "`protocol`"] }
        set { __data[dynamicMember: "`protocol`"] = newValue }
      }

      public var `public`: String {
        get { __data[dynamicMember: "`public`"] }
        set { __data[dynamicMember: "`public`"] = newValue }
      }

      public var `rethrows`: String {
        get { __data[dynamicMember: "`rethrows`"] }
        set { __data[dynamicMember: "`rethrows`"] = newValue }
      }

      public var `static`: String {
        get { __data[dynamicMember: "`static`"] }
        set { __data[dynamicMember: "`static`"] = newValue }
      }

      public var `struct`: String {
        get { __data[dynamicMember: "`struct`"] }
        set { __data[dynamicMember: "`struct`"] = newValue }
      }

      public var `subscript`: String {
        get { __data[dynamicMember: "`subscript`"] }
        set { __data[dynamicMember: "`subscript`"] = newValue }
      }

      public var `typealias`: String {
        get { __data[dynamicMember: "`typealias`"] }
        set { __data[dynamicMember: "`typealias`"] = newValue }
      }

      public var `var`: String {
        get { __data[dynamicMember: "`var`"] }
        set { __data[dynamicMember: "`var`"] = newValue }
      }

      public var `break`: String {
        get { __data[dynamicMember: "`break`"] }
        set { __data[dynamicMember: "`break`"] = newValue }
      }

      public var `case`: String {
        get { __data[dynamicMember: "`case`"] }
        set { __data[dynamicMember: "`case`"] = newValue }
      }

      public var `catch`: String {
        get { __data[dynamicMember: "`catch`"] }
        set { __data[dynamicMember: "`catch`"] = newValue }
      }

      public var `continue`: String {
        get { __data[dynamicMember: "`continue`"] }
        set { __data[dynamicMember: "`continue`"] = newValue }
      }

      public var `default`: String {
        get { __data[dynamicMember: "`default`"] }
        set { __data[dynamicMember: "`default`"] = newValue }
      }

      public var `defer`: String {
        get { __data[dynamicMember: "`defer`"] }
        set { __data[dynamicMember: "`defer`"] = newValue }
      }

      public var `do`: String {
        get { __data[dynamicMember: "`do`"] }
        set { __data[dynamicMember: "`do`"] = newValue }
      }

      public var `else`: String {
        get { __data[dynamicMember: "`else`"] }
        set { __data[dynamicMember: "`else`"] = newValue }
      }

      public var `fallthrough`: String {
        get { __data[dynamicMember: "`fallthrough`"] }
        set { __data[dynamicMember: "`fallthrough`"] = newValue }
      }

      public var `guard`: String {
        get { __data[dynamicMember: "`guard`"] }
        set { __data[dynamicMember: "`guard`"] = newValue }
      }

      public var `if`: String {
        get { __data[dynamicMember: "`if`"] }
        set { __data[dynamicMember: "`if`"] = newValue }
      }

      public var `in`: String {
        get { __data[dynamicMember: "`in`"] }
        set { __data[dynamicMember: "`in`"] = newValue }
      }

      public var `repeat`: String {
        get { __data[dynamicMember: "`repeat`"] }
        set { __data[dynamicMember: "`repeat`"] = newValue }
      }

      public var `return`: String {
        get { __data[dynamicMember: "`return`"] }
        set { __data[dynamicMember: "`return`"] = newValue }
      }

      public var `throw`: String {
        get { __data[dynamicMember: "`throw`"] }
        set { __data[dynamicMember: "`throw`"] = newValue }
      }

      public var `switch`: String {
        get { __data[dynamicMember: "`switch`"] }
        set { __data[dynamicMember: "`switch`"] = newValue }
      }

      public var `where`: String {
        get { __data[dynamicMember: "`where`"] }
        set { __data[dynamicMember: "`where`"] = newValue }
      }

      public var `while`: String {
        get { __data[dynamicMember: "`while`"] }
        set { __data[dynamicMember: "`while`"] = newValue }
      }

      public var `as`: String {
        get { __data[dynamicMember: "`as`"] }
        set { __data[dynamicMember: "`as`"] = newValue }
      }

      public var `false`: String {
        get { __data[dynamicMember: "`false`"] }
        set { __data[dynamicMember: "`false`"] = newValue }
      }

      public var `is`: String {
        get { __data[dynamicMember: "`is`"] }
        set { __data[dynamicMember: "`is`"] = newValue }
      }

      public var `nil`: String {
        get { __data[dynamicMember: "`nil`"] }
        set { __data[dynamicMember: "`nil`"] = newValue }
      }

      public var `self`: String {
        get { __data[dynamicMember: "`self`"] }
        set { __data[dynamicMember: "`self`"] = newValue }
      }

      public var `super`: String {
        get { __data[dynamicMember: "`super`"] }
        set { __data[dynamicMember: "`super`"] = newValue }
      }

      public var `throws`: String {
        get { __data[dynamicMember: "`throws`"] }
        set { __data[dynamicMember: "`throws`"] = newValue }
      }

      public var `true`: String {
        get { __data[dynamicMember: "`true`"] }
        set { __data[dynamicMember: "`true`"] = newValue }
      }

      public var `try`: String {
        get { __data[dynamicMember: "`try`"] }
        set { __data[dynamicMember: "`try`"] = newValue }
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
      config: .mock(schemaName: "testschema", output: .mock(
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
        get { __data[dynamicMember: "enumField"] }
        set { __data[dynamicMember: "enumField"] = newValue }
      }

      public var inputField: GraphQLNullable<Testschema.InnerInputObject> {
        get { __data[dynamicMember: "inputField"] }
        set { __data[dynamicMember: "inputField"] = newValue }
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
      config: .mock(schemaName: "TESTSCHEMA", output: .mock(
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
        get { __data[dynamicMember: "enumField"] }
        set { __data[dynamicMember: "enumField"] = newValue }
      }

      public var inputField: GraphQLNullable<TESTSCHEMA.InnerInputObject> {
        get { __data[dynamicMember: "inputField"] }
        set { __data[dynamicMember: "inputField"] = newValue }
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
      config: .mock(schemaName: "TestSchema", output: .mock(
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
        get { __data[dynamicMember: "enumField"] }
        set { __data[dynamicMember: "enumField"] = newValue }
      }

      public var inputField: GraphQLNullable<TestSchema.InnerInputObject> {
        get { __data[dynamicMember: "inputField"] }
        set { __data[dynamicMember: "inputField"] = newValue }
      }
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 8, ignoringExtraLines: true))
  }

  func test__casing__givenLowercasedSchemaName_listField_generatesWithFirstUppercasedzNamespace() throws {
    // given
    buildSubject(
      fields: [GraphQLInputField.mock(
        "nullableListNullableItem",
        type: .list(.enum(.mock(name: "EnumValue"))),
        defaultValue: nil)],
      config: .mock(schemaName: "testschema")
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
      config: .mock(schemaName: "TESTSCHEMA")
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
      config: .mock(schemaName: "TestSchema")
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
}
