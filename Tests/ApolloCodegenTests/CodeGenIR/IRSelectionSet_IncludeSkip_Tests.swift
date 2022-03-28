import XCTest
import Nimble
import OrderedCollections
@testable import ApolloCodegenLib
import ApolloTestSupport
import ApolloCodegenTestSupport
import ApolloAPI
import ApolloUtils

class IRSelectionSet_IncludeSkip_Tests: XCTestCase {

  var schemaSDL: String!
  var document: String!
  var ir: IR!
  var operation: CompilationResult.OperationDefinition!
  var subject: IR.EntityField!

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

  func buildSubjectRootField() throws {
    ir = try .mock(schema: schemaSDL, document: document)
    operation = try XCTUnwrap(ir.compilationResult.operations.first)

    (subject, _) = IR.RootFieldBuilder.buildRootEntityField(
      forRootField: .mock(
        "query",
        type: .nonNull(.entity(operation.rootType)),
        selectionSet: operation.selectionSet
      ),
      onRootEntity: IR.Entity(
        rootTypePath: LinkedList(operation.rootType),
        fieldPath: ResponsePath("query")
      ),
      inSchema: ir.schema
    )
  }

  // MARK: - Scalar Fields

  func test__selections__givenIncludeIfVariable_onScalarField_createsSelectionWithInclusionCondition() throws {
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
    query Test($a: Boolean!) {
      allAnimals {
        species @include(if: $a)
      }
    }
    """

    // when
    try buildSubjectRootField()

    let actual = self.subject[field: "allAnimals"]?[field: "species"]

    let expected: AnyOf<IR.InclusionConditions> = try XCTUnwrap(
      AnyOf(.mock([.include(if: "a")]))
    )

    // then
    expect(actual?.inclusionConditions).to(equal(expected))
  }

  func test__selections__givenSkipIfVariable_onScalarField_createsSelectionWithInclusionCondition() throws {
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
    query Test($a: Boolean!) {
      allAnimals {
        species @skip(if: $a)
      }
    }
    """

    // when
    try buildSubjectRootField()

    let actual = self.subject[field: "allAnimals"]?[field: "species"]

    let expected: AnyOf<IR.InclusionConditions> = try XCTUnwrap(
      AnyOf(.mock([
        .skip(if: "a")
      ]))
    )

    // then
    expect(actual?.inclusionConditions).to(equal(expected))
  }

  func test__selections__givenTwoIncludeVariables_onScalarField_createsSelectionWithBothInclusionConditions() throws {
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
    query Test($a: Boolean!, $b: Boolean!) {
      allAnimals {
        species @include(if: $a) @include(if: $b)
      }
    }
    """

    // when
    try buildSubjectRootField()

    let actual = self.subject[field: "allAnimals"]?[field: "species"]

    let expected: AnyOf<IR.InclusionConditions> = try XCTUnwrap(
      AnyOf(.mock([
        .include(if: "a"),
        .include(if: "b"),
      ]))
    )

    // then
    expect(actual?.inclusionConditions).to(equal(expected))
  }

  func test__selections__givenTwoSkipVariables_onScalarField_createsSelectionWithBothInclusionConditions() throws {
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
    query Test($a: Boolean!, $b: Boolean!) {
      allAnimals {
        species @skip(if: $a) @skip(if: $b)
      }
    }
    """

    // when
    try buildSubjectRootField()

    let actual = self.subject[field: "allAnimals"]?[field: "species"]

    let expected: AnyOf<IR.InclusionConditions> = try XCTUnwrap(
      AnyOf(.mock([
        .skip(if: "a"),
        .skip(if: "b"),
      ]))
    )

    // then
    expect(actual?.inclusionConditions).to(equal(expected))
  }

  func test__selections__givenTwoIncludeWithSameVariable_onScalarField_createsSelectionWithOneInclusionConditions() throws {
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
    query Test($a: Boolean!, $b: Boolean!) {
      allAnimals {
        species @include(if: $a) @include(if: $a)
      }
    }
    """

    // when
    try buildSubjectRootField()

    let actual = self.subject[field: "allAnimals"]?[field: "species"]

    let expected: AnyOf<IR.InclusionConditions> = try XCTUnwrap(
      AnyOf(.mock([
        .include(if: "a")
      ]))
    )

    // then
    expect(actual?.inclusionConditions).to(equal(expected))
  }

  func test__selections__givenDuplicateSelection_includeWithSameVariableFirst_onScalarField_createsSelectionWithNoInclusionConditions() throws {
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
    query Test($a: Boolean!, $b: Boolean!) {
      allAnimals {
        species @include(if: $a)
        species
      }
    }
    """

    // when
    try buildSubjectRootField()

    let actual = self.subject[field: "allAnimals"]?[field: "species"]

    // then
    expect(actual).toNot(beNil())
    expect(actual?.inclusionConditions).to(beNil())
  }

