import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenInternalTestHelpers

class MockObjectTemplateTests: XCTestCase {

  var ir: IR!
  var subject: MockObjectTemplate!

  override func tearDown() {
    subject = nil
    ir = nil

    super.tearDown()
  }

  // MARK: - Helpers

  private func buildSubject(
    name: String = "Dog",
    interfaces: [GraphQLInterfaceType] = [],
    schemaNamespace: String = "TestSchema",
    moduleType: ApolloCodegenConfiguration.SchemaTypesFileOutput.ModuleType = .swiftPackageManager,
    testMocks: ApolloCodegenConfiguration.TestMockFileOutput = .swiftPackage(),
    warningsOnDeprecatedUsage: ApolloCodegenConfiguration.Composition = .exclude
  ) {
    let config = ApolloCodegenConfiguration.mock(
      schemaNamespace: schemaNamespace,
      output: .mock(moduleType: moduleType, testMocks: testMocks),
      options: .init(warningsOnDeprecatedUsage: warningsOnDeprecatedUsage)
    )
    ir = IR.mock(compilationResult: .mock())

    subject = MockObjectTemplate(
      graphqlObject: GraphQLObjectType.mock(name, interfaces: interfaces),
      config: ApolloCodegen.ConfigurationContext(config: config),
      ir: ir
    )
  }

  private func renderSubject() -> String {
    subject.template.description
  }

  // MARK: Boilerplate tests

  func test__target__isTestMockFile() {
    buildSubject()

    expect(self.subject.target).to(equal(.testMockFile))
  }

