import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenInternalTestHelpers

class SelectionSetTemplateTests: XCTestCase {

  var schemaSDL: String!
  var document: String!
  var ir: IR!
  var operation: IR.Operation!
  var subject: SelectionSetTemplate!

  override func setUp() {
    super.setUp()
  }

  override func tearDown() {
    schemaSDL = nil
    document = nil
    ir = nil
    operation = nil
    subject = nil
    super.tearDown()
  }

  // MARK: - Helpers

  func buildSubjectAndOperation(
    named operationName: String = "TestOperation",
    configOutput: ApolloCodegenConfiguration.FileOutput = .mock(),
    inflectionRules: [ApolloCodegenLib.InflectionRule] = [],
    schemaDocumentation: ApolloCodegenConfiguration.Composition = .exclude,
    warningsOnDeprecatedUsage: ApolloCodegenConfiguration.Composition = .exclude,
    cocoapodsImportStatements: Bool = false
  ) throws {
    ir = try .mock(schema: schemaSDL, document: document)
    let operationDefinition = try XCTUnwrap(ir.compilationResult[operation: operationName])
    operation = ir.build(operation: operationDefinition)
    let config = ApolloCodegenConfiguration.mock(
      schemaName: "TestSchema",
      output: configOutput,
      options: .init(
        additionalInflectionRules: inflectionRules,
        schemaDocumentation: schemaDocumentation,
        cocoapodsCompatibleImportStatements: cocoapodsImportStatements,
        warningsOnDeprecatedUsage: warningsOnDeprecatedUsage
      )
    )
    subject = SelectionSetTemplate(
      generateInitializers: false,
      config: ApolloCodegen.ConfigurationContext(config: config)
    )
  }

  // MARK: - Tests

