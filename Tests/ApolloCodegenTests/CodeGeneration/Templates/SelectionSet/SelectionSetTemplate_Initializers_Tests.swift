import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenInternalTestHelpers

class SelectionSetTemplate_Initializers_Tests: XCTestCase {

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
    selectionSetInitializers: ApolloCodegenConfiguration.SelectionSetInitializers
  ) throws {
    ir = try .mock(schema: schemaSDL, document: document)
    let operationDefinition = try XCTUnwrap(ir.compilationResult[operation: operationName])
    operation = ir.build(operation: operationDefinition)
    let config = ApolloCodegenConfiguration.mock(
      schemaName: "TestSchema",
      options: .init(
        selectionSetInitializers: selectionSetInitializers
      )
    )
    subject = SelectionSetTemplate(
      config: ApolloCodegen.ConfigurationContext(config: config)
    )
  }

  private func buildFragmentTemplate(
    named fragmentName: String = "TestFragment",
    selectionSetInitializers: ApolloCodegenConfiguration.SelectionSetInitializers
  ) throws -> FragmentTemplate {
    ir = try .mock(schema: schemaSDL, document: document)
    let fragmentDefinition = try XCTUnwrap(ir.compilationResult[fragment: fragmentName])
    let fragment = ir.build(fragment: fragmentDefinition)
    let config = ApolloCodegenConfiguration.mock(
      schemaName: "TestSchema",
      options: .init(
        selectionSetInitializers: selectionSetInitializers
      )
    )
    return FragmentTemplate(fragment: fragment, config: .init(config: config))
  }

  // MARK: - Tests

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

      public init(
        species: String
      ) {
        self.init(data: DataDict(
          objectType: AnimalKingdomAPI.Objects.Cat,
          data: ["species": species],
          variables: nil
        ))
      }
    """

    // when
    try buildSubjectAndOperation(
      selectionSetInitializers: [.localCacheMutations]
    )

    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 13, ignoringExtraLines: true))
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

    // when
    try buildSubjectAndOperation(
      selectionSetInitializers: [.namedFragments]
    )

    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine("}", atLine: 13, ignoringExtraLines: true))
  }

  func test__render_givenOperationSelectionSet_configIncludesOperations_rendersInitializer() throws {
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

    let expected =
    """
      }

      public init(
        species: String
      ) {
        self.init(data: DataDict(
          objectType: AnimalKingdomAPI.Objects.Cat,
          data: ["species": species],
          variables: nil
        ))
      }
    """

    // when
    try buildSubjectAndOperation(
      selectionSetInitializers: [.operations]
    )

    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 13, ignoringExtraLines: true))
  }

  func test__render_givenOperationSelectionSet_configIncludesSpecificOperation_rendersInitializer() throws {
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

    let expected =
    """
      }

      public init(
        species: String
      ) {
        self.init(data: DataDict(
          objectType: AnimalKingdomAPI.Objects.Cat,
          data: ["species": species],
          variables: nil
        ))
      }
    """

    // when
    try buildSubjectAndOperation(
      selectionSetInitializers: [.operation(named: "TestOperation")]
    )

    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 13, ignoringExtraLines: true))
  }

  func test__render_givenOperationSelectionSet_configDoesNotIncludeOperations_doesNotRenderInitializer() throws {
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
    try buildSubjectAndOperation(
      selectionSetInitializers: [.namedFragments]
    )

    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine("}", atLine: 13, ignoringExtraLines: true))
  }

  func test__render_givenOperationSelectionSet_configIncludeSpecificOperationWithOtherName_doesNotRenderInitializer() throws {
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
    try buildSubjectAndOperation(
      selectionSetInitializers: [.operation(named: "OtherOperation")]
    )

    let allAnimals = try XCTUnwrap(
      operation[field: "query"]?[field: "allAnimals"] as? IR.EntityField
    )

    let actual = subject.render(field: allAnimals)

    // then
    expect(actual).to(equalLineByLine("}", atLine: 13, ignoringExtraLines: true))
  }

  func test__render_givenNamedFragment_configIncludesNamedFragments_rendersInitializer() throws {
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
    fragment TestFragment on Animal {
      species
    }
    """

    let expected =
    """
      }

      public init(
        species: String
      ) {
        self.init(data: DataDict(
          objectType: AnimalKingdomAPI.Objects.Cat,
          data: ["species": species],
          variables: nil
        ))
      }
    """

    // when
    let subject = try buildFragmentTemplate(
      selectionSetInitializers: [.operations]
    )

    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 13, ignoringExtraLines: true))
  }

  func test__render_givenNamedFragment_configIncludesSpecificFragment_rendersInitializer() throws {
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
    fragment TestFragment on Animal {
      species
    }
    """

    let expected =
    """
      }

      public init(
        species: String
      ) {
        self.init(data: DataDict(
          objectType: AnimalKingdomAPI.Objects.Cat,
          data: ["species": species],
          variables: nil
        ))
      }
    """

    // when
    let subject = try buildFragmentTemplate(
      selectionSetInitializers: [.operations]
    )

    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine(expected, atLine: 13, ignoringExtraLines: true))
  }

  func test__render_givenNamedFragment_configDoesNotIncludeNamedFragments_doesNotRenderInitializer() throws {
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
    fragment TestFragment on Animal {
      species
    }
    """

    // when
    let subject = try buildFragmentTemplate(
      selectionSetInitializers: [.operations]
    )

    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine("}", atLine: 13, ignoringExtraLines: true))
  }

  func test__render_givenNamedFragments_configIncludeSpecificFragmentWithOtherName_doesNotRenderInitializer() throws {
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
    fragment TestFragment on Animal {
      species
    }
    """

    // when
    let subject = try buildFragmentTemplate(
      selectionSetInitializers: [.operations]
    )

    let actual = subject.render()

    // then
    expect(actual).to(equalLineByLine("}", atLine: 13, ignoringExtraLines: true))
  }

}
