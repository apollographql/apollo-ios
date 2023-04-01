import XCTest
import Nimble
import OrderedCollections
@testable import ApolloCodegenLib
import ApolloCodegenInternalTestHelpers

class LocalCacheMutationDefinitionTemplateTests: XCTestCase {

  var schemaSDL: String!
  var document: String!
  var ir: IR!
  var operation: IR.Operation!
  var config: ApolloCodegenConfiguration!
  var subject: LocalCacheMutationDefinitionTemplate!

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
    query TestOperation @apollo_client_ios_localCacheMutation {
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
    subject = LocalCacheMutationDefinitionTemplate(
      operation: operation,
      config: ApolloCodegen.ConfigurationContext(config: config)
    )
  }

  private func renderSubject() -> String {
    subject.template.description
  }

  // MARK: - Operation Definition

  func test__generate__givenQuery_generatesLocalCacheMutation() throws {
    // given
    let expected =
    """
    class TestOperationLocalCacheMutation: LocalCacheMutation {
      static let operationType: GraphQLOperationType = .query

    """

    // when
    try buildSubjectAndOperation()

    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__generate__givenQueryWithLowercasing_generatesCorrectlyCasedLocalCacheMutation() throws {
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
    query lowercaseOperation($variable: String = "TestVar") @apollo_client_ios_localCacheMutation {
      allAnimals {
        species
      }
    }
    """

    let expected =
    """
    class LowercaseOperationLocalCacheMutation: LocalCacheMutation {
      static let operationType: GraphQLOperationType = .query

    """

    // when
    try buildSubjectAndOperation(named: "lowercaseOperation")

    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__generate__givenQueryWithNameEndingInLocalCacheMutation_generatesLocalCacheMutationWithoutDoubledTypeSuffix() throws {
    // given
    document = """
    query TestOperationLocalCacheMutation @apollo_client_ios_localCacheMutation {
      allAnimals {
        species
      }
    }
    """

    let expected =
    """
    class TestOperationLocalCacheMutation: LocalCacheMutation {
      static let operationType: GraphQLOperationType = .query

    """

    // when
    try buildSubjectAndOperation(named: "TestOperationLocalCacheMutation")

    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__generate__givenMutation_generatesLocalCacheMutation() throws {
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
    mutation TestOperation @apollo_client_ios_localCacheMutation {
      addAnimal {
        species
      }
    }
    """

    let expected =
    """
    class TestOperationLocalCacheMutation: LocalCacheMutation {
      static let operationType: GraphQLOperationType = .mutation

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
    subscription TestOperation @apollo_client_ios_localCacheMutation {
      streamAnimals {
        species
      }
    }
    """

    let expected =
    """
    class TestOperationLocalCacheMutation: LocalCacheMutation {
      static let operationType: GraphQLOperationType = .subscription

    """

    // when
    try buildSubjectAndOperation()

    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test__generate__givenQuery_generatesSelectionSetsAsMutable() throws {
    // given
    let expected =
    """
      struct Data: TestSchema.MutableSelectionSet {
        var __data: DataDict
    """

    // when
    try buildSubjectAndOperation()

    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 6, ignoringExtraLines: true))
  }

  func test__generate__givenLowercasedSchemaName_generatesSelectionSetsWithFirstUppercasedNamespace() throws {
    // given
    let expected =
    """
      public struct Data: Myschema.MutableSelectionSet {
        public var __data: DataDict
    """

    // when
    config = .mock(schemaNamespace: "myschema")
    try buildSubjectAndOperation()

    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 6, ignoringExtraLines: true))
  }