  func test__render_rendersClosingBracket() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      species: String!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        species
      }
    }
    """

    // when
    try buildSubjectAndOperation()

    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(String(actual.reversed())).to(equalLineByLine("}", ignoringExtraLines: true))
  }

  // MARK: Parent Type

  func test__render_parentType__givenParentTypeAs_Object_rendersParentType() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      species: String!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        species
      }
    }
    """

    let expected = """
      public static var __parentType: ApolloAPI.ParentType { TestSchema.Objects.Animal }
    """

    // when
    try buildSubjectAndOperation()

    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 6, ignoringExtraLines: true))
  }

  func test__render_parentType__givenParentTypeAs_Interface_rendersParentType() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        species
      }
    }
    """

    let expected = """
      public static var __parentType: ApolloAPI.ParentType { TestSchema.Interfaces.Animal }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 6, ignoringExtraLines: true))
  }

  func test__render_parentType__givenParentTypeAs_Union_rendersParentType() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Dog {
      species: String!
    }

    union Animal = Dog
    """

    document = """
    query TestOperation {
      allAnimals {
        ... on Dog {
          species
        }
      }
    }
    """

    let expected = """
      public static var __parentType: ApolloAPI.ParentType { TestSchema.Unions.Animal }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 6, ignoringExtraLines: true))
  }

  func test__render_parentType__givenCocoapodsImportStatements_true_rendersParentTypeWithApolloNamespace() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Dog {
      species: String!
    }

    union Animal = Dog
    """

    document = """
    query TestOperation {
      allAnimals {
        ... on Dog {
          species
        }
      }
    }
    """

    let expected = """
      public static var __parentType: Apollo.ParentType { TestSchema.Unions.Animal }
    """

    // when
    try buildSubjectAndOperation(cocoapodsImportStatements: true)
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 6, ignoringExtraLines: true))
  }

  // MARK: - Selections

  func test__render_selections__givenCocoapodsImportStatements_true_rendersSelectionsWithApolloNamespace() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      FieldName: String!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        FieldName
      }
    }
    """

    let expected = """
      public static var __selections: [Apollo.Selection] { [
        .field("FieldName", String.self),
      ] }
    """

    // when
    try buildSubjectAndOperation(cocoapodsImportStatements: true)
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 7, ignoringExtraLines: true))
  }

  func test__render_selections__givenNilDirectSelections_doesNotRenderSelections() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Dog {
      species: String!
      nested: Nested!
    }

    type Nested {
      a: Int!
      b: Int!
    }

    interface Animal {
      nested: Nested!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        nested {
          a
        }
        ... on Dog {
          species
        }
      }
    }
    """

    let expected = """
      public static var __parentType: ApolloAPI.ParentType { TestSchema.Objects.Nested }
    
    """

    // when
    try buildSubjectAndOperation()
    let asDog_Nested = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"]?[as: "Dog"]?[field: "nested"] as? IR.EntityField
    )

    let actual = subject.render(field: asDog_Nested)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 6, ignoringExtraLines: true))
  }

  // MARK: Selections - Fields

  func test__render_selections__givenScalarFieldSelections_rendersAllFieldSelections() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      string: String!
      string_optional: String      
      int: Int!
      int_optional: Int
      float: Float!
      float_optional: Float
      boolean: Boolean!
      boolean_optional: Boolean
      custom: Custom!
      custom_optional: Custom
      custom_required_list: [Custom!]!
      custom_optional_list: [Custom!]
      list_required_required: [String!]!
      list_optional_required: [String!]
      list_required_optional: [String]!
      list_optional_optional: [String]
      nestedList_required_required_required: [[String!]!]!
      nestedList_required_required_optional: [[String]!]!
      nestedList_required_optional_optional: [[String]]!
      nestedList_required_optional_required: [[String!]]!
      nestedList_optional_required_required: [[String!]!]
      nestedList_optional_required_optional: [[String]!]
      nestedList_optional_optional_required: [[String!]]
      nestedList_optional_optional_optional: [[String]]
    }

    scalar Custom
    """

    document = """
    query TestOperation {
      allAnimals {
        string
        string_optional
        int
        int_optional
        float
        float_optional
        boolean
        boolean_optional
        custom
        custom_optional
        custom_required_list
        custom_optional_list
        list_required_required
        list_optional_required
        list_required_optional
        list_optional_optional
        nestedList_required_required_required
        nestedList_required_required_optional
        nestedList_required_optional_optional
        nestedList_required_optional_required
        nestedList_optional_required_required
        nestedList_optional_required_optional
        nestedList_optional_optional_required
        nestedList_optional_optional_optional
      }
    }
    """

    let expected = """
      public static var __selections: [ApolloAPI.Selection] { [
        .field("string", String.self),
        .field("string_optional", String?.self),
        .field("int", Int.self),
        .field("int_optional", Int?.self),
        .field("float", Double.self),
        .field("float_optional", Double?.self),
        .field("boolean", Bool.self),
        .field("boolean_optional", Bool?.self),
        .field("custom", TestSchema.Custom.self),
        .field("custom_optional", TestSchema.Custom?.self),
        .field("custom_required_list", [TestSchema.Custom].self),
        .field("custom_optional_list", [TestSchema.Custom]?.self),
        .field("list_required_required", [String].self),
        .field("list_optional_required", [String]?.self),
        .field("list_required_optional", [String?].self),
        .field("list_optional_optional", [String?]?.self),
        .field("nestedList_required_required_required", [[String]].self),
        .field("nestedList_required_required_optional", [[String?]].self),
        .field("nestedList_required_optional_optional", [[String?]?].self),
        .field("nestedList_required_optional_required", [[String]?].self),
        .field("nestedList_optional_required_required", [[String]]?.self),
        .field("nestedList_optional_required_optional", [[String?]]?.self),
        .field("nestedList_optional_optional_required", [[String]?]?.self),
        .field("nestedList_optional_optional_optional", [[String?]?]?.self),
      ] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 7, ignoringExtraLines: true))
  }

  func test__render_selections__givenCustomScalar_rendersFieldSelectionsWithNamespaceInAllConfigurations() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      custom: Custom!
      custom_optional: Custom
      custom_required_list: [Custom!]!
      custom_optional_list: [Custom!]
      lowercaseCustom: lowercaseCustom!
    }

    scalar Custom
    scalar lowercaseCustom
    """

    document = """
    query TestOperation {
      allAnimals {
        custom
        custom_optional
        custom_required_list
        custom_optional_list
        lowercaseCustom
      }
    }
    """

    let expected = """
      public static var __selections: [ApolloAPI.Selection] { [
        .field("custom", TestSchema.Custom.self),
        .field("custom_optional", TestSchema.Custom?.self),
        .field("custom_required_list", [TestSchema.Custom].self),
        .field("custom_optional_list", [TestSchema.Custom]?.self),
        .field("lowercaseCustom", TestSchema.LowercaseCustom.self),
      ] }
    """

    let tests: [ApolloCodegenConfiguration.FileOutput] = [
      .mock(moduleType: .swiftPackageManager, operations: .relative(subpath: nil)),
      .mock(moduleType: .swiftPackageManager, operations: .absolute(path: "custom")),
      .mock(moduleType: .swiftPackageManager, operations: .inSchemaModule),
      .mock(moduleType: .other, operations: .relative(subpath: nil)),
      .mock(moduleType: .other, operations: .absolute(path: "custom")),
      .mock(moduleType: .other, operations: .inSchemaModule),
      .mock(moduleType: .embeddedInTarget(name: "CustomTarget"), operations: .relative(subpath: nil)),
      .mock(moduleType: .embeddedInTarget(name: "CustomTarget"), operations: .absolute(path: "custom")),
      .mock(moduleType: .embeddedInTarget(name: "CustomTarget"), operations: .inSchemaModule)
    ]

    for test in tests {
      // when
      try buildSubjectAndOperation(configOutput: test)
      let allAnimals = try XCTUnwrap(
        operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
      )

      let actual = subject.render(field: allAnimals)

      // then
      expect(actual).to(equalLineByLine(expected, atLine: 7, ignoringExtraLines: true))
    }
  }

  func test__render_selections__givenEnumField_rendersFieldSelectionsWithNamespaceInAllConfigurations() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      testEnum: TestEnum!
      testEnumOptional: TestEnumOptional
      lowercaseEnum: lowercaseEnum!
    }

    enum TestEnum {
      CASE_ONE
    }

    enum TestEnumOptional {
      CASE_ONE
    }

    enum lowercaseEnum {
      CASE_ONE
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        testEnum
        testEnumOptional
        lowercaseEnum
      }
    }
    """

    let expected = """
      public static var __selections: [ApolloAPI.Selection] { [
        .field("testEnum", GraphQLEnum<TestSchema.TestEnum>.self),
        .field("testEnumOptional", GraphQLEnum<TestSchema.TestEnumOptional>?.self),
        .field("lowercaseEnum", GraphQLEnum<TestSchema.LowercaseEnum>.self),
      ] }
    """

    let tests: [ApolloCodegenConfiguration.FileOutput] = [
      .mock(moduleType: .swiftPackageManager, operations: .relative(subpath: nil)),
      .mock(moduleType: .swiftPackageManager, operations: .absolute(path: "custom")),
      .mock(moduleType: .swiftPackageManager, operations: .inSchemaModule),
      .mock(moduleType: .other, operations: .relative(subpath: nil)),
      .mock(moduleType: .other, operations: .absolute(path: "custom")),
      .mock(moduleType: .other, operations: .inSchemaModule),
      .mock(moduleType: .embeddedInTarget(name: "CustomTarget"), operations: .relative(subpath: nil)),
      .mock(moduleType: .embeddedInTarget(name: "CustomTarget"), operations: .absolute(path: "custom")),
      .mock(moduleType: .embeddedInTarget(name: "CustomTarget"), operations: .inSchemaModule)
    ]

    for test in tests {
      // when
      try buildSubjectAndOperation(configOutput: test)
      let allAnimals = try XCTUnwrap(
        operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
      )

      let actual = subject.render(field: allAnimals)

      // then
      expect(actual).to(equalLineByLine(expected, atLine: 7, ignoringExtraLines: true))
    }
  }

  func test__render_selections__givenFieldWithUppercasedName_rendersFieldSelections() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      FieldName: String!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        FieldName
      }
    }
    """

    let expected = """
      public static var __selections: [ApolloAPI.Selection] { [
        .field("FieldName", String.self),
      ] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 7, ignoringExtraLines: true))
  }

  func test__render_selections__givenFieldWithAlias_rendersFieldSelections() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      string: String!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        aliased: string
      }
    }
    """

    let expected = """
      public static var __selections: [ApolloAPI.Selection] { [
        .field("string", alias: "aliased", String.self),
      ] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 7, ignoringExtraLines: true))
  }

  func test__render_selections__givenEntityFieldWithNameNotMatchingType_rendersFieldSelections() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      predator: Animal!
      lowercaseType: lowercaseType!
      species: String!
    }

    type lowercaseType {
      a: String!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        predator {
          species
        }
        lowercaseType {
          a
        }
      }
    }
    """

    let expected = """
      public static var __selections: [ApolloAPI.Selection] { [
        .field("predator", Predator.self),
        .field("lowercaseType", LowercaseType.self),
      ] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 7, ignoringExtraLines: true))
  }

  // MARK: Selections - Fields - Reserved Keywords & Special Names

  func test__render_selections__givenFieldsWithSwiftReservedKeywordNames_rendersFieldsNotBacktickEscaped() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      associatedtype: String!
      class: String!
      deinit: String!
      enum: String!
      extension: String!
      fileprivate: String!
      func: String!
      import: String!
      init: String!
      inout: String!
      internal: String!
      let: String!
      operator: String!
      private: String!
      precedencegroup: String!
      protocol: String!
      Protocol: String!
      public: String!
      rethrows: String!
      static: String!
      struct: String!
      subscript: String!
      typealias: String!
      var: String!
      break: String!
      case: String!
      catch: String!
      continue: String!
      default: String!
      defer: String!
      do: String!
      else: String!
      fallthrough: String!
      for: String!
      guard: String!
      if: String!
      in: String!
      repeat: String!
      return: String!
      throw: String!
      switch: String!
      where: String!
      while: String!
      as: String!
      false: String!
      is: String!
      nil: String!
      self: String!
      Self: String!
      super: String!
      throws: String!
      true: String!
      try: String!
      _: String!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        associatedtype
        class
        deinit
        enum
        extension
        fileprivate
        func
        import
        init
        inout
        internal
        let
        operator
        private
        precedencegroup
        protocol
        Protocol
        public
        rethrows
        static
        struct
        subscript
        typealias
        var
        break
        case
        catch
        continue
        default
        defer
        do
        else
        fallthrough
        for
        guard
        if
        in
        repeat
        return
        throw
        switch
        where
        while
        as
        false
        is
        nil
        self
        Self
        super
        throws
        true
        try
        _
      }
    }
    """

    let expected = """
      public static var __selections: [ApolloAPI.Selection] { [
        .field("associatedtype", String.self),
        .field("class", String.self),
        .field("deinit", String.self),
        .field("enum", String.self),
        .field("extension", String.self),
        .field("fileprivate", String.self),
        .field("func", String.self),
        .field("import", String.self),
        .field("init", String.self),
        .field("inout", String.self),
        .field("internal", String.self),
        .field("let", String.self),
        .field("operator", String.self),
        .field("private", String.self),
        .field("precedencegroup", String.self),
        .field("protocol", String.self),
        .field("Protocol", String.self),
        .field("public", String.self),
        .field("rethrows", String.self),
        .field("static", String.self),
        .field("struct", String.self),
        .field("subscript", String.self),
        .field("typealias", String.self),
        .field("var", String.self),
        .field("break", String.self),
        .field("case", String.self),
        .field("catch", String.self),
        .field("continue", String.self),
        .field("default", String.self),
        .field("defer", String.self),
        .field("do", String.self),
        .field("else", String.self),
        .field("fallthrough", String.self),
        .field("for", String.self),
        .field("guard", String.self),
        .field("if", String.self),
        .field("in", String.self),
        .field("repeat", String.self),
        .field("return", String.self),
        .field("throw", String.self),
        .field("switch", String.self),
        .field("where", String.self),
        .field("while", String.self),
        .field("as", String.self),
        .field("false", String.self),
        .field("is", String.self),
        .field("nil", String.self),
        .field("self", String.self),
        .field("Self", String.self),
        .field("super", String.self),
        .field("throws", String.self),
        .field("true", String.self),
        .field("try", String.self),
        .field("_", String.self),
      ] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 7, ignoringExtraLines: true))
  }

  func test__render_selections__givenEntityFieldWithUnderscorePrefixedName_rendersFieldSelectionsWithTypeFirstUppercased() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      _oneUnderscore: Animal!
      __twoUnderscore: Animal!
      species: String!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        _oneUnderscore {
          species
        }
        __twoUnderscore {
          species
        }
      }
    }
    """

    let expected = """
      public static var __selections: [ApolloAPI.Selection] { [
        .field("_oneUnderscore", _OneUnderscore.self),
        .field("__twoUnderscore", __TwoUnderscore.self),
      ] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 7, ignoringExtraLines: true))
  }

  func test__render_selections__givenEntityFieldWithSwiftKeywordAndApolloReservedTypeNames_rendersFieldSelectionsWithTypeNameSuffixed() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      self: Animal!
      parentType: Animal!
      dataDict: Animal!
      documentType: Animal!
      selection: Animal!
      schema: Animal!
      fragmentContainer: Animal!
      string: Animal!
      bool: Animal!
      int: Animal!
      float: Animal!
      double: Animal!
      iD: Animal!
      any: Animal!
      protocol: Animal!
      type: Animal!
      species: String!
      _: Animal!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        self {
          species
        }
        parentType {
          species
        }
        dataDict {
          species
        }
        documentType {
          species
        }
        selection {
          species
        }
        schema {
          species
        }
        fragmentContainer {
          species
        }
        string {
          species
        }
        bool {
          species
        }
        int {
          species
        }
        float {
          species
        }
        double {
          species
        }
        iD {
          species
        }
        any {
          species
        }
        protocol {
          species
        }
        type {
          species
        }
        _ {
          species
        }
      }
    }
    """

    let expected = """
      public static var __selections: [ApolloAPI.Selection] { [
        .field("self", Self_SelectionSet.self),
        .field("parentType", ParentType_SelectionSet.self),
        .field("dataDict", DataDict_SelectionSet.self),
        .field("documentType", DocumentType_SelectionSet.self),
        .field("selection", Selection_SelectionSet.self),
        .field("schema", Schema_SelectionSet.self),
        .field("fragmentContainer", FragmentContainer_SelectionSet.self),
        .field("string", String_SelectionSet.self),
        .field("bool", Bool_SelectionSet.self),
        .field("int", Int_SelectionSet.self),
        .field("float", Float_SelectionSet.self),
        .field("double", Double_SelectionSet.self),
        .field("iD", ID_SelectionSet.self),
        .field("any", Any_SelectionSet.self),
        .field("protocol", Protocol_SelectionSet.self),
        .field("type", Type_SelectionSet.self),
        .field("_", __SelectionSet.self),
      ] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 7, ignoringExtraLines: true))
  }

  // MARK: Selections - Fields - Arguments

  func test__render_selections__givenFieldWithArgumentWithConstantValue_rendersFieldSelections() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      string(variable: Int): String!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        aliased: string(variable: 3)
      }
    }
    """

    let expected = """
      public static var __selections: [ApolloAPI.Selection] { [
        .field("string", alias: "aliased", String.self, arguments: ["variable": 3]),
      ] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 7, ignoringExtraLines: true))
  }

  func test__render_selections__givenFieldWithArgumentWithNullConstantValue_rendersFieldSelections() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      string(variable: Int): String!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        aliased: string(variable: null)
      }
    }
    """

    let expected = """
      public static var __selections: [ApolloAPI.Selection] { [
        .field("string", alias: "aliased", String.self, arguments: ["variable": .null]),
      ] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 7, ignoringExtraLines: true))
  }

  func test__render_selections__givenFieldWithArgumentWithVariableValue_rendersFieldSelections() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      string(variable: Int): String!
    }
    """

    document = """
    query TestOperation($var: Int) {
      allAnimals {
        aliased: string(variable: $var)
      }
    }
    """

    let expected = """
      public static var __selections: [ApolloAPI.Selection] { [
        .field("string", alias: "aliased", String.self, arguments: ["variable": .variable("var")]),
      ] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 7, ignoringExtraLines: true))
  }

  func test__render_selections__givenFieldWithArgumentOfInputObjectTypeWithNullableFields_withConstantValues_rendersFieldSelections() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      string(input: TestInput): String!
    }

    input TestInput {
      string: String
      int: Int
      float: Float
      bool: Boolean
      list: [String]
      enum: TestEnum
      innerInput: InnerInput
    }

    input InnerInput {
      string: String
      enumList: [TestEnum]
    }

    enum TestEnum {
      CaseOne
      CaseTwo
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        aliased: string(input: {
          string: "ABCD",
          int: 3,
          float: 123.456,
          bool: true,
          list: ["A", "B"],
          enum: CaseOne,
          innerInput: {
            string: "EFGH",
            enumList: [CaseOne, CaseTwo]
          }
        })
      }
    }
    """

    let expected = """
      public static var __selections: [ApolloAPI.Selection] { [
        .field("string", alias: "aliased", String.self, arguments: ["input": [
          "string": "ABCD",
          "int": 3,
          "float": 123.456,
          "bool": true,
          "list": ["A", "B"],
          "enum": "CaseOne",
          "innerInput": [
            "string": "EFGH",
            "enumList": ["CaseOne", "CaseTwo"]
          ]
        ]]),
      ] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 7, ignoringExtraLines: true))
  }

  // MARK: Selections - Type Cases

  func test__render_selections__givenTypeCases_rendersTypeCaseSelections() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      string: String!
    }

    interface Pet {
      int: Int!
    }

    interface lowercaseInterface {
      int: Int!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        ... on Pet {
          int
        }
        ... on lowercaseInterface {
          int
        }
      }
    }
    """

    let expected = """
      public static var __selections: [ApolloAPI.Selection] { [
        .inlineFragment(AsPet.self),
        .inlineFragment(AsLowercaseInterface.self),
      ] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 7, ignoringExtraLines: true))
  }

  // MARK: Selections - Fragments

  func test__render_selections__givenFragments_rendersFragmentSelections() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      string: String!
      int: Int!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        ...FragmentA
        ...lowercaseFragment
      }
    }

    fragment FragmentA on Animal {
      int
    }

    fragment lowercaseFragment on Animal {
      string
    }
    """

    let expected = """
      public static var __selections: [ApolloAPI.Selection] { [
        .fragment(FragmentA.self),
        .fragment(LowercaseFragment.self),
      ] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 7, ignoringExtraLines: true))
  }

  // MARK: Selections - Include/Skip

  func test__render_selections__givenFieldWithIncludeCondition_rendersFieldSelections() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      fieldName: String!
    }
    """

    document = """
    query TestOperation($a: Boolean!) {
      allAnimals {
        fieldName @include(if: $a)
      }
    }
    """

    let expected = """
      public static var __selections: [ApolloAPI.Selection] { [
        .include(if: "a", .field("fieldName", String.self)),
      ] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 7, ignoringExtraLines: true))
  }

  func test__render_selections__givenFieldWithSkipCondition_rendersFieldSelections() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      fieldName: String!
    }
    """

    document = """
    query TestOperation($b: Boolean!) {
      allAnimals {
        fieldName @skip(if: $b)
      }
    }
    """

    let expected = """
      public static var __selections: [ApolloAPI.Selection] { [
        .include(if: !"b", .field("fieldName", String.self)),
      ] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 7, ignoringExtraLines: true))
  }

  func test__render_selections__givenFieldWithMultipleConditions_rendersFieldSelections() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      fieldName: String!
    }
    """

    document = """
    query TestOperation($b: Boolean!) {
      allAnimals {
        fieldName @skip(if: $b) @include(if: $a)
      }
    }
    """

    let expected = """
      public static var __selections: [ApolloAPI.Selection] { [
        .include(if: !"b" && "a", .field("fieldName", String.self)),
      ] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 7, ignoringExtraLines: true))
  }

  func test__render_selections__givenMergedFieldsWithMultipleConditions_rendersFieldSelections() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      fieldName: String!
    }
    """

    document = """
    query TestOperation($b: Boolean!) {
      allAnimals {
        fieldName @skip(if: $b) @include(if: $a)
        fieldName @skip(if: $c)
        fieldName @include(if: $d) @skip(if: $e)
        fieldName @include(if: $f)
      }
    }
    """

    let expected = """
      public static var __selections: [ApolloAPI.Selection] { [
        .include(if: (!"b" && "a") || !"c" || ("d" && !"e") || "f", .field("fieldName", String.self)),
      ] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 7, ignoringExtraLines: true))
  }

  func test__render_selections__givenMultipleSelectionsWithSameIncludeConditions_rendersFieldSelections() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      fieldA: String!
      fieldB: String!
    }

    interface Pet {
      fieldA: String!
    }
    """

    document = """
    query TestOperation($a: Boolean!) {
      allAnimals {
        fieldA @include(if: $a)
        fieldB @include(if: $a)
        ... on Pet @include(if: $a) {
          fieldA
        }
        ...FragmentA @include(if: $a)
      }
    }

    fragment FragmentA on Animal {
      fieldA
    }
    """

    let expected = """
      public static var __selections: [ApolloAPI.Selection] { [
        .include(if: "a", [
          .field("fieldA", String.self),
          .field("fieldB", String.self),
          .inlineFragment(AsPet.self),
          .fragment(FragmentA.self),
        ]),
      ] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 7, ignoringExtraLines: true))
  }

  func test__render_selections__givenFragmentWithNonMatchingTypeAndInclusionCondition_rendersTypeCaseSelectionWithInclusionCondition() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      string: String!
      int: Int!
    }

    type Pet {
      string: String!
      int: Int!
    }
    """

    document = """
    query TestOperation($a: Boolean!) {
      allAnimals {
        ...FragmentA @include(if: $a)
      }
    }

    fragment FragmentA on Pet {
      int
    }
    """

    let expected = """
      public static var __selections: [ApolloAPI.Selection] { [
        .include(if: "a", .inlineFragment(AsPet.self)),
      ] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 7, ignoringExtraLines: true))
  }

  func test__render_selections__givenInlineFragmentOnSameTypeWithConditions_rendersInlineFragmentSelectionSetAccessorWithCorrectName() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      fieldA: String!
    }

    interface Pet {
      fieldA: String!
    }
    """

    document = """
    query TestOperation($a: Boolean!) {
      allAnimals {
        ... on Animal @include(if: $a) {
          fieldA
        }
      }
    }
    """

    let expected = """
      public static var __selections: [ApolloAPI.Selection] { [
        .include(if: "a", .inlineFragment(IfA.self)),
      ] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 7, ignoringExtraLines: true))
  }

  func test__render_selections__givenFragmentWithInclusionConditionThatMatchesScope_rendersFragmentSelectionWithoutInclusionCondition() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      string: String!
      int: Int!
    }

    type Pet {
      string: String!
      int: Int!
    }
    """

    document = """
    query TestOperation($a: Boolean!) {
      allAnimals {
        ...FragmentA @include(if: $a)
      }
    }

    fragment FragmentA on Pet {
      int
    }
    """

    let expected = """
      public static var __selections: [ApolloAPI.Selection] { [
        .fragment(FragmentA.self),
      ] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals_asPet = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"]?[as: "Pet", if: "a"]
    )

    let actual = subject.render(inlineFragment: allAnimals_asPet)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 8, ignoringExtraLines: true))
  }

  // MARK: - Field Accessors - Scalar

  func test__render_fieldAccessors__givenScalarFields_rendersAllFieldAccessors() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      string: String!
      string_optional: String
      int: Int!
      int_optional: Int
      float: Float!
      float_optional: Float
      boolean: Boolean!
      boolean_optional: Boolean
      custom: Custom!
      custom_optional: Custom
      custom_required_list: [Custom!]!
      custom_optional_list: [Custom!]
      list_required_required: [String!]!
      list_optional_required: [String!]
      list_required_optional: [String]!
      list_optional_optional: [String]
      nestedList_required_required_required: [[String!]!]!
      nestedList_required_required_optional: [[String]!]!
      nestedList_required_optional_optional: [[String]]!
      nestedList_required_optional_required: [[String!]]!
      nestedList_optional_required_required: [[String!]!]
      nestedList_optional_required_optional: [[String]!]
      nestedList_optional_optional_required: [[String!]]
      nestedList_optional_optional_optional: [[String]]
    }

    scalar Custom
    """

    document = """
    query TestOperation {
      allAnimals {
        string
        string_optional
        int
        int_optional
        float
        float_optional
        boolean
        boolean_optional
        custom
        custom_optional
        custom_required_list
        custom_optional_list
        list_required_required
        list_optional_required
        list_required_optional
        list_optional_optional
        nestedList_required_required_required
        nestedList_required_required_optional
        nestedList_required_optional_optional
        nestedList_required_optional_required
        nestedList_optional_required_required
        nestedList_optional_required_optional
        nestedList_optional_optional_required
        nestedList_optional_optional_optional
      }
    }
    """

    let expected = """
      public var string: String { __data["string"] }
      public var string_optional: String? { __data["string_optional"] }
      public var int: Int { __data["int"] }
      public var int_optional: Int? { __data["int_optional"] }
      public var float: Double { __data["float"] }
      public var float_optional: Double? { __data["float_optional"] }
      public var boolean: Bool { __data["boolean"] }
      public var boolean_optional: Bool? { __data["boolean_optional"] }
      public var custom: TestSchema.Custom { __data["custom"] }
      public var custom_optional: TestSchema.Custom? { __data["custom_optional"] }
      public var custom_required_list: [TestSchema.Custom] { __data["custom_required_list"] }
      public var custom_optional_list: [TestSchema.Custom]? { __data["custom_optional_list"] }
      public var list_required_required: [String] { __data["list_required_required"] }
      public var list_optional_required: [String]? { __data["list_optional_required"] }
      public var list_required_optional: [String?] { __data["list_required_optional"] }
      public var list_optional_optional: [String?]? { __data["list_optional_optional"] }
      public var nestedList_required_required_required: [[String]] { __data["nestedList_required_required_required"] }
      public var nestedList_required_required_optional: [[String?]] { __data["nestedList_required_required_optional"] }
      public var nestedList_required_optional_optional: [[String?]?] { __data["nestedList_required_optional_optional"] }
      public var nestedList_required_optional_required: [[String]?] { __data["nestedList_required_optional_required"] }
      public var nestedList_optional_required_required: [[String]]? { __data["nestedList_optional_required_required"] }
      public var nestedList_optional_required_optional: [[String?]]? { __data["nestedList_optional_required_optional"] }
      public var nestedList_optional_optional_required: [[String]?]? { __data["nestedList_optional_optional_required"] }
      public var nestedList_optional_optional_optional: [[String?]?]? { __data["nestedList_optional_optional_optional"] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 34, ignoringExtraLines: true))
  }

  func test__render_fieldAccessors__givenCustomScalarFields_rendersFieldAccessorsWithNamespaceWhenRequiredInAllConfigurations() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      custom: Custom!
      custom_optional: Custom
      custom_required_list: [Custom!]!
      custom_optional_list: [Custom!]
      lowercaseScalar: lowercaseScalar!
    }

    scalar Custom
    scalar lowercaseScalar
    """

    document = """
    query TestOperation {
      allAnimals {
        custom
        custom_optional
        custom_required_list
        custom_optional_list
        lowercaseScalar
      }
    }
    """

    let expected = """
      public var custom: TestSchema.Custom { __data["custom"] }
      public var custom_optional: TestSchema.Custom? { __data["custom_optional"] }
      public var custom_required_list: [TestSchema.Custom] { __data["custom_required_list"] }
      public var custom_optional_list: [TestSchema.Custom]? { __data["custom_optional_list"] }
      public var lowercaseScalar: TestSchema.LowercaseScalar { __data["lowercaseScalar"] }
    """

    let tests: [ApolloCodegenConfiguration.FileOutput] = [
      .mock(moduleType: .swiftPackageManager, operations: .relative(subpath: nil)),
      .mock(moduleType: .swiftPackageManager, operations: .absolute(path: "custom")),
      .mock(moduleType: .swiftPackageManager, operations: .inSchemaModule),
      .mock(moduleType: .other, operations: .relative(subpath: nil)),
      .mock(moduleType: .other, operations: .absolute(path: "custom")),
      .mock(moduleType: .other, operations: .inSchemaModule),
      .mock(moduleType: .embeddedInTarget(name: "CustomTarget"), operations: .relative(subpath: nil)),
      .mock(moduleType: .embeddedInTarget(name: "CustomTarget"), operations: .absolute(path: "custom")),
      .mock(moduleType: .embeddedInTarget(name: "CustomTarget"), operations: .inSchemaModule)
    ]

    for test in tests {
      // when
      try buildSubjectAndOperation(configOutput: test)
      let allAnimals = try XCTUnwrap(
        operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
      )

      let actual = subject.render(field: allAnimals)

      // then
      expect(actual).to(equalLineByLine(expected, atLine: 15, ignoringExtraLines: true))
    }
  }

  func test__render_fieldAccessors__givenEnumField_rendersFieldAccessorsWithNamespacedInAllConfigurations() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      testEnum: TestEnum!
      testEnumOptional: TestEnumOptional
      lowercaseEnum: lowercaseEnum!
    }

    enum TestEnum {
      CASE_ONE
    }

    enum TestEnumOptional {
      CASE_ONE
    }

    enum lowercaseEnum {
      CASE_ONE
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        testEnum
        testEnumOptional
        lowercaseEnum
      }
    }
    """

    let expected = """
      public var testEnum: GraphQLEnum<TestSchema.TestEnum> { __data["testEnum"] }
      public var testEnumOptional: GraphQLEnum<TestSchema.TestEnumOptional>? { __data["testEnumOptional"] }
      public var lowercaseEnum: GraphQLEnum<TestSchema.LowercaseEnum> { __data["lowercaseEnum"] }
    """

    let tests: [ApolloCodegenConfiguration.FileOutput] = [
      .mock(moduleType: .swiftPackageManager, operations: .relative(subpath: nil)),
      .mock(moduleType: .swiftPackageManager, operations: .absolute(path: "custom")),
      .mock(moduleType: .swiftPackageManager, operations: .inSchemaModule),
      .mock(moduleType: .other, operations: .relative(subpath: nil)),
      .mock(moduleType: .other, operations: .absolute(path: "custom")),
      .mock(moduleType: .other, operations: .inSchemaModule),
      .mock(moduleType: .embeddedInTarget(name: "CustomTarget"), operations: .relative(subpath: nil)),
      .mock(moduleType: .embeddedInTarget(name: "CustomTarget"), operations: .absolute(path: "custom")),
      .mock(moduleType: .embeddedInTarget(name: "CustomTarget"), operations: .inSchemaModule)
    ]

    for test in tests {
      // when
      try buildSubjectAndOperation(configOutput: test)
      let allAnimals = try XCTUnwrap(
        operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
      )

      let actual = subject.render(field: allAnimals)

      // then
      expect(actual).to(equalLineByLine(expected, atLine: 13, ignoringExtraLines: true))
    }
  }

  func test__render_fieldAccessors__givenFieldWithUpperCaseName_rendersFieldAccessorWithLowercaseName() throws {
    // given
    schemaSDL = """
    type Query {
      AllAnimals: [Animal!]
    }

    type Animal {
      FieldName: String!
    }

    scalar Custom
    """

    document = """
    query TestOperation {
      AllAnimals {
        FieldName
      }
    }
    """

    let expected = """
      public var fieldName: String { __data["FieldName"] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "AllAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 11, ignoringExtraLines: true))
  }

  func test__render_fieldAccessors__givenFieldWithAlias_rendersAllFieldAccessors() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      string: String!
    }

    scalar Custom
    """

    document = """
    query TestOperation {
      allAnimals {
        aliasedFieldName: string
      }
    }
    """

    let expected = """
      public var aliasedFieldName: String { __data["aliasedFieldName"] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 11, ignoringExtraLines: true))
  }

  func test__render_fieldAccessors__givenMergedScalarField_rendersFieldAccessor() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      a: String!
    }

    type Dog {
      b: String!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        a
        ... on Dog {
          b
        }
      }
    }
    """

    let expected = """
      public var b: String { __data["b"] }
      public var a: String { __data["a"] }
    """

    // when
    try buildSubjectAndOperation()
    let dog = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"]?[as: "Dog"]
    )

    let actual = subject.render(inlineFragment: dog)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 12, ignoringExtraLines: true))
  }

  // MARK: Field Accessors - Reserved Keywords + Special Names

  func test__render_fieldAccessors__givenFieldsWithSwiftReservedKeywordNames_rendersFieldsBacktickEscaped() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      associatedtype: String!
      class: String!
      deinit: String!
      enum: String!
      extension: String!
      fileprivate: String!
      func: String!
      import: String!
      init: String!
      inout: String!
      internal: String!
      let: String!
      operator: String!
      private: String!
      precedencegroup: String!
      protocol: String!
      Protocol: String!
      public: String!
      rethrows: String!
      static: String!
      struct: String!
      subscript: String!
      typealias: String!
      var: String!
      break: String!
      case: String!
      catch: String!
      continue: String!
      default: String!
      defer: String!
      do: String!
      else: String!
      fallthrough: String!
      for: String!
      guard: String!
      if: String!
      in: String!
      repeat: String!
      return: String!
      throw: String!
      switch: String!
      where: String!
      while: String!
      as: String!
      false: String!
      is: String!
      nil: String!
      self: String!
      Self: String!
      super: String!
      throws: String!
      true: String!
      try: String!
      _: String!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        associatedtype
        class
        deinit
        enum
        extension
        fileprivate
        func
        import
        init
        inout
        internal
        let
        operator
        private
        precedencegroup
        protocol
        Protocol
        public
        rethrows
        static
        struct
        subscript
        typealias
        var
        break
        case
        catch
        continue
        default
        defer
        do
        else
        fallthrough
        for
        guard
        if
        in
        repeat
        return
        throw
        switch
        where
        while
        as
        false
        is
        nil
        self
        Self
        super
        throws
        true
        try
      }
    }
    """

    let expected = """
      public var `associatedtype`: String { __data["associatedtype"] }
      public var `class`: String { __data["class"] }
      public var `deinit`: String { __data["deinit"] }
      public var `enum`: String { __data["enum"] }
      public var `extension`: String { __data["extension"] }
      public var `fileprivate`: String { __data["fileprivate"] }
      public var `func`: String { __data["func"] }
      public var `import`: String { __data["import"] }
      public var `init`: String { __data["init"] }
      public var `inout`: String { __data["inout"] }
      public var `internal`: String { __data["internal"] }
      public var `let`: String { __data["let"] }
      public var `operator`: String { __data["operator"] }
      public var `private`: String { __data["private"] }
      public var `precedencegroup`: String { __data["precedencegroup"] }
      public var `protocol`: String { __data["protocol"] }
      public var `protocol`: String { __data["Protocol"] }
      public var `public`: String { __data["public"] }
      public var `rethrows`: String { __data["rethrows"] }
      public var `static`: String { __data["static"] }
      public var `struct`: String { __data["struct"] }
      public var `subscript`: String { __data["subscript"] }
      public var `typealias`: String { __data["typealias"] }
      public var `var`: String { __data["var"] }
      public var `break`: String { __data["break"] }
      public var `case`: String { __data["case"] }
      public var `catch`: String { __data["catch"] }
      public var `continue`: String { __data["continue"] }
      public var `default`: String { __data["default"] }
      public var `defer`: String { __data["defer"] }
      public var `do`: String { __data["do"] }
      public var `else`: String { __data["else"] }
      public var `fallthrough`: String { __data["fallthrough"] }
      public var `for`: String { __data["for"] }
      public var `guard`: String { __data["guard"] }
      public var `if`: String { __data["if"] }
      public var `in`: String { __data["in"] }
      public var `repeat`: String { __data["repeat"] }
      public var `return`: String { __data["return"] }
      public var `throw`: String { __data["throw"] }
      public var `switch`: String { __data["switch"] }
      public var `where`: String { __data["where"] }
      public var `while`: String { __data["while"] }
      public var `as`: String { __data["as"] }
      public var `false`: String { __data["false"] }
      public var `is`: String { __data["is"] }
      public var `nil`: String { __data["nil"] }
      public var `self`: String { __data["self"] }
      public var `self`: String { __data["Self"] }
      public var `super`: String { __data["super"] }
      public var `throws`: String { __data["throws"] }
      public var `true`: String { __data["true"] }
      public var `try`: String { __data["try"] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(
      expected,
      atLine: 10 + allAnimals.selectionSet.selections.direct!.fields.count,
      ignoringExtraLines: true)
    )
  }

  func test__render_fieldAccessors__givenEntityFieldWithUnderscorePrefixedName_rendersFieldWithTypeFirstUppercased() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      _oneUnderscore: Animal!
      __twoUnderscore: Animal!
      species: String!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        _oneUnderscore {
          species
        }
        __twoUnderscore {
          species
        }
      }
    }
    """

    let expected = """
      public var _oneUnderscore: _OneUnderscore { __data["_oneUnderscore"] }
      public var __twoUnderscore: __TwoUnderscore { __data["__twoUnderscore"] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(
      expected,
      atLine: 10 + allAnimals.selectionSet.selections.direct!.fields.count,
      ignoringExtraLines: true)
    )
  }

  func test__render_fieldAccessors__givenEntityFieldWithSwiftKeywordAndApolloReservedTypeNames_rendersFieldAccessorWithTypeNameSuffixed() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      self: Animal!
      parentType: Animal!
      dataDict: Animal!
      selection: Animal!
      schema: Animal!
      fragmentContainer: Animal!
      string: Animal!
      bool: Animal!
      int: Animal!
      float: Animal!
      double: Animal!
      iD: Animal!
      any: Animal!
      protocol: Animal!
      type: Animal!
      species: String!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        self {
          species
        }
        parentType {
          species
        }
        dataDict {
          species
        }
        selection {
          species
        }
        schema {
          species
        }
        fragmentContainer {
          species
        }
        string {
          species
        }
        bool {
          species
        }
        int {
          species
        }
        float {
          species
        }
        double {
          species
        }
        iD {
          species
        }
        any {
          species
        }
        protocol {
          species
        }
        type {
          species
        }
      }
    }
    """

    let expected = """
      public var `self`: Self_SelectionSet { __data["self"] }
      public var parentType: ParentType_SelectionSet { __data["parentType"] }
      public var dataDict: DataDict_SelectionSet { __data["dataDict"] }
      public var selection: Selection_SelectionSet { __data["selection"] }
      public var schema: Schema_SelectionSet { __data["schema"] }
      public var fragmentContainer: FragmentContainer_SelectionSet { __data["fragmentContainer"] }
      public var string: String_SelectionSet { __data["string"] }
      public var bool: Bool_SelectionSet { __data["bool"] }
      public var int: Int_SelectionSet { __data["int"] }
      public var float: Float_SelectionSet { __data["float"] }
      public var double: Double_SelectionSet { __data["double"] }
      public var iD: ID_SelectionSet { __data["iD"] }
      public var any: Any_SelectionSet { __data["any"] }
      public var `protocol`: Protocol_SelectionSet { __data["protocol"] }
      public var type: Type_SelectionSet { __data["type"] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(
      expected,
      atLine: 10 + allAnimals.selectionSet.selections.direct!.fields.count,
      ignoringExtraLines: true)
    )
  }

  // MARK: Field Accessors - Entity

  func test__render_fieldAccessors__givenDirectEntityField_rendersFieldAccessor() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predator: Animal!
      lowercaseType: lowercaseType!
    }

    type lowercaseType {
      a: String!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        predator {
          species
        }
        lowercaseType {
          a
        }
      }
    }
    """

    let expected = """
      public var predator: Predator { __data["predator"] }
      public var lowercaseType: LowercaseType { __data["lowercaseType"] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 12, ignoringExtraLines: true))
  }

  func test__render_fieldAccessors__givenDirectEntityFieldWithAlias_rendersFieldAccessor() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predator: Animal!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        aliasedPredator: predator {
          species
        }
      }
    }
    """

    let expected = """
      public var aliasedPredator: AliasedPredator { __data["aliasedPredator"] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 11, ignoringExtraLines: true))
  }

  func test__render_fieldAccessors__givenDirectEntityFieldAsOptional_rendersFieldAccessor() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predator: Animal
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        predator {
          species
        }
      }
    }
    """

    let expected = """
      public var predator: Predator? { __data["predator"] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 11, ignoringExtraLines: true))
  }

  func test__render_fieldAccessors__givenDirectEntityFieldAsList_rendersFieldAccessor() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predators: [Animal!]
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        predators {
          species
        }
      }
    }
    """

    let expected = """
      public var predators: [Predator]? { __data["predators"] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 11, ignoringExtraLines: true))
  }

  func test__render_fieldAccessors__givenEntityFieldWithDirectSelectionsAndMergedFromFragment_rendersFieldAccessor() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      name: String!
      predator: Animal!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        ...PredatorDetails
        predator {
          name
        }
      }
    }

    fragment PredatorDetails on Animal {
      predator {
        species
      }
    }
    """

    let expected = """
      public var predator: Predator { __data["predator"] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 12, ignoringExtraLines: true))
  }

  // MARK: Field Accessors - Merged Fragment

  func test__render_fieldAccessors__givenEntityFieldMergedFromFragment_rendersFieldAccessor() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predator: Animal!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        ...PredatorDetails
      }
    }

    fragment PredatorDetails on Animal {
      predator {
        species
      }
    }
    """

    let expected = """
      public var predator: PredatorDetails.Predator { __data["predator"] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 11, ignoringExtraLines: true))
  }

  func test__render_fieldAccessors__givenEntityFieldMergedFromFragmentEntityNestedInEntity_rendersFieldAccessor() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predator: Animal!
      height: Height!
    }

    type Height {
      feet: Int!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        predator {
          species
        }
        ...PredatorDetails
      }
    }

    fragment PredatorDetails on Animal {
      predator {
        height {
          feet
        }
      }
    }
    """

    let expected = """
      public var species: String { __data["species"] }
      public var height: PredatorDetails.Predator.Height { __data["height"] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals_predator = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"]?[field: "predator"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals_predator)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 11, ignoringExtraLines: true))
  }

  func test__render_fieldAccessors__givenEntityFieldMergedFromFragmentInTypeCaseWithEntityNestedInEntity_rendersFieldAccessor() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predator: Animal!
      height: Height!
    }

    interface Pet {
      predator: Animal!
    }

    type Height {
      feet: Int!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        predator {
          species
        }
        ...PredatorDetails
      }
    }

    fragment PredatorDetails on Pet {
      predator {
        height {
          feet
        }
      }
    }
    """

    let expected = """
      public var height: PredatorDetails.Predator.Height { __data["height"] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals_asPet_predator = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"]?[as: "Pet"]?[field: "predator"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals_asPet_predator)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 9, ignoringExtraLines: true))
  }

  func test__render_fieldAccessors__givenEntityFieldMergedFromTypeCaseInFragment_rendersFieldAccessor() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predator: Animal!
      height: Height!
    }

    interface Pet {
      height: Height!
    }

    type Height {
      feet: Int!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        predator {
          species
          ...PredatorDetails
        }
      }
    }

    fragment PredatorDetails on Animal {
      ... on Pet {
        height {
          feet
        }
      }
    }
    """

    let predator_expected = """
      public var species: String { __data["species"] }

    """

    let predator_asPet_expected = """
      public var species: String { __data["species"] }
      public var height: PredatorDetails.AsPet.Height { __data["height"] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals_predator = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"]?[field: "predator"] as? IR.EntityField
    )

    let allAnimals_predator_asPet = try XCTUnwrap(allAnimals_predator[as: "Pet"])

    let allAnimals_predator_actual = subject.render(field: allAnimals_predator)
    let allAnimals_predator_asPet_actual = subject.render(inlineFragment: allAnimals_predator_asPet)

    // then
    expect(allAnimals_predator_actual).to(equalLineByLine(predator_expected, atLine: 12, ignoringExtraLines: true))
    expect(allAnimals_predator_asPet_actual).to(equalLineByLine(predator_asPet_expected, atLine: 9, ignoringExtraLines: true))
  }

  func test__render_fieldAccessors__givenEntityFieldMergedFromFragmentWithEntityNestedInEntityTypeCase_rendersFieldAccessor() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predator: Animal!
      height: Height!
    }

    interface Pet {
      height: Height!
    }

    type Height {
      feet: Int!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        predator {
          species
        }
        ...PredatorDetails
      }
    }

    fragment PredatorDetails on Animal {
      predator {
        ... on Pet {
          height {
            feet
          }
        }
      }
    }
    """

    let predator_expected = """
      public var species: String { __data["species"] }

    """

    let predator_asPet_expected = """
      public var species: String { __data["species"] }
      public var height: PredatorDetails.Predator.AsPet.Height { __data["height"] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals_predator = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"]?[field: "predator"] as? IR.EntityField
    )

    let allAnimals_predator_asPet = try XCTUnwrap(allAnimals_predator[as: "Pet"])

    let allAnimals_predator_actual = subject.render(field: allAnimals_predator)
    let allAnimals_predator_asPet_actual = subject.render(inlineFragment: allAnimals_predator_asPet)

    // then
    expect(allAnimals_predator_actual).to(equalLineByLine(predator_expected, atLine: 11, ignoringExtraLines: true))
    expect(allAnimals_predator_asPet_actual).to(equalLineByLine(predator_asPet_expected, atLine: 9, ignoringExtraLines: true))
  }

  func test__render_fieldAccessors__givenTypeCaseMergedFromFragmentWithOtherMergedFields_rendersFieldAccessor() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predator: Animal!
    }

    interface Pet {
      favoriteToy: Item
    }

    type Item {
      name: String!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        predator {
          ...PredatorDetails
          species
        }
      }
    }

    fragment PredatorDetails on Animal {
      ... on Pet {
        favoriteToy {
          ...PetToy
        }
      }
    }

    fragment PetToy on Item {
      name
    }
    """

    let predator_expected = """
      public var asPet: AsPet? { _asInlineFragment() }
    """

    // when
    try buildSubjectAndOperation()
    let predator = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"]?[field: "predator"] as? IR.EntityField
    )

    let predator_actual = subject.render(field: predator)

    // then
    expect(predator_actual)
      .to(equalLineByLine(predator_expected, atLine: 14, ignoringExtraLines: true))
  }

  func test__render_fieldAccessors__givenTypeCaseMergedFromFragmentWithNoOtherMergedFields_rendersFieldAccessor() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predator: Animal!
    }

    interface Pet {
      favoriteToy: Item
    }

    type Item {
      name: String!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        predator {
          ...PredatorDetails
        }
      }
    }

    fragment PredatorDetails on Animal {
      ... on Pet {
        favoriteToy {
          ...PetToy
        }
      }
    }

    fragment PetToy on Item {
      name
    }
    """

    let predator_expected = """
      public var asPet: AsPet? { _asInlineFragment() }
    """

    // when
    try buildSubjectAndOperation()
    let predator = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"]?[field: "predator"] as? IR.EntityField
    )

    let predator_actual = subject.render(field: predator)

    // then
    expect(predator_actual)
      .to(equalLineByLine(predator_expected, atLine: 11, ignoringExtraLines: true))
  }

  func test__render_fieldAccessors__givenEntityFieldMergedAsRootOfNestedFragment_rendersFieldAccessor() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predator: Animal!
    }

    interface Pet {
      favoriteToy: Item
    }

    type Item {
      name: String!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        predator {
          ...PredatorDetails
        }
      }
    }

    fragment PredatorDetails on Animal {
      ... on Pet {
        favoriteToy {
          ...PetToy
        }
      }
    }

    fragment PetToy on Item {
      name
    }
    """

    let predator_asPet_expected = """
      public var favoriteToy: FavoriteToy? { __data["favoriteToy"] }
    """

    // when
    try buildSubjectAndOperation()
    let predator_asPet = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"]?[field: "predator"]?[as: "Pet"]
    )

    let predator_asPet_actual = subject.render(inlineFragment: predator_asPet)

    // then
    expect(predator_asPet_actual)
      .to(equalLineByLine(predator_asPet_expected, atLine: 9, ignoringExtraLines: true))
  }

  // MARK: Field Accessors - Merged From Parent

  func test__render_fieldAccessors__givenEntityFieldMergedFromParent_rendersFieldAccessorWithDirectName() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predator: Animal!
    }

    type Dog implements Animal {
      species: String!
      predator: Animal!
      name: String!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        predator {
          species
        }
        ... on Dog {
          name
        }
      }
    }
    """

    let expected = """
      public var name: String { __data["name"] }
      public var predator: Predator { __data["predator"] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals_asDog = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"]?[as: "Dog"]
    )

    let actual = subject.render(inlineFragment: allAnimals_asDog)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 12, ignoringExtraLines: true))
  }

  func test__render_fieldAccessors__givenEntityFieldMergedFromSiblingTypeCase_rendersFieldAccessorWithCorrectName() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predator: Animal!
    }

    interface Pet implements Animal {
      species: String!
      predator: Animal!
    }

    type Dog implements Animal & Pet {
      species: String!
      predator: Animal!
      name: String!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        ... on Pet {
          predator {
            species
          }
        }
        ... on Dog {
          name
        }
      }
    }
    """

    let expected = """
      public var name: String { __data["name"] }
      public var predator: AsPet.Predator { __data["predator"] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals_asDog = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"]?[as: "Dog"]
    )

    let actual = subject.render(inlineFragment: allAnimals_asDog)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 12, ignoringExtraLines: true))
  }

  func test__render_fieldAccessors__givenEntityFieldNestedInEntityFieldMergedFromParent_rendersFieldAccessorWithCorrectName() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predator: Animal!
      height: Height!
    }

    type Dog implements Animal {
      name: String!
      species: String!
      predator: Animal!
      height: Height!
    }

    type Height {
      feet: Int!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        predator {
          height {
            feet
          }
        }
        ... on Dog {
          predator {
            species
          }
        }
      }
    }
    """

    let expected = """
      public var species: String { __data["species"] }
      public var height: AllAnimal.Predator.Height { __data["height"] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals_asDog_predator = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"]?[as: "Dog"]?[field: "predator"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals_asDog_predator)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 11, ignoringExtraLines: true))
  }

  func test__render_fieldAccessors__givenEntityFieldNestedInEntityFieldInMatchingTypeCaseMergedFromParent_rendersFieldAccessorWithCorrectName() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predator: Animal!
      height: Height!
    }

    interface Pet implements Animal {
      species: String!
      predator: Animal!
      height: Height!
    }

    type Dog implements Animal & Pet {
      name: String!
      species: String!
      predator: Animal!
      height: Height!
    }

    type Height {
      feet: Int!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        ... on Pet {
          predator {
            height {
              feet
            }
          }
        }
        ... on Dog {
          predator {
            species
          }
        }
      }
    }
    """

    let expected = """
      public var species: String { __data["species"] }
      public var height: AllAnimal.AsPet.Predator.Height { __data["height"] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals_asDog_predator = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"]?[as: "Dog"]?[field: "predator"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals_asDog_predator)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 11, ignoringExtraLines: true))
  }

  // MARK: Field Accessors - Include/Skip

  func test__render_fieldAccessor__givenNonNullFieldWithIncludeCondition_rendersAsOptional() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      fieldName: String!
    }
    """

    document = """
    query TestOperation($a: Boolean!) {
      allAnimals {
        fieldName @include(if: $a)
      }
    }
    """

    let expected = """
      public var fieldName: String? { __data["fieldName"] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 11, ignoringExtraLines: true))
  }

  func test__render_fieldAccessor__givenNonNullFieldWithSkipCondition_rendersAsOptional() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      fieldName: String!
    }
    """

    document = """
    query TestOperation($a: Boolean!) {
      allAnimals {
        fieldName @skip(if: $a)
      }
    }
    """

    let expected = """
      public var fieldName: String? { __data["fieldName"] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 11, ignoringExtraLines: true))
  }

  func test__render_fieldAccessors__givenEntityFieldMergedFromParentWithInclusionCondition_rendersFieldAccessorAsOptional() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predator: Animal!
    }

    type Dog implements Animal {
      species: String!
      predator: Animal!
      name: String!
    }
    """

    document = """
    query TestOperation($a: Boolean!) {
      allAnimals {
        predator @include(if: $a) {
          species
        }
        ... on Dog {
          name
        }
      }
    }
    """

    let expected = """
      public var name: String { __data["name"] }
      public var predator: Predator? { __data["predator"] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals_asDog = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"]?[as: "Dog"]
    )

    let actual = subject.render(inlineFragment: allAnimals_asDog)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 12, ignoringExtraLines: true))
  }

  func test__render_fieldAccessor__givenNonNullFieldMergedFromParentWithIncludeConditionThatMatchesScope_rendersAsNotOptional() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      fieldName: String!
      a: String!
    }
    """

    document = """
    query TestOperation($a: Boolean!) {
      allAnimals {
        fieldName @include(if: $a)
        ... @include(if: $a) {
          a
        }
      }
    }
    """

    let expected = """
      public var a: String { __data["a"] }
      public var fieldName: String { __data["fieldName"] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals_ifA = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"]?[if: "a"]
    )

    let actual = subject.render(inlineFragment: allAnimals_ifA)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 12, ignoringExtraLines: true))
  }

  func test__render_fieldAccessor__givenNonNullFieldWithIncludeConditionThatMatchesScope_rendersAsNotOptional() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      fieldName: String!
    }
    """

    document = """
    query TestOperation($a: Boolean!) {
      allAnimals @include(if: $a) {
        fieldName @include(if: $a)
      }
    }
    """

    let expected = """
      public var fieldName: String { __data["fieldName"] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 11, ignoringExtraLines: true))
  }

  func test__render_fieldAccessor__givenNonNullFieldMergedFromNestedEntityInNamedFragmentWithIncludeCondition_doesNotRenderField() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      child: Child!
    }

    type Child {
      a: String!
      b: String!
    }
    """

    document = """
    query TestOperation($a: Boolean!) {
      allAnimals {
        ...ChildFragment @include(if: $a)
        child {
          a
        }
      }
    }

    fragment ChildFragment on Animal {
      child {
        b
      }
    }
    """

    let expected = """
      public var a: String { __data["a"] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals_child = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"]?[field: "child"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals_child)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 11, ignoringExtraLines: true))
  }

  func test__render_fieldAccessor__givenNonNullFieldMergedFromNestedEntityInNamedFragmentWithIncludeCondition_inConditionalFragment_rendersFieldAsNonOptional() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      child: Child!
    }

    type Child {
      a: String!
      b: String!
    }
    """

    document = """
    query TestOperation($a: Boolean!) {
      allAnimals {
        ...ChildFragment @include(if: $a)
        child {
          a
        }
      }
    }

    fragment ChildFragment on Animal {
      child {
        b
      }
    }
    """

    let expected = """
      public var a: String { __data["a"] }
      public var b: String { __data["b"] }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals_child = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"]?[if: "a"]?[field: "child"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals_child)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 8, ignoringExtraLines: true))
  }

  // MARK: - Inline Fragment Accessors

  func test__render_inlineFragmentAccessors__givenDirectTypeCases_rendersTypeCaseAccessorWithCorrectName() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predator: Animal!
    }

    interface Pet implements Animal {
      species: String!
      predator: Animal!
      name: String!
    }

    type Dog implements Animal & Pet {
      species: String!
      predator: Animal!
      name: String!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        species
        ... on Pet {
          name
        }
        ... on Dog {
          name
        }
      }
    }
    """

    let expected = """
      public var asPet: AsPet? { _asInlineFragment() }
      public var asDog: AsDog? { _asInlineFragment() }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 15, ignoringExtraLines: true))
  }

  func test__render_inlineFragmentAccessors__givenMergedTypeCasesFromSingleMergedTypeCaseSource_rendersTypeCaseAccessorWithCorrectName() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predator: Animal!
    }

    interface Pet implements Animal {
      species: String!
      predator: Animal!
      name: String!
    }

    type Dog implements Animal & Pet {
      species: String!
      predator: Animal!
      name: String!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        species
        predator {
          ... on Pet {
            name
          }
        }
        ... on Dog {
          name
          predator {
            species
          }
        }
      }
    }
    """

    let expected = """
      public var asPet: AsPet? { _asInlineFragment() }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals_asDog_predator = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"]?[as: "Dog"]?[field: "predator"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals_asDog_predator)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 13, ignoringExtraLines: true))
  }

  // MARK: Inline Fragment Accessors - Include/Skip

  func test__render_inlineFragmentAccessors__givenInlineFragmentOnDifferentTypeWithCondition_rendersWithConditionInTypeCaseConversionFunction() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      fieldA: String!
    }

    interface Pet {
      fieldA: String!
    }
    """

    document = """
    query TestOperation($a: Boolean!) {
      allAnimals {
        ... on Pet @include(if: $a) {
          fieldA
        }
      }
    }
    """

    let expected = """
      public var asPet: AsPet? { _asInlineFragment(if: "a") }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 11, ignoringExtraLines: true))
  }

  func test__render_inlineFragmentAccessors__givenInlineFragmentOnDifferentTypeWithSkipCondition_rendersWithConditionInTypeCaseConversionFunction() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      fieldA: String!
    }

    interface Pet {
      fieldA: String!
    }
    """

    document = """
    query TestOperation($a: Boolean!) {
      allAnimals {
        ... on Pet @skip(if: $a) {
          fieldA
        }
      }
    }
    """

    let expected = """
      public var asPet: AsPet? { _asInlineFragment(if: !"a") }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 11, ignoringExtraLines: true))
  }

  func test__render_inlineFragmentAccessors__givenInlineFragmentOnDifferentTypeWithMultipleConditions_rendersWithConditionInTypeCaseConversionFunction() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      fieldA: String!
    }

    interface Pet {
      fieldA: String!
    }
    """

    document = """
    query TestOperation($a: Boolean!) {
      allAnimals {
        ... on Pet @include(if: $a) @skip(if: $b) {
          fieldA
        }
      }
    }
    """

    let expected = """
      public var asPet: AsPet? { _asInlineFragment(if: "a" && !"b") }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 11, ignoringExtraLines: true))
  }

  func test__render_inlineFragmentAccessors__givenInlineFragmentOnSameTypeWithMultipleConditions_rendersConditionalSelectionSetAccessor() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      fieldA: String!
    }

    interface Pet {
      fieldA: String!
    }
    """

    document = """
    query TestOperation($a: Boolean!) {
      allAnimals {
        ... on Animal @include(if: $a) @skip(if: $b) {
          fieldA
        }
      }
    }
    """

    let expected = """
      public var ifAAndNotB: IfAAndNotB? { _asInlineFragment(if: "a" && !"b") }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 11, ignoringExtraLines: true))
  }

  func test__render_inlineFragmentAccessor__givenNamedFragmentOnSameTypeWithInclusionCondition_rendersConditionalSelectionSetAccessor() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      string: String!
      int: Int!
    }
    """

    document = """
    query TestOperation($a: Boolean!) {
      allAnimals {
        ...FragmentA @include(if: $a)
      }
    }

    fragment FragmentA on Animal {
      int
    }
    """

    let expected = """
      public var ifA: IfA? { _asInlineFragment(if: "a") }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 11, ignoringExtraLines: true))
  }

  // MARK: - Fragment Accessors

  func test__render_fragmentAccessor__givenFragments_rendersFragmentAccessor() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      string: String!
      int: Int!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        ...FragmentA
        ...lowercaseFragment
      }
    }

    fragment FragmentA on Animal {
      int
    }

    fragment lowercaseFragment on Animal {
      string
    }
    """

    let expected = """
      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public var fragmentA: FragmentA { _toFragment() }
        public var lowercaseFragment: LowercaseFragment { _toFragment() }
      }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 15, ignoringExtraLines: true))
  }

  func test__render_fragmentAccessor__givenInheritedFragmentFromParent_rendersFragmentAccessor() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      string: String!
      int: Int!
    }

    type Cat implements Animal {
      string: String!
      int: Int!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        ...FragmentA
        ... on Cat {
          string
        }
      }
    }

    fragment FragmentA on Animal {
      int
    }

    fragment lowercaseFragment on Animal {
      string
    }
    """

    let expected = """
      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public var fragmentA: FragmentA { _toFragment() }
      }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals_asCat = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"]?[as: "Cat"]
    )

    let actual = subject.render(inlineFragment: allAnimals_asCat)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 15, ignoringExtraLines: true))
  }

  // MARK: - Fragment Accessors - Include Skip

  func test__render_fragmentAccessor__givenFragmentOnSameTypeWithInclusionCondition_rendersFragmentAccessorAsOptionalWithInclusionCondition() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      string: String!
      int: Int!
    }
    """

    document = """
    query TestOperation($a: Boolean!) {
      allAnimals {
        ...FragmentA @include(if: $a)
        ...lowercaseFragment
      }
    }

    fragment FragmentA on Animal {
      int
    }

    fragment lowercaseFragment on Animal {
      string
    }
    """

    let expected = """
      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public var fragmentA: FragmentA? { _toFragment(if: "a") }
        public var lowercaseFragment: LowercaseFragment { _toFragment() }
      }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 16, ignoringExtraLines: true))
  }

  func test__render_fragmentAccessor__givenFragmentOnSameTypeWithInclusionConditionThatMatchesScope_rendersFragmentAccessorAsNotOptional() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      string: String!
      int: Int!
    }
    """

    document = """
    query TestOperation($a: Boolean!) {
      allAnimals @include(if: $a) {
        ...FragmentA @include(if: $a)
      }
    }

    fragment FragmentA on Animal {
      int
    }
    """

    let expected = """
      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public var fragmentA: FragmentA { _toFragment() }
      }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 11, ignoringExtraLines: true))
  }

  func test__render_fragmentAccessor__givenFragmentOnSameTypeWithInclusionConditionThatPartiallyMatchesScope_rendersFragmentAccessorAsOptionalWithConditions() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      string: String!
      int: Int!
    }
    """

    document = """
    query TestOperation($a: Boolean!, $b: Boolean!) {
      allAnimals @include(if: $a) {
        ...FragmentA @include(if: $a) @include(if: $b)
      }
    }

    fragment FragmentA on Animal {
      int
    }
    """

    let expected = """
      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public var fragmentA: FragmentA? { _toFragment(if: "a" && "b") }
      }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 13, ignoringExtraLines: true))
  }

  func test__render_fragmentAccessor__givenFragmentMergedFromParent_withInclusionConditionThatMatchesScope_rendersFragmentAccessorAsNotOptional() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      string: String!
      int: Int!
    }
    """

    document = """
    query TestOperation($a: Boolean!) {
      allAnimals {
        ...FragmentA @include(if: $a)
      }
    }

    fragment FragmentA on Animal {
      int
    }
    """

    let expected = """
      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public var fragmentA: FragmentA { _toFragment() }
      }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals_ifA = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"]?[if: "a"]
    )

    let actual = subject.render(inlineFragment: allAnimals_ifA)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 11, ignoringExtraLines: true))
  }

  // MARK: - Nested Selection Sets

  func test__render_nestedSelectionSets__givenDirectEntityFieldAsList_rendersNestedSelectionSet() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predators: [Animal!]
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        predators {
          species
        }
      }
    }
    """

    let expected = """
      public var predators: [Predator]? { __data["predators"] }

      /// AllAnimal.Predator
      public struct Predator: TestSchema.SelectionSet {
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 11, ignoringExtraLines: true))
  }

  func test__render_nestedSelectionSets__givenDirectEntityFieldAsList_withIrregularPluralizationRule_rendersNestedSelectionSetWithCorrectSingularName() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      people: [Animal!]
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        people {
          species
        }
      }
    }
    """

    let expected = """
      public var people: [Person]? { __data["people"] }

      /// AllAnimal.Person
      public struct Person: TestSchema.SelectionSet {
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 11, ignoringExtraLines: true))
  }

  func test__render_nestedSelectionSets__givenDirectEntityFieldAsNonNullList_withIrregularPluralizationRule_rendersNestedSelectionSetWithCorrectSingularName() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      people: [Animal!]!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        people {
          species
        }
      }
    }
    """

    let expected = """
      public var people: [Person] { __data["people"] }

      /// AllAnimal.Person
      public struct Person: TestSchema.SelectionSet {
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 11, ignoringExtraLines: true))
  }

  func test__render_nestedSelectionSets__givenDirectEntityFieldAsList_withCustomIrregularPluralizationRule_rendersNestedSelectionSetWithCorrectSingularName() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      people: [Animal!]
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        people {
          species
        }
      }
    }
    """

    let expected = """
      public var people: [Peep]? { __data["people"] }

      /// AllAnimal.Peep
      public struct Peep: TestSchema.SelectionSet {
    """

    // when
    try buildSubjectAndOperation(inflectionRules: [
      ApolloCodegenLib.InflectionRule.irregular(singular: "Peep", plural: "people")
    ])

    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 11, ignoringExtraLines: true))
  }

  /// Explicit test for edge case surfaced in issue
  /// [#1825](https://github.com/apollographql/apollo-ios/issues/1825)
  func test__render_nestedSelectionSets__givenDirectEntityField_withTwoObjects_oneWithPluralizedNameAsObject_oneWithSingularNameAsList_rendersNestedSelectionSetsWithCorrectNames() throws {
    // given
    schemaSDL = """
    type Query {
      badge: [Badge]
      badges: ProductBadge
    }

    type Badge {
      a: String
    }

    type ProductBadge {
      b: String
    }
    """

    document = """
    query TestOperation {
      badge {
        a
      }
      badges {
        b
      }
    }
    """

    let expected = """
      public var badge: [Badge?]? { __data["badge"] }
      public var badges: Badges? { __data["badges"] }

      /// Badge
      public struct Badge: TestSchema.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ApolloAPI.ParentType { TestSchema.Objects.Badge }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("a", String?.self),
        ] }

        public var a: String? { __data["a"] }
      }

      /// Badges
      public struct Badges: TestSchema.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ApolloAPI.ParentType { TestSchema.Objects.ProductBadge }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("b", String?.self),
        ] }

        public var b: String? { __data["b"] }
      }
    """

    // when
    try buildSubjectAndOperation()

    let query = try XCTUnwrap(
      operation[field: "query"] as? IR.EntityField
    )

    let actual = subject.render(field: query)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 12, ignoringExtraLines: true))
  }

  /// Explicit test for edge case surfaced in issue
  /// [#1825](https://github.com/apollographql/apollo-ios/issues/1825)
  func test__render_nestedSelectionSets__givenDirectEntityField_withTwoObjectsNonNullFields_oneWithPluralizedNameAsObject_oneWithSingularNameAsList_rendersNestedSelectionSetsWithCorrectNames() throws {
    // given
    schemaSDL = """
    type Query {
      badge: [Badge!]!
      badges: ProductBadge!
    }

    type Badge {
      a: String
    }

    type ProductBadge {
      b: String
    }
    """

    document = """
    query TestOperation {
      badge {
        a
      }
      badges {
        b
      }
    }
    """

    let expected = """
      public var badge: [Badge] { __data["badge"] }
      public var badges: Badges { __data["badges"] }

      /// Badge
      public struct Badge: TestSchema.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ApolloAPI.ParentType { TestSchema.Objects.Badge }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("a", String?.self),
        ] }

        public var a: String? { __data["a"] }
      }

      /// Badges
      public struct Badges: TestSchema.SelectionSet {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public static var __parentType: ApolloAPI.ParentType { TestSchema.Objects.ProductBadge }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("b", String?.self),
        ] }

        public var b: String? { __data["b"] }
      }
    """

    // when
    try buildSubjectAndOperation()

    let query = try XCTUnwrap(
      operation[field: "query"] as? IR.EntityField
    )

    let actual = subject.render(field: query)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 12, ignoringExtraLines: true))
  }

  func test__render_nestedSelectionSets__givenEntityFieldMergedFromTwoSources_rendersMergedSelectionSet() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predator: Animal!
      height: Height!
    }

    interface Pet implements Animal {
      species: String!
      predator: Animal!
      height: Height!
    }

    interface WarmBlooded implements Animal {
      species: String!
      predator: Animal!
      height: Height!
    }

    type Dog implements Animal & Pet & WarmBlooded {
      name: String!
      species: String!
      predator: Animal!
      height: Height!
    }

    type Height {
      feet: Int!
      meters: Int!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        ... on Pet {
          predator {
            height {
              feet
            }
          }
        }
        ... on WarmBlooded {
          predator {
            height {
              meters
            }
          }
        }
        ... on Dog {
          predator {
            species
          }
        }
      }
    }
    """

    let expected = """
      public var species: String { __data["species"] }
      public var height: Height { __data["height"] }

      /// AllAnimal.AsDog.Predator.Height
      public struct Height: TestSchema.SelectionSet {
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals_asDog_predator = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"]?[as: "Dog"]?[field: "predator"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals_asDog_predator)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 11, ignoringExtraLines: true))
  }

  func test__render_nestedSelectionSet__givenEntityFieldMergedFromFragment_doesNotRendersSelectionSet() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predator: Animal!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        ...PredatorDetails
      }
    }

    fragment PredatorDetails on Animal {
      predator {
        species
      }
    }
    """

    let expected = """
      public var predator: PredatorDetails.Predator { __data["predator"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public var predatorDetails: PredatorDetails { _toFragment() }
      }
    }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 11, ignoringExtraLines: true))
  }

  func test__render_nestedSelectionSet__givenEntityFieldMergedFromFragmentWithLowercaseName_rendersFragmentNestedSelctionSetNameCorrectlyCased() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predator: Animal!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        ...predatorDetails
      }
    }

    fragment predatorDetails on Animal {
      predator {
        species
      }
    }
    """

    let expected = """
      public var predator: PredatorDetails.Predator { __data["predator"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public var predatorDetails: PredatorDetails { _toFragment() }
      }
    }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 11, ignoringExtraLines: true))
  }

  func test__render_nestedSelectionSet__givenEntityFieldMergedFromNestedFragmentInTypeCase_withNoOtherMergedFields_doesNotRendersSelectionSet() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predator: Animal!
      height: Height!
    }

    interface WarmBlooded implements Animal {
      species: String!
      predator: Animal!
      height: Height!
    }

    type Height {
      meters: Int!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        predator {
          ...WarmBloodedDetails
        }
      }
    }

    fragment WarmBloodedDetails on WarmBlooded {
      species
      ...HeightInMeters
    }

    fragment HeightInMeters on Animal {
      height {
        meters
      }
    }
    """

    let allAnimals_expected = """
      public var predator: Predator { __data["predator"] }

      /// AllAnimal.Predator
      public struct Predator: TestSchema.SelectionSet {
    """

    let allAnimals_predator_expected = """
      public var asWarmBlooded: AsWarmBlooded? { _asInlineFragment() }

      /// AllAnimal.Predator.AsWarmBlooded
      public struct AsWarmBlooded: TestSchema.InlineFragment {
    """

    let allAnimals_predator_asWarmBlooded_expected = """
      public var species: String { __data["species"] }
      public var height: HeightInMeters.Height { __data["height"] }

      public struct Fragments: FragmentContainer {
        public let __data: DataDict
        public init(data: DataDict) { __data = data }

        public var warmBloodedDetails: WarmBloodedDetails { _toFragment() }
        public var heightInMeters: HeightInMeters { _toFragment() }
      }
    }
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )
    let allAnimals_predator = try XCTUnwrap(
      allAnimals[field: "predator"] as? IR.EntityField
    )
    let allAnimals_predator_asWarmBlooded = try XCTUnwrap(
      allAnimals_predator[as: "WarmBlooded"]
    )

    let allAnimals_actual = subject.render(field: allAnimals)
    let allAnimals_predator_actual = subject.render(field: allAnimals_predator)
    let allAnimals_predator_asWarmBlooded_actual = subject
      .render(inlineFragment: allAnimals_predator_asWarmBlooded)

    // then
    expect(allAnimals_actual)
      .to(equalLineByLine(allAnimals_expected, atLine: 11, ignoringExtraLines: true))
    expect(allAnimals_predator_actual)
      .to(equalLineByLine(allAnimals_predator_expected, atLine: 11, ignoringExtraLines: true))
    expect(allAnimals_predator_asWarmBlooded_actual)
      .to(equalLineByLine(allAnimals_predator_asWarmBlooded_expected, atLine: 12, ignoringExtraLines: true))
  }

  func test__render_nestedSelectionSets__givenDirectSelection_typeCase_rendersNestedSelectionSet() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predator: Animal!
    }

    interface Pet implements Animal {
      species: String!
      predator: Animal!
      name: String!
    }

    type Dog implements Animal & Pet {
      species: String!
      predator: Animal!
      name: String!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        species
        ... on Pet {
          name
        }
      }
    }
    """

    let expected = """
      public var asPet: AsPet? { _asInlineFragment() }

      /// AllAnimal.AsPet
      public struct AsPet: TestSchema.InlineFragment {
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 14, ignoringExtraLines: true))
  }

  func test__render_nestedSelectionSet__givenMergedTypeCasesFromSingleMergedTypeCaseSource_rendersTypeCaseSelectionSet() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predator: Animal!
    }

    interface Pet implements Animal {
      species: String!
      predator: Animal!
      name: String!
    }

    type Dog implements Animal & Pet {
      species: String!
      predator: Animal!
      name: String!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        species
        predator {
          ... on Pet {
            name
          }
        }
        ... on Dog {
          name
          predator {
            species
          }
        }
      }
    }
    """

    let expected = """
      public var asPet: AsPet? { _asInlineFragment() }

      /// AllAnimal.AsDog.Predator.AsPet
      public struct AsPet: TestSchema.InlineFragment {
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals_asDog_predator = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"]?[as: "Dog"]?[field: "predator"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals_asDog_predator)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 13, ignoringExtraLines: true))
  }

  func test__render_nestedSelectionSet__givenInlineFragmentOnSameTypeWithMultipleConditions_rendersConditionalSelectionSet() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      fieldA: String!
    }

    interface Pet {
      fieldA: String!
    }
    """

    document = """
    query TestOperation($a: Boolean!) {
      allAnimals {
        ... @include(if: $a) @skip(if: $b) {
          fieldA
        }
      }
    }
    """

    let expected = """
      public var ifAAndNotB: IfAAndNotB? { _asInlineFragment(if: "a" && !"b") }

      /// AllAnimal.IfAAndNotB
      public struct IfAAndNotB: TestSchema.InlineFragment {
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 11, ignoringExtraLines: true))
  }

  func test__render_nestedSelectionSet__givenNamedFragmentOnSameTypeWithInclusionCondition_rendersConditionalSelectionSet() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      string: String!
      int: Int!
    }
    """

    document = """
    query TestOperation($a: Boolean!) {
      allAnimals {
        ...FragmentA @include(if: $a)
      }
    }

    fragment FragmentA on Animal {
      int
    }
    """

    let expected = """
      /// AllAnimal.IfA
      public struct IfA: TestSchema.InlineFragment {
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 20, ignoringExtraLines: true))
  }

  func test__render_nestedSelectionSet__givenTypeCaseMergedFromFragmentWithOtherMergedFields_rendersTypeCase() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predator: Animal!
    }

    interface Pet {
      favoriteToy: Item
    }

    type Item {
      name: String!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        predator {
          ...PredatorDetails
          species
        }
      }
    }

    fragment PredatorDetails on Animal {
      ... on Pet {
        favoriteToy {
          ...PetToy
        }
      }
    }

    fragment PetToy on Item {
      name
    }
    """

    let predator_expected = """
      /// AllAnimal.Predator.AsPet
      public struct AsPet: TestSchema.InlineFragment {
    """

    // when
    try buildSubjectAndOperation()
    let predator = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"]?[field: "predator"] as? IR.EntityField
    )

    let predator_actual = subject.render(field: predator)

    // then
    expect(predator_actual)
      .to(equalLineByLine(predator_expected, atLine: 23, ignoringExtraLines: true))
  }

  func test__render_nestedSelectionSet__givenTypeCaseMergedFromFragmentWithNoOtherMergedFields_rendersTypeCase() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predator: Animal!
    }

    interface Pet {
      favoriteToy: Item
    }

    type Item {
      name: String!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        predator {
          ...PredatorDetails
        }
      }
    }

    fragment PredatorDetails on Animal {
      ... on Pet {
        favoriteToy {
          ...PetToy
        }
      }
    }

    fragment PetToy on Item {
      name
    }
    """

    let predator_expected = """
      /// AllAnimal.Predator.AsPet
      public struct AsPet: TestSchema.InlineFragment {
    """

    // when
    try buildSubjectAndOperation()
    let predator = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"]?[field: "predator"] as? IR.EntityField
    )

    let predator_actual = subject.render(field: predator)

    // then
    expect(predator_actual)
      .to(equalLineByLine(predator_expected, atLine: 20, ignoringExtraLines: true))
  }

  // MARK: Nested Selection Sets - Reserved Keywords + Special Names

  func test__render_nestedSelectionSet__givenEntityFieldWithSwiftKeywordAndApolloReservedTypeNames_rendersSelectionSetWithNameSuffixed() throws {
    let fieldNames = SwiftKeywords.SelectionSetTypeNamesToSuffix
    for fieldName in fieldNames {
      // given
      schemaSDL = """
      type Query {
        allAnimals: [Animal!]
      }

      interface Animal {
        species: String!
        \(fieldName.firstLowercased): Animal!
      }
      """

      document = """
      query TestOperation {
        allAnimals {
          \(fieldName.firstLowercased) {
            species
          }
        }
      }
      """

      let expected = """
        /// AllAnimal.\(fieldName.firstUppercased)_SelectionSet
        public struct \(fieldName.firstUppercased)_SelectionSet: TestSchema.SelectionSet {
      """

      // when
      try buildSubjectAndOperation()
      let allAnimals = try XCTUnwrap(
        operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
      )

      let predator_actual = subject.render(field: allAnimals)

      // then
      expect(predator_actual)
        .to(equalLineByLine(expected, atLine: 13, ignoringExtraLines: true))
    }
  }

  // MARK: - InlineFragment RootEntityType Tests

  func test__render_nestedTypeCase__rendersRootEntityType() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predators: [Animal!]
    }

    interface Pet {
      name: String!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        ... on Pet {
          name
        }
      }
    }
    """

    let expected = """
    /// AllAnimal.AsPet
    public struct AsPet: TestSchema.InlineFragment {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public typealias RootEntityType = AllAnimal
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals_AsPet = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"]?[as: "Pet"]
    )

    let actual = subject.render(inlineFragment: allAnimals_AsPet)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 1, ignoringExtraLines: true))
  }

  func test__render_doublyNestedTypeCase__rendersRootEntityType() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predators: [Animal!]
    }

    interface Pet {
      name: String!
    }

    interface WarmBlooded {
      name: String!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        ... on WarmBlooded {
          ... on Pet {
            name
          }
        }
      }
    }
    """

    let expected = """
    /// AllAnimal.AsWarmBlooded.AsPet
    public struct AsPet: TestSchema.InlineFragment {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public typealias RootEntityType = AllAnimal
    """

    // when
    try buildSubjectAndOperation()
    let allAnimals_AsPet = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"]?[as: "WarmBlooded"]?[as: "Pet"]
    )

    let actual = subject.render(inlineFragment: allAnimals_AsPet)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 1, ignoringExtraLines: true))
  }

  func test__render_nestedTypeCaseWithNameConflictingWithChild__rendersRootEntityType() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predators: [Animal!]
    }

    interface Pet {
      name: String!
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        predators {
           ... on Pet {
            name
          }
          predators {
            species
          }
        }
      }
    }
    """

    let expected = """
    /// AllAnimal.Predator.AsPet
    public struct AsPet: TestSchema.InlineFragment {
      public let __data: DataDict
      public init(data: DataDict) { __data = data }

      public typealias RootEntityType = AllAnimal.Predator
    """

    // when
    try buildSubjectAndOperation()
    let predators_asPet = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"]?[field: "predators"]?[as: "Pet"]
    )

    let actual = subject.render(inlineFragment: predators_asPet)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 1, ignoringExtraLines: true))
  }

  // MARK: - Documentation Tests

  func test__render_nestedSelectionSet__givenSchemaDocumentation_include_hasDocumentation_shouldGenerateDocumentationComment() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predators: [Animal!]
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        predators {
          species
        }
      }
    }
    """

    let expected = """
      public var predators: [Predator]? { __data["predators"] }

      /// AllAnimal.Predator
      ///
      /// Parent Type: `Animal`
      public struct Predator: TestSchema.SelectionSet {
    """

    // when
    try buildSubjectAndOperation(schemaDocumentation: .include)
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 13, ignoringExtraLines: true))
  }

  func test__render_nestedSelectionSet_givenSchemaDocumentation_exclude_hasDocumentation_shouldNotGenerateDocumentationComment() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      predators: [Animal!]
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        predators {
          species
        }
      }
    }
    """

    let expected = """
      public var predators: [Predator]? { __data["predators"] }

      /// AllAnimal.Predator
      public struct Predator: TestSchema.SelectionSet {
    """

    // when
    try buildSubjectAndOperation(schemaDocumentation: .exclude)
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 11, ignoringExtraLines: true))
  }

  func test__render_fieldAccessors__givenSchemaDocumentation_include_hasDocumentation_shouldGenerateDocumentationComment() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      "This field is a string."
      string: String!
    }

    scalar Custom
    """

    document = """
    query TestOperation {
      allAnimals {
        string
      }
    }
    """

    let expected = """
      /// This field is a string.
      public var string: String { __data["string"] }
    """

    // when
    try buildSubjectAndOperation(schemaDocumentation: .include)
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 13, ignoringExtraLines: true))
  }

  func test__render_fieldAccessors__givenSchemaDocumentation_exclude_hasDocumentation_shouldNotGenerateDocumentationComment() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      "This field is a string."
      string: String!
    }

    scalar Custom
    """

    document = """
    query TestOperation {
      allAnimals {
        string
      }
    }
    """

    let expected = """
      public var string: String { __data["string"] }
    """

    // when
    try buildSubjectAndOperation(schemaDocumentation: .exclude)
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 11, ignoringExtraLines: true))
  }

  // MARK: - Deprecation Warnings

  func test__render_fieldAccessors__givenWarningsOnDeprecatedUsage_include_hasDeprecatedField_withDocumentation_shouldGenerateWarningBelowDocumentation() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      "This field is a string."
      string: String! @deprecated(reason: "Cause I said so!")
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        string
      }
    }
    """

    let expected = """
      /// This field is a string.
      @available(*, deprecated, message: "Cause I said so!")
      public var string: String { __data["string"] }
    """

    // when
    try buildSubjectAndOperation(
      schemaDocumentation: .include,
      warningsOnDeprecatedUsage: .include
    )
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 13, ignoringExtraLines: true))
  }


  func test__render_fieldAccessors__givenWarningsOnDeprecatedUsage_include_hasDeprecatedField_withMultilineDocumentation_shouldGenerateWarningBelowDocumentationWithMultilineLiteral() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      "This field is a string."
      string: String! @deprecated(reason: "Cause I\\nsaid so!")
    }
    """ // Escaping the backslash is required to allow the frontend to parse correctly this string.
    // Removing the escape leads to a "unterminated string literal" error when parsing the schema.

    document = """
    query TestOperation {
      allAnimals {
        string
      }
    }
    """

    let expected = #"""
      /// This field is a string.
      @available(*, deprecated, message: """
        Cause I
        said so!
        """)
      public var string: String { __data["string"] }
    """#

    // when
    try buildSubjectAndOperation(
      schemaDocumentation: .include,
      warningsOnDeprecatedUsage: .include
    )
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 13, ignoringExtraLines: true))
  }

  func test__render_fieldAccessors__givenWarningsOnDeprecatedUsage_include_hasDeprecatedField_withMultilineDocumentation_includingEmptyLine_shouldGenerateWarningBelowDocumentationWithMultilineLiteral() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      "This field is a string."
      string: String! @deprecated(reason: "Cause I\\n\\nsaid so!")
    }
    """ // Escaping the backslash is required to allow the frontend to parse correctly this string.
    // Removing the escape leads to a "unterminated string literal" error when parsing the schema.

    document = """
    query TestOperation {
      allAnimals {
        string
      }
    }
    """

    let expected = #"""
      /// This field is a string.
      @available(*, deprecated, message: """
        Cause I

        said so!
        """)
      public var string: String { __data["string"] }
    """#

    // when
    try buildSubjectAndOperation(
      schemaDocumentation: .include,
      warningsOnDeprecatedUsage: .include
    )
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 13, ignoringExtraLines: true))
  }

  func test__render_fieldAccessors__givenWarningsOnDeprecatedUsage_exclude_hasDeprecatedField_shouldNotGenerateWarning() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      string: String! @deprecated
    }
    """

    document = """
    query TestOperation {
      allAnimals {
        string
      }
    }
    """

    let expected = """
      public var string: String { __data["string"] }
    """

    // when
    try buildSubjectAndOperation(warningsOnDeprecatedUsage: .exclude)
    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 11, ignoringExtraLines: true))
  }

  func test__render_selections__givenWarningsOnDeprecatedUsage_include_usesDeprecatedArgument__shouldGenerateWarning() throws {
    // given
    schemaSDL = """
    type Query {
      animal: Animal
    }

    type Animal {
      friend(name: String, species: String @deprecated(reason: "Who cares?")): Animal
      species: String
    }
    """

    document = """
    query TestOperation($name: String, $species: String) {
      animal {
        friend(name: $name, species: $species) {
          species
        }
      }
    }
    """

    let expected = """
      #warning("Argument 'species' of field 'friend' is deprecated. Reason: 'Who cares?'")
      public static var __selections: [ApolloAPI.Selection] { [
        .field("friend", Friend?.self, arguments: [
          "name": .variable("name"),
          "species": .variable("species")
        ]),
      ] }
    """

    // when
    try buildSubjectAndOperation(
      warningsOnDeprecatedUsage: .include
    )
    let animal = try XCTUnwrap(
      operation[field: "query"]?[field: "animal"] as? IR.EntityField
    )

    let actual = subject.render(field: animal)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 7, ignoringExtraLines: true))
  }

  func test__render_selections__givenWarningsOnDeprecatedUsage_exclude_usesDeprecatedArgument__shouldNotGenerateWarning() throws {
    // given
    schemaSDL = """
    type Query {
      animal: Animal
    }

    type Animal {
      friend(name: String, species: String @deprecated(reason: "Who cares?")): Animal
      species: String
    }
    """

    document = """
    query TestOperation($name: String, $species: String) {
      animal {
        friend(name: $name, species: $species) {
          species
        }
      }
    }
    """

    let expected = """
      public static var __selections: [ApolloAPI.Selection] { [
        .field("friend", Friend?.self, arguments: [
          "name": .variable("name"),
          "species": .variable("species")
        ]),
      ] }
    """

    // when
    try buildSubjectAndOperation(
      warningsOnDeprecatedUsage: .exclude
    )
    let animal = try XCTUnwrap(
      operation[field: "query"]?[field: "animal"] as? IR.EntityField
    )

    let actual = subject.render(field: animal)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 7, ignoringExtraLines: true))
  }

  func test__render_selections__givenWarningsOnDeprecatedUsage_include_usesMultipleDeprecatedArgumentsSameField__shouldGenerateWarningAllWarnings() throws {
    // given
    schemaSDL = """
    type Query {
      animal: Animal
    }

    type Animal {
      friend(
        name: String @deprecated(reason: "Someone broke it."),
        species: String @deprecated(reason: "Who cares?")
      ): Animal
      species: String
    }
    """

    document = """
    query TestOperation($name: String, $species: String) {
      animal {
        friend(name: $name, species: $species) {
          species
        }
      }
    }
    """

    let expected = """
      #warning("Argument 'name' of field 'friend' is deprecated. Reason: 'Someone broke it.'"),
      #warning("Argument 'species' of field 'friend' is deprecated. Reason: 'Who cares?'")
      public static var __selections: [ApolloAPI.Selection] { [
        .field("friend", Friend?.self, arguments: [
          "name": .variable("name"),
          "species": .variable("species")
        ]),
      ] }
    """

    // when
    try buildSubjectAndOperation(
      warningsOnDeprecatedUsage: .include
    )
    let animal = try XCTUnwrap(
      operation[field: "query"]?[field: "animal"] as? IR.EntityField
    )

    let actual = subject.render(field: animal)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 7, ignoringExtraLines: true))
  }

  func test__render_selections__givenWarningsOnDeprecatedUsage_include_usesMultipleDeprecatedArgumentsDifferentFields__shouldGenerateWarningAllWarnings() throws {
    // given
    schemaSDL = """
    type Query {
      animal: Animal
    }

    type Animal {
      friend(name: String @deprecated(reason: "Someone broke it.")): Animal
      species(species: String @deprecated(reason: "Redundant")): String
    }
    """

    document = """
    query TestOperation($name: String, $species: String) {
      animal {
        friend(name: $name) {
          species
        }
        species(species: $species)
      }
    }
    """

    let expected = """
      #warning("Argument 'name' of field 'friend' is deprecated. Reason: 'Someone broke it.'"),
      #warning("Argument 'species' of field 'species' is deprecated. Reason: 'Redundant'")
      public static var __selections: [ApolloAPI.Selection] { [
        .field("friend", Friend?.self, arguments: ["name": .variable("name")]),
        .field("species", String?.self, arguments: ["species": .variable("species")]),
      ] }
    """

    // when
    try buildSubjectAndOperation(
      warningsOnDeprecatedUsage: .include
    )
    let animal = try XCTUnwrap(
      operation[field: "query"]?[field: "animal"] as? IR.EntityField
    )

    let actual = subject.render(field: animal)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 7, ignoringExtraLines: true))
  }
}
