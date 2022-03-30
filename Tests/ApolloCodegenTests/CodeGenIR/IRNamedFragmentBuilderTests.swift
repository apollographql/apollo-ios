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

  func test__buildFragment__givenFragment_hasNamedFragmentInBuiltFragments() throws {
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

    let actual = ir.builtFragments["TestFragment"]

    // then
    expect(actual).to(beIdenticalTo(self.subject))
  }

  func test__buildFragment__givenAlreadyBuiltFragment_returnsExistingBuiltFragment() throws {
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

    let actual = ir.build(fragment: fragment)

    // then
    expect(actual).to(beIdenticalTo(self.subject))
  }

  func test__referencedFragments__givenUsesFragmentsReferencingOtherFragment_includesBothFragments() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String
      name: String
    }
    """

    document = """
    fragment AnimalDetails on Animal {
      species
      ...AnimalName
    }

    fragment AnimalName on Animal {
      name
    }

    fragment TestFragment on Animal {
      ...AnimalDetails
    }
    """

    // when
    try buildSubjectFragment()

    let expected: OrderedSet = [
      try ir.builtFragments["AnimalDetails"].xctUnwrapped(),
      try ir.builtFragments["AnimalName"].xctUnwrapped(),
    ]

    // then
    expect(self.subject.referencedFragments).to(equal(expected))
  }

  func test__entities__givenUsesMultipleNestedEntities_includingEntitiesInNestedFragments_includesAllEntities() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      name: String
      friend: Animal
    }
    """

    document = """
    fragment AnimalDetails on Animal {
      details1: friend {
        details2: friend {
          name
        }
      }
    }

    fragment TestFragment on Animal {
      test1: friend {
        test2: friend {
          ...AnimalDetails
        }
      }
      ...AnimalDetails
    }
    """

    // when
    try buildSubjectFragment()

    let Interface_Animal = try schema[interface: "Animal"].xctUnwrapped()

    let rootFieldPath: ResponsePath = ["TestFragment"]
    let test1FieldPath: ResponsePath = ["TestFragment", "test1"]
    let test2FieldPath: ResponsePath = ["TestFragment", "test1", "test2"]
    let test_details1FieldPath: ResponsePath = ["TestFragment", "test1", "test2", "details1"]
    let test_details2FieldPath: ResponsePath = ["TestFragment", "test1", "test2", "details1", "details2"]
    let root_details1FieldPath: ResponsePath = ["TestFragment", "details1"]
    let root_details2FieldPath: ResponsePath = ["TestFragment", "details1", "details2"]

    let rootTypePath: LinkedList<GraphQLCompositeType> = [Interface_Animal]
    let test1TypePath: LinkedList<GraphQLCompositeType> = [Interface_Animal, Interface_Animal]
    let test2TypePath: LinkedList<GraphQLCompositeType> = [Interface_Animal, Interface_Animal, Interface_Animal]
    let test_details1TypePath: LinkedList<GraphQLCompositeType> = [Interface_Animal, Interface_Animal, Interface_Animal, Interface_Animal]
    let test_details2TypePath: LinkedList<GraphQLCompositeType> = [Interface_Animal, Interface_Animal, Interface_Animal, Interface_Animal, Interface_Animal]
    let root_details1TypePath: LinkedList<GraphQLCompositeType> = [Interface_Animal, Interface_Animal]
    let root_details2TypePath: LinkedList<GraphQLCompositeType> = [Interface_Animal, Interface_Animal, Interface_Animal]

    let expected: [ResponsePath: IR.Entity] = [
      rootFieldPath: IR.Entity(rootTypePath: rootTypePath, fieldPath: rootFieldPath),
      test1FieldPath: IR.Entity(rootTypePath: test1TypePath, fieldPath: test1FieldPath),
      test2FieldPath: IR.Entity(rootTypePath: test2TypePath, fieldPath: test2FieldPath),
      test_details1FieldPath: IR.Entity(rootTypePath: test_details1TypePath, fieldPath: test_details1FieldPath),
      test_details2FieldPath: IR.Entity(rootTypePath: test_details2TypePath, fieldPath: test_details2FieldPath),
      root_details1FieldPath: IR.Entity(rootTypePath: root_details1TypePath, fieldPath: root_details1FieldPath),
      root_details2FieldPath: IR.Entity(rootTypePath: root_details2TypePath, fieldPath: root_details2FieldPath),
    ]

    // then
    expect(self.subject.entities).to(match(expected))
  }

}

// MARK: - Custom Matchers

fileprivate func match(
  _ expectedValue: [ResponsePath: IR.Entity]
) -> Predicate<[ResponsePath: IR.Entity]> {
  return Predicate.define { actual in
    let message: ExpectationMessage = .expectedActualValueTo("equal \(expectedValue)")
    guard let actual = try actual.evaluate(),
          actual.count == expectedValue.count else {
      return PredicateResult(status: .fail, message: message)
    }

    for (expected, actual) in zip(expectedValue, actual) {
      if expected.key != actual.key ||
          expected.value.rootTypePath != actual.value.rootTypePath ||
          expected.value.fieldPath != actual.value.fieldPath {
        return PredicateResult(status: .fail, message: message)
      }
    }

    return PredicateResult(status: .matches, message: message)
  }
}
