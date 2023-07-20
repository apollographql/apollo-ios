import XCTest
import Nimble
import OrderedCollections
@testable import ApolloCodegenLib
import ApolloInternalTestHelpers
import ApolloCodegenInternalTestHelpers
import ApolloAPI

class IROperationBuilderTests: XCTestCase {

  var schemaSDL: String!
  var document: String!
  var ir: IR!
  var operation: CompilationResult.OperationDefinition!
  var subject: IR.Operation!

  var schema: IR.Schema { ir.schema }

  override func setUp() {
    super.setUp()
  }

  override func tearDown() {
    schemaSDL = nil
    document = nil
    operation = nil
    subject = nil
    super.tearDown()
  }

  // MARK: = Helpers

  func buildSubjectOperation(
    named operationName: String? = nil,
    fromJSONSchema json: Bool = false
  ) throws {
    ir = json ?
    try .mock(schemaJSON: schemaSDL, document: document) :
    try .mock(schema: schemaSDL, document: document)

    if let operationName = operationName {
      operation = try XCTUnwrap(ir.compilationResult.operations.first {$0.name == operationName})
    } else {
      operation = try XCTUnwrap(ir.compilationResult.operations.first)
    }
    subject = ir.build(operation: operation)
  }

  func test__buildOperation__givenQuery_hasRootFieldAsQuery() throws {
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
    query Test {
      allAnimals {
        species
      }
    }
    """

    // when
    try buildSubjectOperation()

    let Object_Query = GraphQLObjectType.mock("Query")

    // then
    expect(self.subject.definition.operationType).to(equal(.query))

    expect(self.subject.rootField.underlyingField.name).to(equal("query"))
    expect(self.subject.rootField.underlyingField.type).to(equal(.nonNull(.entity(Object_Query))))
    expect(self.subject.rootField.underlyingField.selectionSet)
      .to(beIdenticalTo(self.operation.selectionSet))

    expect(self.subject.rootField.selectionSet.entity.rootType).to(equal(Object_Query))
    expect(self.subject.rootField.selectionSet.entity.rootTypePath)
      .to(equal(LinkedList(Object_Query)))
    expect(self.subject.rootField.selectionSet.entity.location)
      .to(equal(.init(source: .operation(self.subject.definition), fieldPath: nil)))
  }

  func test__buildOperation__givenSubscription_hasRootFieldAsSubscription() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Subscription {
      streamAnimal: Animal!
    }

    interface Animal {
      species: String!
    }
    """

    document = """
    subscription Test {
      streamAnimal {
        species
      }
    }
    """

    // when
    try buildSubjectOperation()

    let Object_Subscription = GraphQLObjectType.mock("Subscription")

    // then
    expect(self.subject.definition.operationType).to(equal(.subscription))

    expect(self.subject.rootField.underlyingField.name).to(equal("subscription"))
    expect(self.subject.rootField.underlyingField.type).to(equal(.nonNull(.entity(Object_Subscription))))
    expect(self.subject.rootField.underlyingField.selectionSet)
      .to(beIdenticalTo(self.operation.selectionSet))

    expect(self.subject.rootField.selectionSet.entity.rootType).to(equal(Object_Subscription))
    expect(self.subject.rootField.selectionSet.entity.rootTypePath)
      .to(equal(LinkedList(Object_Subscription)))
    expect(self.subject.rootField.selectionSet.entity.location)
      .to(equal(.init(source: .operation(self.subject.definition), fieldPath: nil)))
  }

  func test__buildOperation__givenMutation_hasRootFieldAsMutation() throws {
    // given
    schemaSDL = """
    type Mutation {
      createAnimal: Animal!
    }

    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
    }
    """

    document = """
    mutation Test {
      createAnimal {
        species
      }
    }
    """

    // when
    try buildSubjectOperation()

    let Object_Mutation = GraphQLObjectType.mock("Mutation")

    // then
    expect(self.subject.definition.operationType).to(equal(.mutation))

    expect(self.subject.rootField.underlyingField.name).to(equal("mutation"))
    expect(self.subject.rootField.underlyingField.type).to(equal(.nonNull(.entity(Object_Mutation))))
    expect(self.subject.rootField.underlyingField.selectionSet)
      .to(beIdenticalTo(self.operation.selectionSet))

    expect(self.subject.rootField.selectionSet.entity.rootType).to(equal(Object_Mutation))
    expect(self.subject.rootField.selectionSet.entity.rootTypePath)
      .to(equal(LinkedList(Object_Mutation)))
    expect(self.subject.rootField.selectionSet.entity.location)
      .to(equal(.init(source: .operation(self.subject.definition), fieldPath: nil)))
  }

  // MARK: - Operation Identifier Computation

  func test__buildOperation__givenOperationWithNoFragments__hasCorrectOperationIdentifier() throws {
    // given
    document = try String(
      contentsOf: ApolloCodegenInternalTestHelpers.Resources.StarWars.GraphQLOperation(named: "HeroAndFriendsNames")
    )

    schemaSDL = try String(
      contentsOf: ApolloCodegenInternalTestHelpers.Resources.StarWars.JSONSchema)

    let expected = "1e36c3331171b74c012b86caa04fbb01062f37c61227655d9c0729a62c6f7285"

    // when
    try buildSubjectOperation(named: "HeroAndFriendsNames", fromJSONSchema: true)

    // then
    expect(self.subject.operationIdentifier).to(equal(expected))
  }

  func test__buildOperation__givenOperationWithFragment__hasCorrectOperationIdentifier() throws {
    // given
    document = try String(
      contentsOf: ApolloCodegenInternalTestHelpers.Resources.StarWars.GraphQLOperation(named: "HeroAndFriendsNamesWithFragment")
    ) + "\n" + String(
      contentsOf: ApolloCodegenInternalTestHelpers.Resources.StarWars.GraphQLOperation(named: "HeroName")
    )

    schemaSDL = try String(
      contentsOf: ApolloCodegenInternalTestHelpers.Resources.StarWars.JSONSchema)

    let expected = "64c202d03546e91cd18840ad6a98d31e2b843b5687a9adf1d99a1eca09c0d983"

    // when
    try buildSubjectOperation(named: "HeroAndFriendsNamesWithFragment", fromJSONSchema: true)

    // then
    expect(self.subject.operationIdentifier).to(equal(expected))
  }
  
}
