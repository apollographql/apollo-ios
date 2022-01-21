import XCTest
import Nimble
import OrderedCollections
@testable import ApolloCodegenLib
import ApolloTestSupport
import ApolloCodegenTestSupport
import ApolloAPI
import ApolloUtils

class IRNamedFragmentBuilderTests: XCTestCase {

  var schemaSDL: String!
  var document: String!
  var ir: IR!
  var fragment: CompilationResult.FragmentDefinition!
  var subject: IR.NamedFragment!

  var schema: IR.Schema { ir.schema }

  override func setUp() {
    super.setUp()
  }

  override func tearDown() {
    schemaSDL = nil
    document = nil
    fragment = nil
    subject = nil
    super.tearDown()
  }

  // MARK: - Helpers

  func buildSubjectFragment() throws {
    ir = try .mock(schema: schemaSDL, document: document)
    fragment = try XCTUnwrap(ir.compilationResult[fragment: "TestFragment"])
    subject = ir.build(fragment: fragment)
  }

  func test__buildFragment__givenFragment_hasConfiguredRootField() throws {
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
    fragment TestFragment on Animal {
      species
    }
    """

    // when
    try buildSubjectFragment()

    let Object_Animal = try ir.schema[interface: "Animal"].xctUnwrapped()

    // then
    expect(self.subject.definition).to(beIdenticalTo(fragment))
    expect(self.subject.definition.name).to(equal("TestFragment"))

    expect(self.subject.rootField.underlyingField.name).to(equal("TestFragment"))
    expect(self.subject.rootField.underlyingField.type).to(equal(.nonNull(.entity(Object_Animal))))
    expect(self.subject.rootField.underlyingField.selectionSet)
      .to(beIdenticalTo(self.fragment.selectionSet))

    expect(self.subject.rootField.selectionSet.entity.rootType).to(equal(Object_Animal))
    expect(self.subject.rootField.selectionSet.entity.rootTypePath)
      .to(equal(LinkedList(Object_Animal)))
    expect(self.subject.rootField.selectionSet.entity.fieldPath).to(equal(ResponsePath("TestFragment")))
  }

}