  func test__generate__givenUppercasedSchemaName_generatesSelectionSetsWithUppercasedNamespace() throws {
    // given
    let expected =
    """
      public struct Data: MYSCHEMA.MutableSelectionSet {
        public var __data: DataDict
    """

    // when
    config = .mock(schemaNamespace: "MYSCHEMA")
    try buildSubjectAndOperation()

    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 6, ignoringExtraLines: true))
  }

  func test_render_givenModuleType_swiftPackageManager_generatesClassDefinition_withPublicModifier() throws {
    // given
    config = .mock(.swiftPackageManager)
    try buildSubjectAndOperation()

    let expected = """
    public class TestOperationLocalCacheMutation: LocalCacheMutation {
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test_render_givenModuleType_other_generatesClassDefinition_withPublicModifier() throws {
    // given
    config  = .mock(.other)
    try buildSubjectAndOperation()

    let expected = """
    public class TestOperationLocalCacheMutation: LocalCacheMutation {
    """

    // when
    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, ignoringExtraLines: true))
  }

  func test_render_givenModuleType_embeddedInTarget_generatesClassDefinition_noPublicModifier() throws {
    // given
    config = .mock(.embeddedInTarget(name: "MyOtherProject"))
    try buildSubjectAndOperation()

    let expected = """
    class TestOperationLocalCacheMutation: LocalCacheMutation {
    """

    // when
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
     query TestOperation($variable: String!) @apollo_client_ios_localCacheMutation {
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

       public var __variables: GraphQLOperation.Variables? { ["variable": variable] }
     """

     // when
     try buildSubjectAndOperation()

     let actual = renderSubject()

     // then
     expect(actual).to(equalLineByLine(expected, atLine: 4, ignoringExtraLines: true))
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
    query TestOperation($variable1: String!, $variable2: Boolean!, $variable3: Int!) @apollo_client_ios_localCacheMutation {
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

      public var __variables: GraphQLOperation.Variables? { [
        "variable1": variable1,
        "variable2": variable2,
        "variable3": variable3
      ] }
    """

    // when
    try buildSubjectAndOperation()

    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 4, ignoringExtraLines: true))
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
    query TestOperation($variable: String = "TestVar") @apollo_client_ios_localCacheMutation {
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

      public var __variables: GraphQLOperation.Variables? { ["variable": variable] }
    """

    // when
    try buildSubjectAndOperation()

    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 4, ignoringExtraLines: true))
  }

  // MARK: Initializer Rendering Config - Tests

  func test__render_givenLocalCacheMutation_configIncludesLocalCacheMutations_rendersInitializer() throws {
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
    query TestOperation @apollo_client_ios_localCacheMutation {
      allAnimals {
        species
      }
    }
    """

    let expected =
    """
        }

        init(
    """

    config = ApolloCodegenConfiguration.mock(
      schemaNamespace: "TestSchema",
      options: .init(
        selectionSetInitializers: [.localCacheMutations]
      )
    )

    // when
    try buildSubjectAndOperation()

    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 18, ignoringExtraLines: true))
  }

  func test__render_givenLocalCacheMutation_configIncludesSpecificLocalCacheMutations_rendersInitializer() throws {
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
    query TestOperation @apollo_client_ios_localCacheMutation {
      allAnimals {
        species
      }
    }
    """

    let expected =
    """
        }

        init(
    """

    config = ApolloCodegenConfiguration.mock(
      schemaNamespace: "TestSchema",
      options: .init(
        selectionSetInitializers: [.operation(named: "TestOperation")]
      )
    )

    // when
    try buildSubjectAndOperation()

    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 18, ignoringExtraLines: true))
  }

  func test__render_givenLocalCacheMutation_configDoesNotIncludesLocalCacheMutations_doesNotRenderInitializer() throws
  {
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
    query TestOperation @apollo_client_ios_localCacheMutation {
      allAnimals {
        species
      }
    }
    """

    config = ApolloCodegenConfiguration.mock(
      schemaNamespace: "TestSchema",
      options: .init(
        selectionSetInitializers: [.namedFragments]
      )
    )

    // when
    try buildSubjectAndOperation()

    let actual = renderSubject()

    // then
    expect(actual).to(equalLineByLine("    /// AllAnimal", atLine: 20, ignoringExtraLines: true))
  }

}