  func test__selections__givenDuplicateSelection_includeWithSameVariableSecond_onScalarField_includeFieldWithNoConditions() throws {
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
    query Test($a: Boolean!, $b: Boolean!) {
      allAnimals {
        species
        species @include(if: $a)
      }
    }
    """

    // when
    try buildSubjectRootField()

    let actual = self.subject[field: "allAnimals"]?[field: "species"]

    // then
    expect(actual).toNot(beNil())
    expect(actual?.inclusionConditions).to(beNil())
  }

  // MARK: - Omit Skipped Fields

  func test__selections__givenIncludeIfFalse_onScalarField_omitFieldFromSelectionSet() throws {
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
    query Test($a: Boolean!) {
      allAnimals {
        species @include(if: false)
      }
    }
    """

    // when
    try buildSubjectRootField()

    let allAnimals = self.subject[field: "allAnimals"]

    // then
    expect(allAnimals).toNot(beNil())
    expect(allAnimals?[field: "species"]).to(beNil())
  }

  func test__selections__givenIncludeIfTrue_onScalarField_doesNotOmitFieldFromSelectionSet() throws {
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
    query Test($a: Boolean!) {
      allAnimals {
        species @include(if: true)
      }
    }
    """

    // when
    try buildSubjectRootField()

    let actual = self.subject[field: "allAnimals"]?[field: "species"]

    // then
    expect(actual).toNot(beNil())
    expect(actual?.inclusionConditions).to(beNil())
  }

  func test__selections__givenSkipIfTrue_onScalarField_omitFieldFromSelectionSet() throws {
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
    query Test($a: Boolean!) {
      allAnimals {
        species @skip(if: true)
      }
    }
    """

    // when
    try buildSubjectRootField()

    let allAnimals = self.subject[field: "allAnimals"]

    // then
    expect(allAnimals).toNot(beNil())
    expect(allAnimals?[field: "species"]).to(beNil())
  }

  func test__selections__givenSkipIfFalse_onScalarField_doesNotOmitFieldFromSelectionSet() throws {
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
    query Test($a: Boolean!) {
      allAnimals {
        species @skip(if: false)
      }
    }
    """

    // when
    try buildSubjectRootField()

    let actual = self.subject[field: "allAnimals"]?[field: "species"]

    // then
    expect(actual).toNot(beNil())
    expect(actual?.inclusionConditions).to(beNil())
  }

  func test__selections__givenIncludeAndSkipOnSameVariable_onScalarField_omitFieldFromSelectionSet() throws {
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
    query Test($a: Boolean!) {
      allAnimals {
        species @include(if: $a) @skip(if: $a)
      }
    }
    """

    // when
    try buildSubjectRootField()

    let allAnimals = self.subject[field: "allAnimals"]

    // then
    expect(allAnimals).toNot(beNil())
    expect(allAnimals?[field: "species"]).to(beNil())
  }

  func test__selections__givenDuplicateSelectionIncludeAndSkipOnSameVariable_onScalarField_includeFieldWithConditions() throws {
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
    query Test($a: Boolean!) {
      allAnimals {
        species @include(if: $a)
        species @skip(if: $a)
      }
    }
    """

    // when
    try buildSubjectRootField()

    let actual = self.subject[field: "allAnimals"]?[field: "species"]

    let expected: AnyOf<IR.InclusionConditions> = try AnyOf([
      XCTUnwrap(.mock([.include(if: "a")])),
      XCTUnwrap(.mock([.skip(if: "a")])),
    ])

    // then
    expect(actual).toNot(beNil())
    expect(actual?.inclusionConditions).to(equal(expected))
  }

  func test__selections__givenDuplicateSelectionIncludeAndSkipOnSameVariableWithOtherInclude_onScalarField_doesNotReduceConditions() throws {
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
    query Test($a: Boolean!) {
      allAnimals {
        species @include(if: $a) @include(if: $b)
        species @skip(if: $a)
      }
    }
    """

    // when
    try buildSubjectRootField()

    let actual = self.subject[field: "allAnimals"]?[field: "species"]

    let expected: AnyOf<IR.InclusionConditions> = try AnyOf([
      XCTUnwrap(.mock([.include(if: "a"), .include(if: "b")])),
      XCTUnwrap(.mock([.skip(if: "a")])),
    ])

    // then
    expect(actual).toNot(beNil())
    expect(actual?.inclusionConditions).to(equal(expected))
  }

  // MARK: - Entity Fields

