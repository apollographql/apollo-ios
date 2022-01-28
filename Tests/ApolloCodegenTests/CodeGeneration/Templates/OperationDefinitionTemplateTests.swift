import XCTest
import Nimble
import OrderedCollections
@testable import ApolloCodegenLib
import ApolloCodegenTestSupport

class OperationDefinitionTemplateTests: XCTestCase {

  var schemaSDL: String!
  var document: String!
  var ir: IR!
  var operation: IR.Operation!
  var config: ApolloCodegenConfiguration!
  var subject: OperationDefinitionTemplate!

  override func setUp() {
    super.setUp()
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

    config = .mock()
  }

  override func tearDown() {
    schemaSDL = nil
    document = nil
    ir = nil
    operation = nil
    config = nil
    subject = nil
    super.tearDown()
  }

  // MARK: - Helpers

  func buildSubjectAndOperation(named operationName: String = "TestOperation") throws {
    ir = try .mock(schema: schemaSDL, document: document)
    let operationDefinition = try XCTUnwrap(ir.compilationResult[operation: operationName])
    operation = ir.build(operation: operationDefinition)
    subject = OperationDefinitionTemplate(
      operation: operation,
      schema: ir.schema,
      config: config
    )
  }

  // MARK: - Import Statements

  func test__generate__givenFileOutput_inSchemaModule_schemaModuleManuallyLinked_generatesImportNotIncludingSchemaModule() throws {
    // given
    config = .mock(output: .mock(
      moduleType: .manuallyLinked(namespace: "TestModuleName"),
      operations: .inSchemaModule
    ))

    let expected =
    """
    import ApolloAPI

    """

    // when
    try buildSubjectAndOperation()

    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__generate__givenFileOutput_inSchemaModule_schemaModuleNotManuallyLinked_generatesImportNotIncludingSchemaModule() throws {
    // given
    config = .mock(output: .mock(
      moduleType: .swiftPackageManager(moduleName: "TestModuleName"),
      operations: .inSchemaModule
    ))

    let expected =
    """
    import ApolloAPI

    """

    // when
    try buildSubjectAndOperation()

    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__generate__givenFileOutput_notInSchemaModule_schemaModuleNotManuallyLinked_generatesImportIncludingSchemaModule() throws {
    // given
    config = .mock(output: .mock(
      moduleType: .swiftPackageManager(moduleName: "TestModuleName"),
      operations: .absolute(path: "")
    ))

    let expected =
    """
    import ApolloAPI
    import TestModuleName

    """

    // when
    try buildSubjectAndOperation()

    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  // MARK: - Operation Definition

  func test__generate__givenQuery_generatesQueryOperation() throws {
    // given
    let expected =
    """
    public class TestOperationQuery: GraphQLQuery {
      public let operationName: String = "TestOperation"
    """

    // when
    try buildSubjectAndOperation()

    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 3, ignoringExtraLines: true))
  }

  func test__generate__givenMutation_generatesMutationOperation() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Mutation {
      addAnimal: Animal!
    }

    type Animal {
      species: String!
    }
    """

    document = """
    mutation TestOperation {
      addAnimal {
        species
      }
    }
    """

    let expected =
    """
    public class TestOperationMutation: GraphQLMutation {
      public let operationName: String = "TestOperation"
    """

    // when
    try buildSubjectAndOperation()

    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 3, ignoringExtraLines: true))
  }

  func test__generate__givenSubscription_generatesSubscriptionOperation() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Subscription {
      streamAnimals: [Animal!]
    }

    type Animal {
      species: String!
    }
    """

    document = """
    subscription TestOperation {
      streamAnimals {
        species
      }
    }
    """

    let expected =
    """
    public class TestOperationSubscription: GraphQLSubscription {
      public let operationName: String = "TestOperation"
    """

    // when
    try buildSubjectAndOperation()

    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 3, ignoringExtraLines: true))
  }
}
