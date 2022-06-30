import XCTest
import Nimble
import ApolloInternalTestHelpers
import ApolloCodegenInternalTestHelpers
@testable import ApolloCodegenLib

class CompilationResultSchemaDocumentationTests: XCTestCase {

  var schemaSDL: String!
  var document: String!

  override func setUpWithError() throws {
    try super.setUpWithError()

  }

  override func tearDown() {
    schemaSDL = nil
    document = nil

    super.tearDown()
  }

  // MARK: - Helpers

  func compileFrontend() throws -> CompilationResult {
    let frontend = try GraphQLJSFrontend()
    return try frontend.compile(
      schema: schemaSDL,
      document: document
    )
  }

  // MARK: - Tests

  func testCompile_givenSchemaTypeDocumentation_includesSchemaDocumentation() throws {
    let documentation = "The Schema Docs"

    schemaSDL = """
    "\(documentation)"
    schema {
     query: Query
    }

    type Query {
      a: String!
    }
    """

    document = """
    query Test {
      a
    }
    """

    let compilationResult = try compileFrontend()

    expect(compilationResult.schemaDocumentation).to(equal(documentation))
  }

  func testCompile_givenMultilineDocumentation_includesDocumentation() throws {
    let documentation = """
    The Root Query Object
    What a great object!
    """

    schemaSDL = """
    ""\"
    \(documentation)
    ""\"
    type Query {
      a: String!
    }
    """

    document = """
    query Test {
      a
    }
    """

    let compilationResult = try compileFrontend()
    let actual = compilationResult[type: "Query"]

    expect(actual?.documentation).to(equal(documentation))
  }

  func testCompile_givenObjectTypeWithDocumentation_includesDocumentation() throws {
    let documentation = "This is some great documentation!"

    schemaSDL = """
    "\(documentation)"
    type Query {
      a: String!
    }
    """

    document = """
    query Test {
      a
    }
    """

    let compilationResult = try compileFrontend()
    let actual = compilationResult[type: "Query"]

    expect(actual?.documentation).to(equal(documentation))
  }

  func testCompile_givenInterfaceTypeWithDocumentation_includesDocumentation() throws {
    let documentation = "This is some great documentation!"

    schemaSDL = """
    type Query {
      a: CustomInterface!
    }

    "\(documentation)"
    interface CustomInterface {
      b: String!
    }
    """

    document = """
    query Test {
      a {
        b
      }
    }
    """

    let compilationResult = try compileFrontend()
    let actual = compilationResult[type: "CustomInterface"]

    expect(actual?.documentation).to(equal(documentation))
  }

  func testCompile_givenUnionTypeWithDocumentation_includesDocumentation() throws {
    let documentation = "This is some great documentation!"

    schemaSDL = """
    type Query {
      a: CustomUnion!
    }

    "\(documentation)"
    union CustomUnion = One | Two

    type One {
      one: String!
    }

    type Two {
      two: String!
    }
    """

    document = """
    query Test {
      a {
        ... on One {
          one
        }
      }
    }
    """

    let compilationResult = try compileFrontend()
    let actual = compilationResult[type: "CustomUnion"]

    expect(actual?.documentation).to(equal(documentation))
  }

  func testCompile_givenScalarTypeWithDocumentation_includesDocumentation() throws {
    let documentation = "This is some great documentation!"

    schemaSDL = """
    type Query {
      a: CustomScalar!
    }

    "\(documentation)"
    scalar CustomScalar
    """

    document = """
    query Test {
      a
    }
    """

    let compilationResult = try compileFrontend()
    let actual = compilationResult[type: "CustomScalar"]

    expect(actual?.documentation).to(equal(documentation))
  }

  func testCompile_givenEnumTypeWithDocumentation_includesDocumentation() throws {
    let documentation = "This is some great documentation!"

    schemaSDL = """
    type Query {
      a: TestEnum!
    }

    "\(documentation)"
    enum TestEnum {
     A
     B
    }
    """

    document = """
    query Test {
      a
    }
    """

    let compilationResult = try compileFrontend()
    let actual = compilationResult[type: "TestEnum"]

    expect(actual?.documentation).to(equal(documentation))
  }

  func testCompile_givenEnumValuesWithDocumentation_includesDocumentation() throws {
    let documentation_A = "Enum case A"
    let documentation_B = "Enum case B"

    schemaSDL = """
    type Query {
      a: TestEnum!
    }

    enum TestEnum {
    "\(documentation_A)"
     A
    "\(documentation_B)"
     B
    }
    """

    document = """
    query Test {
      a
    }
    """

    let compilationResult = try compileFrontend()
    let TestEnum = compilationResult[type: "TestEnum"] as? GraphQLEnumType

    expect(TestEnum?.values[0].documentation).to(equal(documentation_A))
    expect(TestEnum?.values[1].documentation).to(equal(documentation_B))
  }

  func testCompile_givenInputObjectTypeWithDocumentation_includesDocumentation() throws {
    let documentation = "This is some great documentation!"

    schemaSDL = """
    type Query {
      a(input: CustomInput!): String!
    }

    "\(documentation)"
    input CustomInput {
      b: String!
    }
    """

    document = """
    query Test($input: CustomInput!) {
      a(input: $input)
    }
    """

    let compilationResult = try compileFrontend()
    let actual = compilationResult[type: "CustomInput"]

    expect(actual?.documentation).to(equal(documentation))
  }

  func testCompile_givenInputFieldWithDocumentation_includesDocumentation() throws {
    let documentation = "This is some great documentation!"

    schemaSDL = """
    type Query {
      a(input: CustomInput!): String!
    }

    input CustomInput {
      "\(documentation)"
      b: String!
    }
    """

    document = """
    query Test($input: CustomInput!) {
      a(input: $input)
    }
    """

    let compilationResult = try compileFrontend()
    let CustomInput = compilationResult[type: "CustomInput"] as? GraphQLInputObjectType
    let actual = CustomInput?.fields["b"]

    expect(actual?.documentation).to(equal(documentation))
  }

  func testCompile_givenFieldWithDocumentation_includesDocumentation() throws {
    let documentation = "This is some great documentation!"

    schemaSDL = """
    type Query {
      a: CustomType!
    }

    type CustomType {
      "\(documentation)"
      b: String!
    }
    """

    document = """
    query Test {
      a {
        b
      }
    }
    """

    let compilationResult = try compileFrontend()
    let CustomType = compilationResult[type: "CustomType"] as? GraphQLObjectType
    let actual = CustomType?.fields["b"]

    expect(actual?.documentation).to(equal(documentation))
  }

  func testCompile_givenFieldArgumentWithDocumentation_includesDocumentation() throws {
    let documentation = "This is some great documentation!"

    schemaSDL = """
    type Query {
      a: CustomType!
    }

    type CustomType {
      b(
        "\(documentation)"
        argument: String!
      ): String!
    }
    """

    document = """
    query Test {
      a {
        b(argument: "Value")
      }
    }
    """

    let compilationResult = try compileFrontend()
    let CustomType = compilationResult[type: "CustomType"] as? GraphQLObjectType
    let actual = CustomType?.fields["b"]?.arguments.first

    expect(actual?.documentation).to(equal(documentation))
  }
}