  func test__selections__givenIncludeIfVariable_onEntityField_createsSelectionWithInclusionCondition() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      friend: Animal!
    }
    """

    document = """
    query Test($a: Boolean!) {
      allAnimals {
        friend @include(if: $a) {
          species
        }
      }
    }
    """

    // when
    try buildSubjectRootField()

    let actual = self.subject[field: "allAnimals"]?[field: "friend"]

    let expected: IR.InclusionConditions = try XCTUnwrap(.mock([.include(if: "a")]))

    // then
    expect(actual?.inclusionConditions).to(equal(AnyOf(expected)))
    expect(actual?.selectionSet?.inclusionConditions).to(equal(expected))

    expect(actual?[field: "species"]).toNot(beNil())
  }

  func test__selections__givenMergingFieldWithNoConditionIntoFieldWithCondition_onEntityField_createsWrapperSelectionSet() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      a: String!
      b: String!
      friend: Animal!
    }
    """

    document = """
    query Test($a: Boolean!) {
      allAnimals {
        friend @include(if: $a) {
          a
        }
        friend {
          b
        }
      }
    }
    """

    // when
    try buildSubjectRootField()

    let Interface_Animal = try XCTUnwrap(schema[interface: "Animal"])

    let actual = self.subject[field: "allAnimals"]?[field: "friend"]

    let expected_friend_selections:
    [CompilationResult.Selection] = [
      .field(.mock("b", type: .nonNull(.scalar(.string())))),
      .inlineFragment(.mock(parentType: Interface_Animal,
                            inclusionConditions: [.include(if: "a")]))
    ]

    let expected_friendIfA_selections: [CompilationResult.Selection] = [
      .field(.mock("a", type: .nonNull(.scalar(.string())))),
    ]

    let friend_ifA_expectedConditions: IR.InclusionConditions = try XCTUnwrap(.mock([
      .include(if: "a")
    ]))

    // then
    expect(actual?.inclusionConditions).to(beNil())
    expect(actual?.selectionSet?.inclusionConditions).to(beNil())
    expect(actual?.selectionSet?.selections.direct).to(shallowlyMatch(expected_friend_selections))

    expect(actual?[if: "a"]?.inclusionConditions).to(equal(friend_ifA_expectedConditions))
    expect(actual?[if: "a"]?.selections.direct)
      .to(shallowlyMatch(expected_friendIfA_selections))
  }

  func test__selections__givenMergingFieldWithConditionIntoFieldWithNoCondition_onEntityField_createsMergedFieldAsConditionalChildSelectionSet() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      a: String!
      b: String!
      friend: Animal!
    }
    """

    document = """
    query Test($a: Boolean!) {
      allAnimals {
        friend {
          b
        }
        friend @include(if: $a) {
          a
        }
      }
    }
    """

    // when
    try buildSubjectRootField()

    let Interface_Animal = try XCTUnwrap(schema[interface: "Animal"])

    let actual = self.subject[field: "allAnimals"]?[field: "friend"]

    let expected_friend = SelectionSetMatcher.directOnly(
      parentType: Interface_Animal,
      inclusionConditions: nil,
      directSelections: [
        .field(.mock("b", type: .nonNull(.scalar(.string())))),
        .inlineFragment(.mock(parentType: Interface_Animal,
                              inclusionConditions: [.include(if: "a")]))
      ]
    )

    let expected_friendIfA = SelectionSetMatcher.directOnly(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "a")],
      directSelections: [
        .field(.mock("a", type: .nonNull(.scalar(.string())))),
      ]
    )

    // then
    expect(actual?.inclusionConditions).to(beNil())
    expect(actual?.selectionSet).to(shallowlyMatch(expected_friend))

    expect(actual?[if: "a"]).to(shallowlyMatch(expected_friendIfA))
  }

  func test__selections__givenTwoEntityFieldsIncludeIfVariableAndSkipIfSameVariable_onEntityField_createsSelectionWithInclusionConditionsWithNestedSelectionSetsWithEachInclusionCondition() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      a: String!
      b: String!
      friend: Animal!
    }
    """

    document = """
    query Test($a: Boolean!) {
      allAnimals {
        friend @include(if: $a) {
          a
        }
        friend @skip(if: $a) {
          b
        }
      }
    }
    """

    // when
    try buildSubjectRootField()

    let Interface_Animal = try XCTUnwrap(schema[interface: "Animal"])

    let actual = self.subject[field: "allAnimals"]?[field: "friend"]

    let friend_expected: AnyOf<IR.InclusionConditions> = try AnyOf([
      XCTUnwrap(.mock([.include(if: "a")])),
      XCTUnwrap(.mock([.skip(if: "a")]))
    ])

    let friend_ifA_expected = SelectionSetMatcher.directOnly(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "a")],
      directSelections: [
        .field(.mock("a", type: .nonNull(.scalar(.string())))),
      ]
    )

    let friend_ifNotA_expected = SelectionSetMatcher.directOnly(
      parentType: Interface_Animal,
      inclusionConditions: [.skip(if: "a")],
      directSelections: [
        .field(.mock("b", type: .nonNull(.scalar(.string())))),
      ]
    )

    // then
    expect(actual?.inclusionConditions).to(equal(friend_expected))
    expect(actual?.selectionSet?.inclusionConditions).to(beNil())

    expect(actual?.selectionSet?.selections.direct?.fields).to(beEmpty())    

    expect(actual?[if: "a"]).to(shallowlyMatch(friend_ifA_expected))
    expect(actual?[if: !"a"]).to(shallowlyMatch(friend_ifNotA_expected))
  }

  func test__selections__givenMergeTwoEntityFieldsWithTwoConditions_createsSelectionWithInclusionConditionsWithNestedSelectionSetsWithEachInclusionCondition() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      a: String!
      c: String!
      friend: Animal!
    }
    """

    document = """
    query Test($a: Boolean!) {
      allAnimals {
        friend @include(if: $a) @include(if: $b) {
          a
        }
        friend @include(if: $c) @include(if: $d) {
          c
        }
      }
    }
    """

    // when
    try buildSubjectRootField()

    let Interface_Animal = try XCTUnwrap(schema[interface: "Animal"])

    let actual = self.subject[field: "allAnimals"]?[field: "friend"]

    let friend_expected: AnyOf<IR.InclusionConditions> = try AnyOf([
      XCTUnwrap(.mock([
        .include(if: "a"),
        .include(if: "b"),
      ])),
      XCTUnwrap(.mock([
        .include(if: "c"),
        .include(if: "d"),
      ]))
    ])

    let friend_ifAAndB_expected = SelectionSetMatcher.directOnly(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "a"), .include(if: "b")],
      directSelections: [
        .field(.mock("a", type: .nonNull(.scalar(.string())))),
      ]
    )

    let friend_ifCAndD_expected = SelectionSetMatcher.directOnly(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "c"), .include(if: "d"),],
      directSelections: [
        .field(.mock("c", type: .nonNull(.scalar(.string())))),
      ]
    )

    // then
    expect(actual?.inclusionConditions).to(equal(friend_expected))
    expect(actual?.selectionSet?.inclusionConditions).to(beNil())

    expect(actual?.selectionSet?.selections.direct?.fields).to(beEmpty())

    expect(actual?[if: "a" && "b"]).to(shallowlyMatch(friend_ifAAndB_expected))
    expect(actual?[if: "c" && "d"]).to(shallowlyMatch(friend_ifCAndD_expected))
  }

  func test__selections__givenMergeThreeFieldsWithConditions_onEntityField_createsSelectionWithInclusionConditionsWithNestedSelectionSetsWithEachInclusionCondition() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      a: String!
      b: String!
      c: String!
      friend: Animal!
    }
    """

    document = """
    query Test($a: Boolean!) {
      allAnimals {
        friend @include(if: $a) {
          a
        }
        friend @skip(if: $b) {
          b
        }
        friend @include(if: $c) {
          c
        }
      }
    }
    """

    // when
    try buildSubjectRootField()

    let Interface_Animal = try XCTUnwrap(schema[interface: "Animal"])

    let actual = self.subject[field: "allAnimals"]?[field: "friend"]

    let friend_expected: AnyOf<IR.InclusionConditions> = try AnyOf([
      XCTUnwrap(.mock([.include(if: "a")])),
      XCTUnwrap(.mock([.skip(if: "b")])),
      XCTUnwrap(.mock([.include(if: "c")])),
    ])

    let friend_ifA_expected = SelectionSetMatcher.directOnly(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "a")],
      directSelections: [
        .field(.mock("a", type: .nonNull(.scalar(.string())))),
      ]
    )

    let friend_ifNotB_expected = SelectionSetMatcher.directOnly(
      parentType: Interface_Animal,
      inclusionConditions: [.skip(if: "b")],
      directSelections: [
        .field(.mock("b", type: .nonNull(.scalar(.string())))),
      ]
    )

    let friend_ifC_expected = SelectionSetMatcher.directOnly(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "c")],
      directSelections: [
        .field(.mock("c", type: .nonNull(.scalar(.string())))),
      ]
    )

    // then
    expect(actual?.inclusionConditions).to(equal(friend_expected))
    expect(actual?.selectionSet?.inclusionConditions).to(beNil())

    expect(actual?.selectionSet?.selections.direct?.fields).to(beEmpty())

    expect(actual?[if: "a"]).to(shallowlyMatch(friend_ifA_expected))
    expect(actual?[if: !"b"]).to(shallowlyMatch(friend_ifNotB_expected))
    expect(actual?[if: "c"]).to(shallowlyMatch(friend_ifC_expected))
  }

  func test__selections__givenMergingFieldWithIncludeIfTrueIntoFieldWithNoCondition_onEntityField_mergesSelectionsDirectly() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      a: String!
      b: String!
      friend: Animal!
    }
    """

    document = """
    query Test {
      allAnimals {
        friend {
          b
        }
        friend @include(if: true) {
          a
        }
      }
    }
    """

    // when
    try buildSubjectRootField()

    let Interface_Animal = try XCTUnwrap(schema[interface: "Animal"])

    let actual = self.subject[field: "allAnimals"]?[field: "friend"]

    let expected_friend = SelectionSetMatcher.directOnly(
      parentType: Interface_Animal,
      inclusionConditions: nil,
      directSelections: [
        .field(.mock("b", type: .nonNull(.scalar(.string())))),
        .field(.mock("a", type: .nonNull(.scalar(.string())))),
      ]
    )

    // then
    expect(actual?.inclusionConditions).to(beNil())
    expect(actual?.selectionSet).to(shallowlyMatch(expected_friend))
  }

  func test__selections__givenMergingFieldWithConditionIntoFieldWithIncludeIfTrue_onEntityField_createsMergedFieldAsConditionalChildSelectionSet() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      a: String!
      b: String!
      friend: Animal!
    }
    """

    document = """
    query Test($a: Boolean!) {
      allAnimals {
        friend @include(if: true) {
          b
        }
        friend @include(if: $a) {
          a
        }
      }
    }
    """

    // when
    try buildSubjectRootField()

    let Interface_Animal = try XCTUnwrap(schema[interface: "Animal"])

    let actual = self.subject[field: "allAnimals"]?[field: "friend"]

    let expected_friend = SelectionSetMatcher.directOnly(
      parentType: Interface_Animal,
      inclusionConditions: nil,
      directSelections: [
        .field(.mock("b", type: .nonNull(.scalar(.string())))),
        .inlineFragment(.mock(parentType: Interface_Animal,
                              inclusionConditions: [.include(if: "a")]))
      ]
    )

    let expected_friendIfA = SelectionSetMatcher.directOnly(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "a")],
      directSelections: [
        .field(.mock("a", type: .nonNull(.scalar(.string())))),
      ]
    )

    // then
    expect(actual?.inclusionConditions).to(beNil())
    expect(actual?.selectionSet).to(shallowlyMatch(expected_friend))

    expect(actual?[if: "a"]).to(shallowlyMatch(expected_friendIfA))
  }

  // MARK: - Inline Fragments

  func test__selections__givenIncludeIfVariable_onInlineFragment_createsSelectionWithInclusionCondition() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      friend: Animal!
    }
    """

    document = """
    query Test($a: Boolean!) {
      allAnimals {
        ... @include(if: $a) {
          species
        }
      }
    }
    """

    // when
    try buildSubjectRootField()

    let Interface_Animal = try XCTUnwrap(schema[interface: "Animal"])

    let allAnimals = self.subject[field: "allAnimals"]

    let expected_allAnimal = SelectionSetMatcher.directOnly(
      parentType: Interface_Animal,
      inclusionConditions: nil,
      directSelections: [
        .inlineFragment(.mock(parentType: Interface_Animal,
                              inclusionConditions: [.include(if: "a")]))
      ]
    )

    let expected_allAnimal_ifA = SelectionSetMatcher.directOnly(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "a")],
      directSelections: [
        .field(.mock("species", type: .nonNull(.scalar(.string())))),
      ]
    )

    // then
    expect(allAnimals?.inclusionConditions).to(beNil())
    expect(allAnimals?.selectionSet).to(shallowlyMatch(expected_allAnimal))

    expect(allAnimals?[if: "a"]).to(shallowlyMatch(expected_allAnimal_ifA))
  }

  func test__selections__givenDuplicateConditions_onInlineFragments_deduplicatesSelectionSet() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      a: String!
      b: String!
    }
    """

    document = """
    query Test($a: Boolean!) {
      allAnimals {
        ... @include(if: $a) {
          a
        }
        ... @include(if: $a) {
          b
        }
      }
    }
    """

    // when
    try buildSubjectRootField()

    let Interface_Animal = try XCTUnwrap(schema[interface: "Animal"])

    let allAnimals = self.subject[field: "allAnimals"]

    let expected_allAnimal = SelectionSetMatcher.directOnly(
      parentType: Interface_Animal,
      inclusionConditions: nil,
      directSelections: [
        .inlineFragment(.mock(parentType: Interface_Animal,
                              inclusionConditions: [.include(if: "a")])),
      ]
    )

    let expected_allAnimal_ifA = SelectionSetMatcher.directOnly(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "a")],
      directSelections: [
        .field(.mock("a", type: .nonNull(.scalar(.string())))),
        .field(.mock("b", type: .nonNull(.scalar(.string())))),
      ]
    )

    // then
    expect(allAnimals?.inclusionConditions).to(beNil())
    expect(allAnimals?.selectionSet).to(shallowlyMatch(expected_allAnimal))

    expect(allAnimals?[if: "a"]).to(shallowlyMatch(expected_allAnimal_ifA))
  }

  func test__selections__givenConditionThatIsSupersetOfOtherCondition_onInlineFragments_createsSeperateSelectionsWithInclusionConditions() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      a: String!
      b: String!
    }
    """

    document = """
    query Test($a: Boolean!) {
      allAnimals {
        ... @include(if: $a) {
          a
        }
        ... @include(if: $a) @include(if: $b) {
          b
        }
      }
    }
    """

    // when
    try buildSubjectRootField()

    let Interface_Animal = try XCTUnwrap(schema[interface: "Animal"])

    let allAnimals = self.subject[field: "allAnimals"]

    let expected_allAnimal = SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: nil,
      directSelections: [
        .inlineFragment(.mock(parentType: Interface_Animal,
                              inclusionConditions: [.include(if: "a")])),
        .inlineFragment(.mock(parentType: Interface_Animal,
                              inclusionConditions: [.include(if: "a"), .include(if: "b")]))
      ],
      mergedSelections: [],
      mergedSources: []
    )

    let expected_allAnimal_ifA = SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "a")],
      directSelections: [
        .field(.mock("a", type: .nonNull(.scalar(.string())))),
      ],
      mergedSelections: [],
      mergedSources: []
    )

    let expected_allAnimal_ifAAndB = try SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "a"), .include(if: "b")],
      directSelections: [
        .field(.mock("b", type: .nonNull(.scalar(.string())))),
      ],
      mergedSelections: [
        .field(.mock("a", type: .nonNull(.scalar(.string())))),
      ],
      mergedSources: [
        .mock(allAnimals?[if: "a"])
      ]
    )

    // then
    expect(allAnimals?.inclusionConditions).to(beNil())
    expect(allAnimals?.selectionSet).to(shallowlyMatch(expected_allAnimal))

    expect(allAnimals?[if: "a"]).to(shallowlyMatch(expected_allAnimal_ifA))
    expect(allAnimals?[if: "a" && "b"]).to(shallowlyMatch(expected_allAnimal_ifAAndB))
  }

  func test__selections__givenConditionNotMatchingOtherCondition_onInlineFragments_doesNotMergeInSelections() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      a: String!
      b: String!
    }
    """

    document = """
    query Test($a: Boolean!) {
      allAnimals {
        ... @include(if: $a) {
          a
        }
        ... @include(if: $b) {
          b
        }
      }
    }
    """

    // when
    try buildSubjectRootField()

    let Interface_Animal = try XCTUnwrap(schema[interface: "Animal"])

    let allAnimals = self.subject[field: "allAnimals"]

    let expected_allAnimal = SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: nil,
      directSelections: [
        .inlineFragment(.mock(parentType: Interface_Animal,
                              inclusionConditions: [.include(if: "a")])),
        .inlineFragment(.mock(parentType: Interface_Animal,
                              inclusionConditions: [.include(if: "b")]))
      ],
      mergedSelections: [],
      mergedSources: []
    )

    let expected_allAnimal_ifA = SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "a")],
      directSelections: [
        .field(.mock("a", type: .nonNull(.scalar(.string())))),
      ],
      mergedSelections: [],
      mergedSources: []
    )

    let expected_allAnimal_ifB = SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "b")],
      directSelections: [
        .field(.mock("b", type: .nonNull(.scalar(.string())))),
      ],
      mergedSelections: [],
      mergedSources: []
    )

    // then
    expect(allAnimals?.inclusionConditions).to(beNil())
    expect(allAnimals?.selectionSet).to(shallowlyMatch(expected_allAnimal))

    expect(allAnimals?[if: "a"]).to(shallowlyMatch(expected_allAnimal_ifA))
    expect(allAnimals?[if: "b"]).to(shallowlyMatch(expected_allAnimal_ifB))
  }

  func test__selections__givenDuplicateConditionsNestedInsideOtherCondition_onInlineFragments_hasNestedConditionalSelectionSets() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      a: String!
      b1: String!
      b2: String!
    }
    """

    document = """
    query Test($a: Boolean!) {
      allAnimals {
        ... @include(if: $a) {
          a
          ... @include(if: $b) {
            b2
          }
        }
        ... @include(if: $b) {
          b1
        }
      }
    }
    """

    // when
    try buildSubjectRootField()

    let Interface_Animal = try XCTUnwrap(schema[interface: "Animal"])

    let allAnimals = self.subject[field: "allAnimals"]

    let expected_allAnimal = SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: nil,
      directSelections: [
        .inlineFragment(.mock(parentType: Interface_Animal,
                              inclusionConditions: [.include(if: "a")])),
        .inlineFragment(.mock(parentType: Interface_Animal,
                              inclusionConditions: [.include(if: "b")])),
      ],
      mergedSelections: [],
      mergedSources: []
    )

    let expected_allAnimal_ifA = SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "a")],
      directSelections: [
        .field(.mock("a", type: .nonNull(.scalar(.string())))),
        .inlineFragment(.mock(parentType: Interface_Animal,
                              inclusionConditions: [.include(if: "b")])),
      ],
      mergedSelections: [],
      mergedSources: []
    )

    let expected_allAnimal_ifB = SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "b")],
      directSelections: [
        .field(.mock("b1", type: .nonNull(.scalar(.string())))),
      ],
      mergedSelections: [],
      mergedSources: []
    )

    let expected_allAnimal_ifA_ifB = try SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "b")],
      directSelections: [
        .field(.mock("b2", type: .nonNull(.scalar(.string())))),
      ],
      mergedSelections: [
        .field(.mock("a", type: .nonNull(.scalar(.string())))),
        .field(.mock("b1", type: .nonNull(.scalar(.string())))),
      ],
      mergedSources: [
        .mock(allAnimals?[if: "a"]),
        .mock(allAnimals?[if: "b"])
      ]
    )

    // then
    expect(allAnimals?.inclusionConditions).to(beNil())
    expect(allAnimals?.selectionSet).to(shallowlyMatch(expected_allAnimal))

    expect(allAnimals?[if: "a"]).to(shallowlyMatch(expected_allAnimal_ifA))
    expect(allAnimals?[if: "a"]?[if: "b"]).to(shallowlyMatch(expected_allAnimal_ifA_ifB))
    expect(allAnimals?[if: "b"]).to(shallowlyMatch(expected_allAnimal_ifB))
  }

  func test__selections__givenConditionNotMatchingNestedCondition_onInlineFragments_doesNotMergeSelections() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      a: String!
      b: String!
      c: String!
    }
    """

    document = """
    query Test($a: Boolean!) {
      allAnimals {
        ... @include(if: $a) {
          a
          ... @include(if: $b) {
            b
          }
        }
        ... @include(if: $c) {
          c
        }
      }
    }
    """

    // when
    try buildSubjectRootField()

    let Interface_Animal = try XCTUnwrap(schema[interface: "Animal"])

    let allAnimals = self.subject[field: "allAnimals"]

    let expected_allAnimal = SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: nil,
      directSelections: [
        .inlineFragment(.mock(parentType: Interface_Animal,
                              inclusionConditions: [.include(if: "a")])),
        .inlineFragment(.mock(parentType: Interface_Animal,
                              inclusionConditions: [.include(if: "c")])),
      ],
      mergedSelections: [],
      mergedSources: []
    )

    let expected_allAnimal_ifA = SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "a")],
      directSelections: [
        .field(.mock("a", type: .nonNull(.scalar(.string())))),
        .inlineFragment(.mock(parentType: Interface_Animal,
                              inclusionConditions: [.include(if: "b")])),
      ],
      mergedSelections: [],
      mergedSources: []
    )

    let expected_allAnimal_ifC = SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "c")],
      directSelections: [
        .field(.mock("c", type: .nonNull(.scalar(.string())))),
      ],
      mergedSelections: [],
      mergedSources: []
    )

    let expected_allAnimal_ifA_ifB = try SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "b")],
      directSelections: [
        .field(.mock("b", type: .nonNull(.scalar(.string())))),
      ],
      mergedSelections: [
        .field(.mock("a", type: .nonNull(.scalar(.string())))),
      ],
      mergedSources: [
        .mock(allAnimals?[if: "a"]),
      ]
    )

    // then
    expect(allAnimals?.inclusionConditions).to(beNil())
    expect(allAnimals?.selectionSet).to(shallowlyMatch(expected_allAnimal))

    expect(allAnimals?[if: "a"]).to(shallowlyMatch(expected_allAnimal_ifA))
    expect(allAnimals?[if: "a"]?[if: "b"]).to(shallowlyMatch(expected_allAnimal_ifA_ifB))
    expect(allAnimals?[if: "c"]).to(shallowlyMatch(expected_allAnimal_ifC))
  }


  func test__selections__givenSiblingTypeCaseAndCondition_onInlineFragments_doesNotMergeSiblings() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      a: String!
      b: String!
    }

    interface Pet implements Animal {
      a: String!
      b: String!
    }
    """

    document = """
    query Test($b: Boolean!) {
      allAnimals {
        ... on Pet {
          a
        }
        ... @include(if: $b) {
          b
        }
      }
    }
    """

    // when
    try buildSubjectRootField()

    let Interface_Animal = try XCTUnwrap(schema[interface: "Animal"])
    let Interface_Pet = try XCTUnwrap(schema[interface: "Pet"])

    let allAnimals = self.subject[field: "allAnimals"]

    let expected_allAnimal = SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: nil,
      directSelections: [
        .inlineFragment(.mock(parentType: Interface_Pet,
                              inclusionConditions: nil)),
        .inlineFragment(.mock(parentType: Interface_Animal,
                              inclusionConditions: [.include(if: "b")]))
      ],
      mergedSelections: [],
      mergedSources: []
    )

    let expected_allAnimal_asPet = SelectionSetMatcher(
      parentType: Interface_Pet,
      inclusionConditions: nil,
      directSelections: [
        .field(.mock("a", type: .nonNull(.scalar(.string())))),
      ],
      mergedSelections: [],
      mergedSources: []
    )

    let expected_allAnimal_ifB = SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "b")],
      directSelections: [
        .field(.mock("b", type: .nonNull(.scalar(.string())))),
      ],
      mergedSelections: [],
      mergedSources: []
    )

    // then
    expect(allAnimals?.inclusionConditions).to(beNil())
    expect(allAnimals?.selectionSet).to(shallowlyMatch(expected_allAnimal))

    expect(allAnimals?[as: "Pet"]).to(shallowlyMatch(expected_allAnimal_asPet))
    expect(allAnimals?[if: "b"]).to(shallowlyMatch(expected_allAnimal_ifB))
  }

  func test__selections__givenTypeCaseAndCondition_siblingWithMatchingCondition_onInlineFragments_mergesConditionSelections() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      a: String!
      b: String!
    }

    interface Pet implements Animal {
      a: String!
      b: String!
    }
    """

    document = """
    query Test($b: Boolean!) {
      allAnimals {
        ... on Pet @include(if: $b) {
          a
        }
        ... @include(if: $b) {
          b
        }
      }
    }
    """

    // when
    try buildSubjectRootField()

    let Interface_Animal = try XCTUnwrap(schema[interface: "Animal"])
    let Interface_Pet = try XCTUnwrap(schema[interface: "Pet"])

    let allAnimals = self.subject[field: "allAnimals"]

    let expected_allAnimal = SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: nil,
      directSelections: [
        .inlineFragment(.mock(parentType: Interface_Pet,
                              inclusionConditions: [.include(if: "b")])),
        .inlineFragment(.mock(parentType: Interface_Animal,
                              inclusionConditions: [.include(if: "b")]))
      ],
      mergedSelections: [],
      mergedSources: []
    )

    let expected_allAnimal_asPet = try SelectionSetMatcher(
      parentType: Interface_Pet,
      inclusionConditions: [.include(if: "b")],
      directSelections: [
        .field(.mock("a", type: .nonNull(.scalar(.string())))),
      ],
      mergedSelections: [
        .field(.mock("b", type: .nonNull(.scalar(.string())))),
      ],
      mergedSources: [
        .mock(allAnimals?[if: "b"])
      ]
    )

    let expected_allAnimal_ifB = SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "b")],
      directSelections: [
        .field(.mock("b", type: .nonNull(.scalar(.string())))),
      ],
      mergedSelections: [],
      mergedSources: []
    )

    // then
    expect(allAnimals?.inclusionConditions).to(beNil())
    expect(allAnimals?.selectionSet).to(shallowlyMatch(expected_allAnimal))

    expect(allAnimals?[as: "Pet", if: "b"]).to(shallowlyMatch(expected_allAnimal_asPet))
    expect(allAnimals?[if: "b"]).to(shallowlyMatch(expected_allAnimal_ifB))
  }

  func test__selections__givenTypeCaseAndCondition_siblingWithNonMatchingCondition_onInlineFragments_doesNotMergesConditionSelections() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      a: String!
      b: String!
    }

    interface Pet implements Animal {
      a: String!
      b: String!
    }
    """

    document = """
    query Test($b: Boolean!) {
      allAnimals {
        ... on Pet @include(if: $a) {
          a
        }
        ... @include(if: $b) {
          b
        }
      }
    }
    """

    // when
    try buildSubjectRootField()

    let Interface_Animal = try XCTUnwrap(schema[interface: "Animal"])
    let Interface_Pet = try XCTUnwrap(schema[interface: "Pet"])

    let allAnimals = self.subject[field: "allAnimals"]

    let expected_allAnimal = SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: nil,
      directSelections: [
        .inlineFragment(.mock(parentType: Interface_Pet,
                              inclusionConditions: [.include(if: "a")])),
        .inlineFragment(.mock(parentType: Interface_Animal,
                              inclusionConditions: [.include(if: "b")]))
      ],
      mergedSelections: [],
      mergedSources: []
    )

    let expected_allAnimal_asPet = SelectionSetMatcher(
      parentType: Interface_Pet,
      inclusionConditions: [.include(if: "a")],
      directSelections: [
        .field(.mock("a", type: .nonNull(.scalar(.string())))),
      ],
      mergedSelections: [],
      mergedSources: []
    )

    let expected_allAnimal_ifB = SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "b")],
      directSelections: [
        .field(.mock("b", type: .nonNull(.scalar(.string())))),
      ],
      mergedSelections: [],
      mergedSources: []
    )

    // then
    expect(allAnimals?.inclusionConditions).to(beNil())
    expect(allAnimals?.selectionSet).to(shallowlyMatch(expected_allAnimal))

    expect(allAnimals?[as: "Pet", if: "a"]).to(shallowlyMatch(expected_allAnimal_asPet))
    expect(allAnimals?[if: "b"]).to(shallowlyMatch(expected_allAnimal_ifB))
  }

  // MARK: - Named Fragments

   func test__selections__givenIncludeIfVariable_onNamedFragment_createsSelectionWithInclusionCondition() throws {
     // given
     schemaSDL = """
     type Query {
       allAnimals: [Animal!]
     }

     interface Animal {
       a: String!
       friend: Animal!
     }
     """

     document = """
     query Test($a: Boolean!) {
       allAnimals {
         ...FragmentA @include(if: $a)
       }
     }

     fragment FragmentA on Animal {
       a
     }
     """

     // when
     try buildSubjectRootField()

     let Interface_Animal = try XCTUnwrap(schema[interface: "Animal"])
     let FragmentA = try XCTUnwrap(ir.compilationResult[fragment: "FragmentA"])

     let allAnimals = self.subject[field: "allAnimals"]

     let expected_allAnimal = try SelectionSetMatcher(
       parentType: Interface_Animal,
       inclusionConditions: nil,
       directSelections: [
         .fragmentSpread(FragmentA, inclusionConditions: [.include(if: "a")]),
       ],
       mergedSelections: [
        .inlineFragment(.mock(parentType: Interface_Animal,
                              inclusionConditions: [.include(if: "a")])),
       ],
       mergedSources: [
        .mock(allAnimals?[if: "a"])
       ]
     )

     let expected_allAnimal_ifA = try SelectionSetMatcher(
       parentType: Interface_Animal,
       inclusionConditions: [.include(if: "a")],
       directSelections: [],
       mergedSelections: [
        .field(.mock("a", type: .nonNull(.scalar(.string())))),
        .fragmentSpread(FragmentA, inclusionConditions: nil),
       ],
       mergedSources: [
        .mock(allAnimals?[if: "a"]?[fragment: "FragmentA"])
       ]
     )

     // then
     expect(allAnimals?.inclusionConditions).to(beNil())
     expect(allAnimals?.selectionSet).to(shallowlyMatch(expected_allAnimal))

     expect(allAnimals?[if: "a"]).to(shallowlyMatch(expected_allAnimal_ifA))
   }

}
