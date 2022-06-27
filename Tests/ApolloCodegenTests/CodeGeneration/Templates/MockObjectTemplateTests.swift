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

  func test_render_givenModuleType_swiftPackageManager_generatesExtension_noNamespace() {
    // given
    buildSubject(name: "Dog", moduleType: .swiftPackageManager)

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

  func test_render_givenModuleType_other_generatesExtension_noNamespace() {
    // given
    buildSubject(name: "Dog", moduleType: .other)

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

  func test_render_givenModuleType_embeddedInTarget_generatesExtension_withNamespace() {
    // given
    buildSubject(name: "Dog", moduleType: .embeddedInTarget(name: "MockApplication"))

    let expected = """
    extension TestSchema.Dog: Mockable {
      public static let __mockFields = MockFields()

      public typealias MockValueCollectionType = Array<Mock<TestSchema.Dog>>

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

  func test_render_givenModuleType_swiftPackageManager_generatesFieldAccessors_noNamespace() {
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
        @Field<CustomScalar>("customScalar") public var customScalar
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

  func test_render_givenModuleType_other_generatesFieldAccessors_noNamespace() {
    // given
    buildSubject(moduleType: .other)

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
        @Field<CustomScalar>("customScalar") public var customScalar
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

  func test_render_givenModuleType_embeddedInTarget_generatesFieldAccessors_withNamespace() {
    // given
    buildSubject(moduleType: .embeddedInTarget(name: "MockTarget"))

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
        @Field<TestSchema.Cat>("object") public var object
        @Field<[TestSchema.Cat]>("objectList") public var objectList
        @Field<[[TestSchema.Cat]]>("objectNestedList") public var objectNestedList
        @Field<[TestSchema.Cat?]>("objectOptionalList") public var objectOptionalList
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

  func test_render_givenModuleType_swiftPackageManager_generatesConvenienceInitializer_noNamespace() {
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
        customScalar: CustomScalar? = nil,
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
    expect(actual).to(equalLineByLine(expected, atLine: 23, ignoringExtraLines: true))
  }

  func test_render_givenModuleType_other_generatesConvenienceInitializer_noNamespace() {
    // given
    buildSubject(moduleType: .other)

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
        customScalar: CustomScalar? = nil,
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
    expect(actual).to(equalLineByLine(expected, atLine: 23, ignoringExtraLines: true))
  }

  func test_render_givenModuleType_embeddedInTarget_generatesConvenienceInitializer_withNamespace() {
    // given
    buildSubject(moduleType: .embeddedInTarget(name: "MockTarget"))

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
    ]

    ir.fieldCollector.add(
      fields: subject.graphqlObject.fields.values.map {
        .mock($0.name, type: $0.type)
      },
      to: subject.graphqlObject
    )

    let expected = """
    }

    public extension Mock where O == TestSchema.Dog {
      convenience init(
        customScalar: TestSchema.CustomScalar? = nil,
        interface: AnyMock? = nil,
        interfaceList: [AnyMock]? = nil,
        interfaceNestedList: [[AnyMock]]? = nil,
        interfaceOptionalList: [AnyMock?]? = nil,
        object: Mock<TestSchema.Cat>? = nil,
        objectList: [Mock<TestSchema.Cat>]? = nil,
        objectNestedList: [[Mock<TestSchema.Cat>]]? = nil,
        objectOptionalList: [Mock<TestSchema.Cat>?]? = nil,
        optionalString: String? = nil,
        string: String? = nil,
        union: AnyMock? = nil,
        unionList: [AnyMock]? = nil,
        unionNestedList: [[AnyMock]]? = nil,
        unionOptionalList: [AnyMock?]? = nil
      ) {
        self.init()
        self.customScalar = customScalar
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
    expect(actual).to(equalLineByLine(expected, atLine: 23, ignoringExtraLines: true))
  }

}
