import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenInternalTestHelpers
import ApolloUtils

class MockObjectTemplateTests: XCTestCase {

  var ir: IR!
  var subject: MockObjectTemplate!

  override func tearDown() {
    subject = nil
    ir = nil

    super.tearDown()
  }

  // MARK: Helpers

  private func buildSubject(
    name: String = "Dog",
    interfaces: [GraphQLInterfaceType] = [],
    moduleType: ApolloCodegenConfiguration.SchemaTypesFileOutput.ModuleType = .swiftPackageManager
  ) {
    let config = ApolloCodegenConfiguration.mock(moduleType)
    ir = IR.mock(compilationResult: .mock())

    subject = MockObjectTemplate(
      graphqlObject: GraphQLObjectType.mock(name, interfaces: interfaces),
      config: ReferenceWrapped(value: config),
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

  func test_render_givenSchemaType_generatesExtension() {
    // given
    buildSubject(name: "Dog")

    let expected = """
    extension Dog: Mockable {
      public static let __mockFields = MockFields()

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

  func test_render_givenConfig_SchemaTypeOutputNone_generatesExtensionWithSchemaNamespace() {
    // given
    buildSubject(name: "Dog", moduleType: .embeddedInTarget(name: "MockApplication"))

    let expected = """
    extension TestSchema.Dog: Mockable {
      public static let __mockFields = MockFields()

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

  // MARK: Class Definition Tests

  func test_render_givenSchemaType_generatesExtensionCorrectlyCased() {
    // given
    buildSubject(name: "dog")

    let expected = """
    extension Dog: Mockable {
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  // MARK: Field Accessor Tests

  func test_render_givenSchemaType_generatesFieldAccessors() {
    // given
    buildSubject()

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

  // MARK: Convenience Initializer Tests

  func test_render_givenSchemaType_generatesConvenienceInitializer() {
    // given
    buildSubject()

    let Cat: GraphQLType = .entity(GraphQLObjectType.mock("Cat"))

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
    }

    public extension Mock where O == Dog {
      convenience init(
        customScalar: TestSchema.CustomScalar? = nil,
        object: Mock<Cat>? = nil,
        objectList: [Mock<Cat>]? = nil,
        objectNestedList: [[Mock<Cat>]]? = nil,
        objectOptionalList: [Mock<Cat>?]? = nil,
        optionalString: String? = nil,
        string: String? = nil
      ) {
        self.init()
        self.customScalar = customScalar
        self.object = object
        self.objectList = objectList
        self.objectNestedList = objectNestedList
        self.objectOptionalList = objectOptionalList
        self.optionalString = optionalString
        self.string = string
      }
    }
    """
    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 15, ignoringExtraLines: true))
  }

  func test_render_givenSchemaType_withInterfaceTypedFields_generatesConvenienceInitializer() {
    // given
    buildSubject()

    let Animal: GraphQLType = .entity(GraphQLInterfaceType.mock("Animal"))

    subject.graphqlObject.fields = [
      "string": .mock("string", type: .nonNull(.string())),
      "customScalar": .mock("customScalar", type: .nonNull(.scalar(.mock(name: "CustomScalar")))),
      "optionalString": .mock("optionalString", type: .string()),
      "interface": .mock("interface", type: Animal),
      "interfaceList": .mock("interfaceList", type: .list(.nonNull(Animal))),
      "interfaceNestedList": .mock("interfaceNestedList", type: .list(.nonNull(.list(.nonNull(Animal))))),
      "interfaceOptionalList": .mock("interfaceOptionalList", type: .list(Animal)),
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
        interface: AnyMock? = nil,
        interfaceList: [AnyMock]? = nil,
        interfaceNestedList: [[AnyMock]]? = nil,
        interfaceOptionalList: [AnyMock?]? = nil,
        optionalString: String? = nil,
        string: String? = nil
      ) {
        self.init()
        self.customScalar = customScalar
        self.interface = interface
        self.interfaceList = interfaceList
        self.interfaceNestedList = interfaceNestedList
        self.interfaceOptionalList = interfaceOptionalList
        self.optionalString = optionalString
        self.string = string
      }
    }
    """
    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 15, ignoringExtraLines: true))
  }

  func test_render_givenSchemaType_withUnionTypedFields_generatesConvenienceInitializer() {
    // given
    buildSubject()

    let Animal: GraphQLType = .entity(GraphQLUnionType.mock("Animal"))

    subject.graphqlObject.fields = [
      "string": .mock("string", type: .nonNull(.string())),
      "customScalar": .mock("customScalar", type: .nonNull(.scalar(.mock(name: "CustomScalar")))),
      "optionalString": .mock("optionalString", type: .string()),
      "union": .mock("union", type: Animal),
      "unionList": .mock("unionList", type: .list(.nonNull(Animal))),
      "unionNestedList": .mock("unionNestedList", type: .list(.nonNull(.list(.nonNull(Animal))))),
      "unionOptionalList": .mock("unionOptionalList", type: .list(Animal)),
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
        optionalString: String? = nil,
        string: String? = nil,
        union: AnyMock? = nil,
        unionList: [AnyMock]? = nil,
        unionNestedList: [[AnyMock]]? = nil,
        unionOptionalList: [AnyMock?]? = nil
      ) {
        self.init()
        self.customScalar = customScalar
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
    expect(actual).to(equalLineByLine(expected, atLine: 15, ignoringExtraLines: true))
  }

}
