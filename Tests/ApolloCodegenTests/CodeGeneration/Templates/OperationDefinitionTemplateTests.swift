import XCTest
import Nimble
import OrderedCollections
@testable import ApolloCodegenLib
import ApolloCodegenInternalTestHelpers
import ApolloUtils

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

  private func buildSubjectAndOperation(named operationName: String = "TestOperation") throws {
    ir = try .mock(schema: schemaSDL, document: document)
    let operationDefinition = try XCTUnwrap(ir.compilationResult[operation: operationName])
    operation = ir.build(operation: operationDefinition)
    subject = OperationDefinitionTemplate(
      operation: operation,
      schema: ir.schema,
      config: ApolloCodegen.ConfigurationContext(config: config)
    )
  }

  private func renderSubject() -> String {
    subject.template.description
  }

  // MARK: - Operation Definition

  func test__generate__givenQuery_generatesQueryOperation() throws {
    // given
    let expected =
    """
    class TestOperationQuery: GraphQLQuery {
      public static let operationName: String = "TestOperation"
    """

    // when
    try buildSubjectAndOperation()

    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__generate__givenQueryWithNameEndingInQuery_generatesQueryOperationWithoutDoubledTypeSuffix() throws {
    // given
    document = """
    query TestOperationQuery {
      allAnimals {
        species
      }
    }
    """

    let expected =
    """
    class TestOperationQuery: GraphQLQuery {
      public static let operationName: String = "TestOperationQuery"
    """

    // when
    try buildSubjectAndOperation(named: "TestOperationQuery")

    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__generate__givenMutationWithNameEndingInQuery_generatesQueryOperationWithBothSuffixes() throws {
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
    mutation TestOperationQuery {
      addAnimal {
        species
      }
    }
    """

    let expected =
    """
    class TestOperationQueryMutation: GraphQLMutation {
      public static let operationName: String = "TestOperationQuery"
    """

    // when
    try buildSubjectAndOperation(named: "TestOperationQuery")

    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
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
    class TestOperationMutation: GraphQLMutation {
      public static let operationName: String = "TestOperation"
    """

    // when
    try buildSubjectAndOperation()

    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
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
    class TestOperationSubscription: GraphQLSubscription {
      public static let operationName: String = "TestOperation"
    """

    // when
    try buildSubjectAndOperation()

    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  // MARK: - Variables

   func test__generate__givenQueryWithScalarVariable_generatesQueryOperationWithVariable() throws {
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
     query TestOperation($variable: String!) {
       allAnimals {
         species
       }
     }
     """

     let expected =
     """
       public var variable: String

       public init(variable: String) {
         self.variable = variable
       }

       public var variables: Variables? {
         ["variable": variable]
       }
     """

     // when
     try buildSubjectAndOperation()

     let actual = renderSubject()

     // then
     expect(actual).to(equalLineByLine(expected, atLine: 15, ignoringExtraLines: true))
   }

  func test__generate__givenQueryWithMutlipleScalarVariables_generatesQueryOperationWithVariables() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      species: String!
      intField: Int!
    }
    """

    document = """
    query TestOperation($variable1: String!, $variable2: Boolean!, $variable3: Int!) {
      allAnimals {
        species
      }
    }
    """

    let expected =
    """
      public var variable1: String
      public var variable2: Bool
      public var variable3: Int

      public init(
        variable1: String,
        variable2: Bool,
        variable3: Int
      ) {
        self.variable1 = variable1
        self.variable2 = variable2
        self.variable3 = variable3
      }

      public var variables: Variables? {
        ["variable1": variable1,
         "variable2": variable2,
         "variable3": variable3]
      }
    """

    // when
    try buildSubjectAndOperation()

    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 15, ignoringExtraLines: true))
  }

  func test__generate__givenQueryWithNullableScalarVariable_generatesQueryOperationWithVariable() throws {
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
    query TestOperation($variable: String = "TestVar") {
      allAnimals {
        species
      }
    }
    """

    let expected =
    """
      public var variable: GraphQLNullable<String>
    
      public init(variable: GraphQLNullable<String> = "TestVar") {
        self.variable = variable
      }

      public var variables: Variables? {
        ["variable": variable]
      }
    """

    // when
    try buildSubjectAndOperation()

    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 15, ignoringExtraLines: true))
  }

  func test__generate__givenQueryWithLowercasing_generatesCorrectlyCasedQueryOperation() throws {
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
    query lowercaseOperation($variable: String = "TestVar") {
      allAnimals {
        species
      }
    }
    """

    let expected =
    """
    class LowercaseOperationQuery: GraphQLQuery {
      public static let operationName: String = "lowercaseOperation"
      public static let document: DocumentType = .notPersisted(
        definition: .init(
          \"\"\"
          query lowercaseOperation($variable: String = "TestVar") {
    """

    // when
    try buildSubjectAndOperation(named: "lowercaseOperation")

    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }
}
