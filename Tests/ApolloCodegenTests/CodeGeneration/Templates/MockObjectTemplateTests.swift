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

  // MARK: Helpers

  private func buildSubject(
    name: String = "Dog",
    interfaces: [GraphQLInterfaceType] = [],
    moduleType: ApolloCodegenConfiguration.SchemaTypesFileOutput.ModuleType = .swiftPackageManager,
    warningsOnDeprecatedUsage: ApolloCodegenConfiguration.Composition = .exclude
  ) {
    let config = ApolloCodegenConfiguration.mock(
      moduleType,
      warningsOnDeprecatedUsage: warningsOnDeprecatedUsage
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

  func test_render_givenSchemaType_generatesExtension() {
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

  // MARK: Class Definition Tests

  func test_render_givenSchemaTypeWithLowercaseName_generatesExtensionCorrectlyCased() {
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

  // MARK: Field Accessor Tests

  func test_render_givenSchemaType_generatesFieldAccessors() {
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

  // MARK: Convenience Initializer Tests

  func test_render_givenSchemaType_generatesConvenienceInitializer() {
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
    expect(actual).to(equalLineByLine(expected, atLine: 23, ignoringExtraLines: false))
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
