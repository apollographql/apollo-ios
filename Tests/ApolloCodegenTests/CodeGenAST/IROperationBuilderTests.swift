import XCTest
import Nimble
import OrderedCollections
@testable import ApolloCodegenLib
import ApolloTestSupport
import ApolloCodegenTestSupport
import ApolloAPI
import ApolloUtils

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

  func buildSubjectOperation() throws {
    ir = try .mock(schema: schemaSDL, document: document)
    operation = try XCTUnwrap(ir.compilationResult.operations.first)
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
    expect(self.subject.rootField.selectionSet.entity.fieldPath).to(equal(ResponsePath("query")))
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
    expect(self.subject.rootField.selectionSet.entity.fieldPath).to(equal(ResponsePath("subscription")))
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
    expect(self.subject.rootField.selectionSet.entity.fieldPath).to(equal(ResponsePath("mutation")))
  }
}
