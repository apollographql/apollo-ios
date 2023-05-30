import XCTest
import Nimble
import OrderedCollections
@testable import ApolloCodegenLib
import ApolloInternalTestHelpers
import ApolloCodegenInternalTestHelpers
import ApolloAPI

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
    expect(self.subject.rootField.selectionSet.entity.location)
      .to(equal(.init(source: .namedFragment(self.subject.definition), fieldPath: nil)))
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

    let field_root = subject.rootField
    let field_test1 = try field_root[field: "test1"].xctUnwrapped()
    let field_test1_test2 = try field_test1[field: "test2"].xctUnwrapped()

    let field_test1_test2_details1 = try field_test1_test2[field: "details1"].xctUnwrapped()
    let field_test1_test2_details1_details2 = try field_test1_test2_details1[field: "details2"].xctUnwrapped()

    let field_root_details1 = try field_root[field: "details1"].xctUnwrapped()
    let field_root_details1_details2 = try field_root_details1[field: "details2"].xctUnwrapped()

    let rootFieldLocation: IR.Entity.Location = .init(
      source: .namedFragment(subject.definition),
      fieldPath: nil
    )
    let test1FieldLocation: IR.Entity.Location = rootFieldLocation + .init(field_test1.underlyingField)
    let test2FieldLocation: IR.Entity.Location = test1FieldLocation + .init(field_test1_test2.underlyingField)
    let test_details1FieldLocation: IR.Entity.Location =
    test2FieldLocation + .init(field_test1_test2_details1.underlyingField)
    let test_details2FieldLocation: IR.Entity.Location =
    test_details1FieldLocation + .init(field_test1_test2_details1_details2.underlyingField)
    let root_details1FieldLocation: IR.Entity.Location =
    rootFieldLocation + .init(field_root_details1.underlyingField)
    let root_details2FieldLocation: IR.Entity.Location =
    root_details1FieldLocation + .init(field_root_details1_details2.underlyingField)

    let rootTypePath: LinkedList<GraphQLCompositeType> = [Interface_Animal]
    let test1TypePath: LinkedList<GraphQLCompositeType> = [Interface_Animal, Interface_Animal]
    let test2TypePath: LinkedList<GraphQLCompositeType> = [Interface_Animal, Interface_Animal, Interface_Animal]
    let test_details1TypePath: LinkedList<GraphQLCompositeType> = [Interface_Animal, Interface_Animal, Interface_Animal, Interface_Animal]
    let test_details2TypePath: LinkedList<GraphQLCompositeType> = [Interface_Animal, Interface_Animal, Interface_Animal, Interface_Animal, Interface_Animal]
    let root_details1TypePath: LinkedList<GraphQLCompositeType> = [Interface_Animal, Interface_Animal]
    let root_details2TypePath: LinkedList<GraphQLCompositeType> = [Interface_Animal, Interface_Animal, Interface_Animal]

    let expected: [IR.Entity.Location: IR.Entity] = [
      rootFieldLocation: IR.Entity(location: rootFieldLocation, rootTypePath: rootTypePath),
      test1FieldLocation: IR.Entity(location: test1FieldLocation, rootTypePath: test1TypePath),
      test2FieldLocation: IR.Entity(location: test2FieldLocation, rootTypePath: test2TypePath),
      test_details1FieldLocation: IR.Entity(location: test_details1FieldLocation, rootTypePath: test_details1TypePath),
      test_details2FieldLocation: IR.Entity(location: test_details2FieldLocation, rootTypePath: test_details2TypePath),
      root_details1FieldLocation: IR.Entity(location: root_details1FieldLocation, rootTypePath: root_details1TypePath),
      root_details2FieldLocation: IR.Entity(location: root_details2FieldLocation, rootTypePath: root_details2TypePath),
    ]

    // then
    expect(self.subject.entities).to(match(expected))
  }

}

// MARK: - Helpers

extension IR.Entity.Location.FieldComponent {
  init(_ field: CompilationResult.Field) {
    self.init(name: field.responseKey, type: field.type)    
  }
}

// MARK: - Custom Matchers

fileprivate func match(
  _ expectedValue: [IR.Entity.Location: IR.Entity]
) -> Predicate<[IR.Entity.Location: IR.Entity]> {
  return Predicate.define { actual in
    let message: ExpectationMessage = .expectedActualValueTo("equal \(expectedValue)")
    guard var actual = try actual.evaluate(),
          actual.count == expectedValue.count else {
      return PredicateResult(status: .fail, message: message)
    }

    for expected in expectedValue {
      guard let actual = actual.removeValue(forKey: expected.key) else {
        return PredicateResult(status: .fail, message: message)
      }

      if expected.value.rootTypePath != actual.rootTypePath ||
          expected.value.location != actual.location {
        return PredicateResult(status: .fail, message: message)
      }
    }

    guard actual.isEmpty else {
      return PredicateResult(status: .fail, message: message)
    }

    return PredicateResult(status: .matches, message: message)
  }
}