  func test__render__givenSchemaType_generatesExtension() {
    // given
    buildSubject(name: "Dog", moduleType: .swiftPackageManager)

    let expected = """
    public class Dog: MockObject {
      public static let objectType: Object = TestSchema.Objects.Dog
      public static let _mockFields = MockFields()
      public typealias MockValueCollectionType = Array<Mock<Dog>>

      public struct MockFields {
      }
    }

    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  // MARK: Casing Tests

  func test__render__givenSchemaTypeWithLowercaseName_generatesCapitalizedClassName() {
    // given
    buildSubject(name: "dog")

    let expected = """
    public class Dog: MockObject {
      public static let objectType: Object = TestSchema.Objects.Dog
      public static let _mockFields = MockFields()
      public typealias MockValueCollectionType = Array<Mock<Dog>>

      public struct MockFields {
      }
    }

    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__render__givenLowercasedSchemaName_generatesFirstUppercasedSchemaNameReferences() {
    // given
    buildSubject(schemaNamespace: "lowercased")

    let expected = """
      public static let objectType: Object = Lowercased.Objects.Dog
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 2, ignoringExtraLines: true))
  }

  func test__render__givenUppercasedSchemaName_generatesCapitalizedSchemaNameReferences() {
    // given
    buildSubject(schemaNamespace: "UPPER")

    let expected = """
      public static let objectType: Object = UPPER.Objects.Dog
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 2, ignoringExtraLines: true))
  }

  func test__render__givenCapitalizedSchemaName_generatesCapitalizedSchemaNameReferences() {
    // given
    buildSubject(schemaNamespace: "MySchema")

    let expected = """
      public static let objectType: Object = MySchema.Objects.Dog
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 2, ignoringExtraLines: true))
  }

  // MARK: Mock Field Tests

  func test__render__givenSchemaType_generatesFieldAccessors() {
    // given
    buildSubject(moduleType: .swiftPackageManager)

    let Cat: GraphQLType = .entity(.mock("Cat"))

    subject.graphqlObject.fields = [
      "string": .mock("string", type: .nonNull(.string())),
      "customScalar": .mock("customScalar", type: .nonNull(.scalar(.mock(name: "CustomScalar")))),
      "optionalString": .mock("optionalString", type: .string()),
      "object": .mock("object", type: Cat),
      "objectList": .mock("objectList", type: .list(.nonNull(Cat))),
      "objectNestedList": .mock("objectNestedList", type: .list(.nonNull(.list(.nonNull(Cat))))),
      "objectOptionalList": .mock("objectOptionalList", type: .list(Cat)),
    ]

    ir.fieldCollector.add(
      fields: subject.graphqlObject.fields.values.map {
        .mock($0.name, type: $0.type)
      },
      to: subject.graphqlObject
    )

    let expected = """
      public struct MockFields {
        @Field<TestSchema.CustomScalar>("customScalar") public var customScalar
        @Field<Cat>("object") public var object
        @Field<[Cat]>("objectList") public var objectList
        @Field<[[Cat]]>("objectNestedList") public var objectNestedList
        @Field<[Cat?]>("objectOptionalList") public var objectOptionalList
        @Field<String>("optionalString") public var optionalString
        @Field<String>("string") public var string
      }
    """
    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 6, ignoringExtraLines: true))
  }

  func test__render__givenFieldsWithLowercaseTypeNames_generatesFieldAccessors() {
    // given
    buildSubject(moduleType: .swiftPackageManager)

    let Cat: GraphQLType = .entity(.mock("cat"))

    subject.graphqlObject.fields = [
      "customScalar": .mock("customScalar", type: .nonNull(.scalar(.mock(name: "customScalar")))),
      "enumType": .mock("enumType", type: .enum(.mock(name: "enumType"))),
      "object": .mock("object", type: Cat),
    ]

    ir.fieldCollector.add(
      fields: subject.graphqlObject.fields.values.map {
        .mock($0.name, type: $0.type)
      },
      to: subject.graphqlObject
    )

    let expected = """
      public struct MockFields {
        @Field<TestSchema.CustomScalar>("customScalar") public var customScalar
        @Field<GraphQLEnum<TestSchema.EnumType>>("enumType") public var enumType
        @Field<Cat>("object") public var object
      }
    """
    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 6, ignoringExtraLines: true))
  }

  func test__render__givenFieldsWithSwiftReservedKeyworkNames_generatesFieldsEscapedWithBackticks() {
    // given
    buildSubject(moduleType: .swiftPackageManager)

    subject.graphqlObject.fields = [
      "associatedtype": .mock("associatedtype", type: .nonNull(.string())),
      "class": .mock("class", type: .nonNull(.string())),
      "deinit": .mock("deinit", type: .nonNull(.string())),
      "enum": .mock("enum", type: .nonNull(.string())),
      "extension": .mock("extension", type: .nonNull(.string())),
      "fileprivate": .mock("fileprivate", type: .nonNull(.string())),
      "func": .mock("func", type: .nonNull(.string())),
      "import": .mock("import", type: .nonNull(.string())),
      "init": .mock("init", type: .nonNull(.string())),
      "inout": .mock("inout", type: .nonNull(.string())),
      "internal": .mock("internal", type: .nonNull(.string())),
      "let": .mock("let", type: .nonNull(.string())),
      "operator": .mock("operator", type: .nonNull(.string())),
      "private": .mock("private", type: .nonNull(.string())),
      "precedencegroup": .mock("precedencegroup", type: .nonNull(.string())),
      "protocol": .mock("protocol", type: .nonNull(.string())),
      "Protocol": .mock("Protocol", type: .nonNull(.string())),
      "public": .mock("public", type: .nonNull(.string())),
      "rethrows": .mock("rethrows", type: .nonNull(.string())),
      "static": .mock("static", type: .nonNull(.string())),
      "struct": .mock("struct", type: .nonNull(.string())),
      "subscript": .mock("subscript", type: .nonNull(.string())),
      "typealias": .mock("typealias", type: .nonNull(.string())),
      "var": .mock("var", type: .nonNull(.string())),
      "break": .mock("break", type: .nonNull(.string())),
      "case": .mock("case", type: .nonNull(.string())),
      "catch": .mock("catch", type: .nonNull(.string())),
      "continue": .mock("continue", type: .nonNull(.string())),
      "default": .mock("default", type: .nonNull(.string())),
      "defer": .mock("defer", type: .nonNull(.string())),
      "do": .mock("do", type: .nonNull(.string())),
      "else": .mock("else", type: .nonNull(.string())),
      "fallthrough": .mock("fallthrough", type: .nonNull(.string())),
      "for": .mock("for", type: .nonNull(.string())),
      "guard": .mock("guard", type: .nonNull(.string())),
      "if": .mock("if", type: .nonNull(.string())),
      "in": .mock("in", type: .nonNull(.string())),
      "repeat": .mock("repeat", type: .nonNull(.string())),
      "return": .mock("return", type: .nonNull(.string())),
      "throw": .mock("throw", type: .nonNull(.string())),
      "switch": .mock("switch", type: .nonNull(.string())),
      "where": .mock("where", type: .nonNull(.string())),
      "while": .mock("while", type: .nonNull(.string())),
      "as": .mock("as", type: .nonNull(.string())),
      "false": .mock("false", type: .nonNull(.string())),
      "is": .mock("is", type: .nonNull(.string())),
      "nil": .mock("nil", type: .nonNull(.string())),
      "self": .mock("self", type: .nonNull(.string())),
      "Self": .mock("Self", type: .nonNull(.string())),
      "super": .mock("super", type: .nonNull(.string())),
      "throws": .mock("throws", type: .nonNull(.string())),
      "true": .mock("true", type: .nonNull(.string())),
      "try": .mock("try", type: .nonNull(.string())),      
      "Type": .mock("Type", type: .nonNull(.string())),
      "Any": .mock("Any", type: .nonNull(.string())),
    ]

    ir.fieldCollector.add(
      fields: subject.graphqlObject.fields.values.map {
        .mock($0.name, type: $0.type)
      },
      to: subject.graphqlObject
    )

    let expected = """
      public struct MockFields {
        @Field<String>("Any") public var `Any`
        @Field<String>("Protocol") public var `Protocol`
        @Field<String>("Self") public var `Self`
        @Field<String>("Type") public var `Type`
        @Field<String>("as") public var `as`
        @Field<String>("associatedtype") public var `associatedtype`
        @Field<String>("break") public var `break`
        @Field<String>("case") public var `case`
        @Field<String>("catch") public var `catch`
        @Field<String>("class") public var `class`
        @Field<String>("continue") public var `continue`
        @Field<String>("default") public var `default`
        @Field<String>("defer") public var `defer`
        @Field<String>("deinit") public var `deinit`
        @Field<String>("do") public var `do`
        @Field<String>("else") public var `else`
        @Field<String>("enum") public var `enum`
        @Field<String>("extension") public var `extension`
        @Field<String>("fallthrough") public var `fallthrough`
        @Field<String>("false") public var `false`
        @Field<String>("fileprivate") public var `fileprivate`
        @Field<String>("for") public var `for`
        @Field<String>("func") public var `func`
        @Field<String>("guard") public var `guard`
        @Field<String>("if") public var `if`
        @Field<String>("import") public var `import`
        @Field<String>("in") public var `in`
        @Field<String>("init") public var `init`
        @Field<String>("inout") public var `inout`
        @Field<String>("internal") public var `internal`
        @Field<String>("is") public var `is`
        @Field<String>("let") public var `let`
        @Field<String>("nil") public var `nil`
        @Field<String>("operator") public var `operator`
        @Field<String>("precedencegroup") public var `precedencegroup`
        @Field<String>("private") public var `private`
        @Field<String>("protocol") public var `protocol`
        @Field<String>("public") public var `public`
        @Field<String>("repeat") public var `repeat`
        @Field<String>("rethrows") public var `rethrows`
        @Field<String>("return") public var `return`
        @Field<String>("self") public var `self`
        @Field<String>("static") public var `static`
        @Field<String>("struct") public var `struct`
        @Field<String>("subscript") public var `subscript`
        @Field<String>("super") public var `super`
        @Field<String>("switch") public var `switch`
        @Field<String>("throw") public var `throw`
        @Field<String>("throws") public var `throws`
        @Field<String>("true") public var `true`
        @Field<String>("try") public var `try`
        @Field<String>("typealias") public var `typealias`
        @Field<String>("var") public var `var`
        @Field<String>("where") public var `where`
        @Field<String>("while") public var `while`
      }
    """
    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 6, ignoringExtraLines: true))
  }

  func test__render__givenFieldType_Interface_named_Actor_generatesFieldsWithNamespace() {
    // given
    buildSubject(moduleType: .swiftPackageManager)

    let Actor_Interface = GraphQLInterfaceType.mock("Actor")

    subject.graphqlObject.fields = [
      "actor": .mock("actor", type: .entity(Actor_Interface)),
    ]

    ir.fieldCollector.add(
      fields: subject.graphqlObject.fields.values.map {
        .mock($0.name, type: $0.type)
      },
      to: subject.graphqlObject
    )

    let expected = """
      public struct MockFields {
        @Field<MockObject.Actor>("actor") public var actor
      }
    """
    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 6, ignoringExtraLines: true))
  }

  func test__render__givenFieldType_Union_named_Actor_generatesFieldsWithNamespace() {
    // given
    buildSubject(moduleType: .swiftPackageManager)

    let Actor_Union = GraphQLUnionType.mock("Actor")

    subject.graphqlObject.fields = [
      "actor": .mock("actor", type: .entity(Actor_Union)),
    ]

    ir.fieldCollector.add(
      fields: subject.graphqlObject.fields.values.map {
        .mock($0.name, type: $0.type)
      },
      to: subject.graphqlObject
    )

    let expected = """
      public struct MockFields {
        @Field<MockObject.Actor>("actor") public var actor
      }
    """
    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 6, ignoringExtraLines: true))
  }

  func test__render__givenFieldType_Object_named_Actor_generatesFieldsWithoutNamespace() {
    // given
    buildSubject(moduleType: .swiftPackageManager)

    let Actor_Object = GraphQLObjectType.mock("Actor")

    subject.graphqlObject.fields = [
      "actor": .mock("actor", type: .entity(Actor_Object)),
    ]

    ir.fieldCollector.add(
      fields: subject.graphqlObject.fields.values.map {
        .mock($0.name, type: $0.type)
      },
      to: subject.graphqlObject
    )

    let expected = """
      public struct MockFields {
        @Field<Actor>("actor") public var actor
      }
    """
    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 6, ignoringExtraLines: true))
  }



  // MARK: Convenience Initializer Tests

  func test__render__givenSchemaType_generatesConvenienceInitializer() {
    // given
    buildSubject(moduleType: .swiftPackageManager)

    let Cat: GraphQLType = .entity(GraphQLObjectType.mock("Cat"))
    let Animal: GraphQLType = .entity(GraphQLInterfaceType.mock("Animal"))
    let Pet: GraphQLType = .entity(GraphQLUnionType.mock("Pet"))

    subject.graphqlObject.fields = [
      "string": .mock("string", type: .nonNull(.string())),
      "customScalar": .mock("customScalar", type: .nonNull(.scalar(.mock(name: "CustomScalar")))),
      "optionalString": .mock("optionalString", type: .string()),
      "object": .mock("object", type: Cat),
      "objectList": .mock("objectList", type: .list(.nonNull(Cat))),
      "objectNestedList": .mock("objectNestedList", type: .list(.nonNull(.list(.nonNull(Cat))))),
      "objectOptionalList": .mock("objectOptionalList", type: .list(Cat)),
      "interface": .mock("interface", type: Animal),
      "interfaceList": .mock("interfaceList", type: .list(.nonNull(Animal))),
      "interfaceNestedList": .mock("interfaceNestedList", type: .list(.nonNull(.list(.nonNull(Animal))))),
      "interfaceOptionalList": .mock("interfaceOptionalList", type: .list(Animal)),
      "union": .mock("union", type: Pet),
      "unionList": .mock("unionList", type: .list(.nonNull(Pet))),
      "unionNestedList": .mock("unionNestedList", type: .list(.nonNull(.list(.nonNull(Pet))))),
      "unionOptionalList": .mock("unionOptionalList", type: .list(Pet)),
      "enumType": .mock("enumType", type: .enum(.mock(name: "enumType"))),
    ]

    ir.fieldCollector.add(
      fields: subject.graphqlObject.fields.values.map {
        .mock($0.name, type: $0.type)
      },
      to: subject.graphqlObject
    )

    let expected = """
    }

    public extension Mock where O == Dog {
      convenience init(
        customScalar: TestSchema.CustomScalar? = nil,
        enumType: GraphQLEnum<TestSchema.EnumType>? = nil,
        interface: AnyMock? = nil,
        interfaceList: [AnyMock]? = nil,
        interfaceNestedList: [[AnyMock]]? = nil,
        interfaceOptionalList: [AnyMock?]? = nil,
        object: Mock<Cat>? = nil,
        objectList: [Mock<Cat>]? = nil,
        objectNestedList: [[Mock<Cat>]]? = nil,
        objectOptionalList: [Mock<Cat>?]? = nil,
        optionalString: String? = nil,
        string: String? = nil,
        union: AnyMock? = nil,
        unionList: [AnyMock]? = nil,
        unionNestedList: [[AnyMock]]? = nil,
        unionOptionalList: [AnyMock?]? = nil
      ) {
        self.init()
        self.customScalar = customScalar
        self.enumType = enumType
        self.interface = interface
        self.interfaceList = interfaceList
        self.interfaceNestedList = interfaceNestedList
        self.interfaceOptionalList = interfaceOptionalList
        self.object = object
        self.objectList = objectList
        self.objectNestedList = objectNestedList
        self.objectOptionalList = objectOptionalList
        self.optionalString = optionalString
        self.string = string
        self.union = union
        self.unionList = unionList
        self.unionNestedList = unionNestedList
        self.unionOptionalList = unionOptionalList
      }
    }

    """
    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(
      expected,
      atLine: 8 + self.subject.graphqlObject.fields.count,
      ignoringExtraLines: false)
    )
  }
  
  func test__render__givenSchemaTypeWithoutFields_doesNotgenerateConvenienceInitializer() {
    // given
    buildSubject(moduleType: .swiftPackageManager)

    let expected = """
    }
    
    """
    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(
      expected,
      atLine: 8 + self.subject.graphqlObject.fields.count,
      ignoringExtraLines: false)
    )
  }

  func test__render__givenFieldsWithSwiftReservedKeyworkNames_generatesConvenienceInitializerParamatersEscapedWithBackticksAndInternalNames() {
    // given
    buildSubject(moduleType: .swiftPackageManager)

    subject.graphqlObject.fields = [
      "associatedtype": .mock("associatedtype", type: .nonNull(.string())),
      "class": .mock("class", type: .nonNull(.string())),
      "deinit": .mock("deinit", type: .nonNull(.string())),
      "enum": .mock("enum", type: .nonNull(.string())),
      "extension": .mock("extension", type: .nonNull(.string())),
      "fileprivate": .mock("fileprivate", type: .nonNull(.string())),
      "func": .mock("func", type: .nonNull(.string())),
      "import": .mock("import", type: .nonNull(.string())),
      "init": .mock("init", type: .nonNull(.string())),
      "inout": .mock("inout", type: .nonNull(.string())),
      "internal": .mock("internal", type: .nonNull(.string())),
      "let": .mock("let", type: .nonNull(.string())),
      "operator": .mock("operator", type: .nonNull(.string())),
      "private": .mock("private", type: .nonNull(.string())),
      "precedencegroup": .mock("precedencegroup", type: .nonNull(.string())),
      "protocol": .mock("protocol", type: .nonNull(.string())),
      "Protocol": .mock("Protocol", type: .nonNull(.string())),
      "public": .mock("public", type: .nonNull(.string())),
      "rethrows": .mock("rethrows", type: .nonNull(.string())),
      "static": .mock("static", type: .nonNull(.string())),
      "struct": .mock("struct", type: .nonNull(.string())),
      "subscript": .mock("subscript", type: .nonNull(.string())),
      "typealias": .mock("typealias", type: .nonNull(.string())),
      "var": .mock("var", type: .nonNull(.string())),
      "break": .mock("break", type: .nonNull(.string())),
      "case": .mock("case", type: .nonNull(.string())),
      "catch": .mock("catch", type: .nonNull(.string())),
      "continue": .mock("continue", type: .nonNull(.string())),
      "default": .mock("default", type: .nonNull(.string())),
      "defer": .mock("defer", type: .nonNull(.string())),
      "do": .mock("do", type: .nonNull(.string())),
      "else": .mock("else", type: .nonNull(.string())),
      "fallthrough": .mock("fallthrough", type: .nonNull(.string())),
      "for": .mock("for", type: .nonNull(.string())),
      "guard": .mock("guard", type: .nonNull(.string())),
      "if": .mock("if", type: .nonNull(.string())),
      "in": .mock("in", type: .nonNull(.string())),
      "repeat": .mock("repeat", type: .nonNull(.string())),
      "return": .mock("return", type: .nonNull(.string())),
      "throw": .mock("throw", type: .nonNull(.string())),
      "switch": .mock("switch", type: .nonNull(.string())),
      "where": .mock("where", type: .nonNull(.string())),
      "while": .mock("while", type: .nonNull(.string())),
      "as": .mock("as", type: .nonNull(.string())),
      "false": .mock("false", type: .nonNull(.string())),
      "is": .mock("is", type: .nonNull(.string())),
      "nil": .mock("nil", type: .nonNull(.string())),
      "self": .mock("self", type: .nonNull(.string())),
      "Self": .mock("Self", type: .nonNull(.string())),
      "super": .mock("super", type: .nonNull(.string())),
      "throws": .mock("throws", type: .nonNull(.string())),
      "true": .mock("true", type: .nonNull(.string())),
      "try": .mock("try", type: .nonNull(.string())),
      "Type": .mock("Type", type: .nonNull(.string())),
      "Any": .mock("Any", type: .nonNull(.string())),
    ]

    ir.fieldCollector.add(
      fields: subject.graphqlObject.fields.values.map {
        .mock($0.name, type: $0.type)
      },
      to: subject.graphqlObject
    )

    let expected = """
    }

    public extension Mock where O == Dog {
      convenience init(
        `Any`: String? = nil,
        `Protocol`: String? = nil,
        `Self`: String? = nil,
        `Type`: String? = nil,
        `as`: String? = nil,
        `associatedtype`: String? = nil,
        `break`: String? = nil,
        `case`: String? = nil,
        `catch`: String? = nil,
        `class`: String? = nil,
        `continue`: String? = nil,
        `default`: String? = nil,
        `defer`: String? = nil,
        `deinit`: String? = nil,
        `do`: String? = nil,
        `else`: String? = nil,
        `enum`: String? = nil,
        `extension`: String? = nil,
        `fallthrough`: String? = nil,
        `false`: String? = nil,
        `fileprivate`: String? = nil,
        `for`: String? = nil,
        `func`: String? = nil,
        `guard`: String? = nil,
        `if`: String? = nil,
        `import`: String? = nil,
        `in`: String? = nil,
        `init`: String? = nil,
        `inout`: String? = nil,
        `internal`: String? = nil,
        `is`: String? = nil,
        `let`: String? = nil,
        `nil`: String? = nil,
        `operator`: String? = nil,
        `precedencegroup`: String? = nil,
        `private`: String? = nil,
        `protocol`: String? = nil,
        `public`: String? = nil,
        `repeat`: String? = nil,
        `rethrows`: String? = nil,
        `return`: String? = nil,
        `self` self_value: String? = nil,
        `static`: String? = nil,
        `struct`: String? = nil,
        `subscript`: String? = nil,
        `super`: String? = nil,
        `switch`: String? = nil,
        `throw`: String? = nil,
        `throws`: String? = nil,
        `true`: String? = nil,
        `try`: String? = nil,
        `typealias`: String? = nil,
        `var`: String? = nil,
        `where`: String? = nil,
        `while`: String? = nil
      ) {
        self.init()
        self.`Any` = `Any`
        self.`Protocol` = `Protocol`
        self.`Self` = `Self`
        self.`Type` = `Type`
        self.`as` = `as`
        self.`associatedtype` = `associatedtype`
        self.`break` = `break`
        self.`case` = `case`
        self.`catch` = `catch`
        self.`class` = `class`
        self.`continue` = `continue`
        self.`default` = `default`
        self.`defer` = `defer`
        self.`deinit` = `deinit`
        self.`do` = `do`
        self.`else` = `else`
        self.`enum` = `enum`
        self.`extension` = `extension`
        self.`fallthrough` = `fallthrough`
        self.`false` = `false`
        self.`fileprivate` = `fileprivate`
        self.`for` = `for`
        self.`func` = `func`
        self.`guard` = `guard`
        self.`if` = `if`
        self.`import` = `import`
        self.`in` = `in`
        self.`init` = `init`
        self.`inout` = `inout`
        self.`internal` = `internal`
        self.`is` = `is`
        self.`let` = `let`
        self.`nil` = `nil`
        self.`operator` = `operator`
        self.`precedencegroup` = `precedencegroup`
        self.`private` = `private`
        self.`protocol` = `protocol`
        self.`public` = `public`
        self.`repeat` = `repeat`
        self.`rethrows` = `rethrows`
        self.`return` = `return`
        self.`self` = self_value
        self.`static` = `static`
        self.`struct` = `struct`
        self.`subscript` = `subscript`
        self.`super` = `super`
        self.`switch` = `switch`
        self.`throw` = `throw`
        self.`throws` = `throws`
        self.`true` = `true`
        self.`try` = `try`
        self.`typealias` = `typealias`
        self.`var` = `var`
        self.`where` = `where`
        self.`while` = `while`
      }
    }

    """
    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(
      expected,
      atLine: 8 + self.subject.graphqlObject.fields.count,
      ignoringExtraLines: false)
    )
  }

  // MARK: Access Level Tests

  func test__render__givenSchemaTypeAndFields_whenTestMocksIsSwiftPackage_shouldRenderWithPublicAccess() {
    // given
    buildSubject(name: "Dog", testMocks: .swiftPackage())

    subject.graphqlObject.fields = [
      "string": .mock("string", type: .nonNull(.string()))
    ]

    ir.fieldCollector.add(
      fields: subject.graphqlObject.fields.values.map {
        .mock($0.name, type: $0.type)
      },
      to: subject.graphqlObject
    )

    let expectedClassDefinition = """
    public class Dog: MockObject {
    """

    let expectedExtensionDefinition = """
    public extension Mock where O == Dog {
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expectedClassDefinition, ignoringExtraLines: true))
    expect(actual).to(equalLineByLine(expectedExtensionDefinition, atLine: 11, ignoringExtraLines: true))
  }

  func test__render__givenSchemaType_whenTestMocksAbsolute_withPublicAccessModifier_shouldRenderWithPublicAccess() {
    // given
    buildSubject(name: "Dog", testMocks: .absolute(path: "", accessModifier: .public))

    subject.graphqlObject.fields = [
      "string": .mock("string", type: .nonNull(.string()))
    ]

    ir.fieldCollector.add(
      fields: subject.graphqlObject.fields.values.map {
        .mock($0.name, type: $0.type)
      },
      to: subject.graphqlObject
    )

    let expectedClassDefinition = """
    public class Dog: MockObject {
    """

    let expectedExtensionDefinition = """
    public extension Mock where O == Dog {
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expectedClassDefinition, ignoringExtraLines: true))
    expect(actual).to(equalLineByLine(expectedExtensionDefinition, atLine: 11, ignoringExtraLines: true))
  }

  func test__render__givenSchemaType_whenTestMocksAbsolute_withInternalAccessModifier_shouldRenderWithInternalAccess() {
    // given
    buildSubject(name: "Dog", testMocks: .absolute(path: "", accessModifier: .internal))

    subject.graphqlObject.fields = [
      "string": .mock("string", type: .nonNull(.string()))
    ]

    ir.fieldCollector.add(
      fields: subject.graphqlObject.fields.values.map {
        .mock($0.name, type: $0.type)
      },
      to: subject.graphqlObject
    )

    let expectedClassDefinition = """
    class Dog: MockObject {
    """

    let expectedExtensionDefinition = """
    extension Mock where O == Dog {
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expectedClassDefinition, ignoringExtraLines: true))
    expect(actual).to(equalLineByLine(expectedExtensionDefinition, atLine: 11, ignoringExtraLines: true))
  }

  // MARK: - Deprecation Warnings

  func test__render_fieldAccessors__givenWarningsOnDeprecatedUsage_include_hasDeprecatedField_shouldGenerateWarning() throws {
    // given
    buildSubject(moduleType: .swiftPackageManager, warningsOnDeprecatedUsage: .include)

    subject.graphqlObject.fields = [
      "string": .mock("string", type: .nonNull(.string()), deprecationReason: "Cause I said so!"),
    ]

    ir.fieldCollector.add(
      fields: subject.graphqlObject.fields.values.map {
        .mock($0.name, type: $0.type, deprecationReason: $0.deprecationReason)
      },
      to: subject.graphqlObject
    )

    let expected = """
      public struct MockFields {
        @available(*, deprecated, message: "Cause I said so!")
        @Field<String>("string") public var string
      }
    """
    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 6, ignoringExtraLines: true))
  }

  func test__render_fieldAccessors__givenWarningsOnDeprecatedUsage_exclude_hasDeprecatedField_shouldNotGenerateWarning() throws {
    // given
    buildSubject(moduleType: .swiftPackageManager, warningsOnDeprecatedUsage: .exclude)

    subject.graphqlObject.fields = [
      "string": .mock("string", type: .nonNull(.string()), deprecationReason: "Cause I said so!"),
    ]

    ir.fieldCollector.add(
      fields: subject.graphqlObject.fields.values.map {
        .mock($0.name, type: $0.type, deprecationReason: $0.deprecationReason)
      },
      to: subject.graphqlObject
    )

    let expected = """
      public struct MockFields {
        @Field<String>("string") public var string
      }
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 6, ignoringExtraLines: true))
  }

}
