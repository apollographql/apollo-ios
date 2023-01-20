import XCTest
import Nimble
import OrderedCollections
@testable import ApolloCodegenLib
import ApolloInternalTestHelpers
import ApolloCodegenInternalTestHelpers
import ApolloAPI

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

    let result = IR.RootFieldBuilder.buildRootEntityField(
      forRootField: .mock(
        "query",
        type: .nonNull(.entity(operation.rootType)),
        selectionSet: operation.selectionSet
      ),
      onRootEntity: IR.Entity(
        rootTypePath: LinkedList(operation.rootType),
        fieldPath: [.init(name: "query", type: .nonNull(.entity(operation.rootType)))]
      ),
      inIR: ir
    )
    subject = result.rootField
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
    [ShallowSelectionMatcher] = [
      .field("b", type: .nonNull(.scalar(.string()))),
      .inlineFragment(parentType: Interface_Animal,
                      inclusionConditions: [.include(if: "a")])
    ]

    let expected_friendIfA_selections: [ShallowSelectionMatcher] = [
      .field("a", type: .nonNull(.scalar(.string()))),
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
        .field("b", type: .nonNull(.scalar(.string()))),
        .inlineFragment(parentType: Interface_Animal,
                              inclusionConditions: [.include(if: "a")])
      ]
    )

    let expected_friendIfA = SelectionSetMatcher.directOnly(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "a")],
      directSelections: [
        .field("a", type: .nonNull(.scalar(.string()))),
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
        .field("a", type: .nonNull(.scalar(.string()))),
      ]
    )

    let friend_ifNotA_expected = SelectionSetMatcher.directOnly(
      parentType: Interface_Animal,
      inclusionConditions: [.skip(if: "a")],
      directSelections: [
        .field("b", type: .nonNull(.scalar(.string()))),
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
        .field("a", type: .nonNull(.scalar(.string()))),
      ]
    )

    let friend_ifCAndD_expected = SelectionSetMatcher.directOnly(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "c"), .include(if: "d"),],
      directSelections: [
        .field("c", type: .nonNull(.scalar(.string()))),
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
        .field("a", type: .nonNull(.scalar(.string()))),
      ]
    )

    let friend_ifNotB_expected = SelectionSetMatcher.directOnly(
      parentType: Interface_Animal,
      inclusionConditions: [.skip(if: "b")],
      directSelections: [
        .field("b", type: .nonNull(.scalar(.string()))),
      ]
    )

    let friend_ifC_expected = SelectionSetMatcher.directOnly(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "c")],
      directSelections: [
        .field("c", type: .nonNull(.scalar(.string()))),
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
        .field("b", type: .nonNull(.scalar(.string()))),
        .field("a", type: .nonNull(.scalar(.string()))),
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
        .field("b", type: .nonNull(.scalar(.string()))),
        .inlineFragment(parentType: Interface_Animal,
                              inclusionConditions: [.include(if: "a")])
      ]
    )

    let expected_friendIfA = SelectionSetMatcher.directOnly(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "a")],
      directSelections: [
        .field("a", type: .nonNull(.scalar(.string()))),
      ]
    )

    // then
    expect(actual?.inclusionConditions).to(beNil())
    expect(actual?.selectionSet).to(shallowlyMatch(expected_friend))

    expect(actual?[if: "a"]).to(shallowlyMatch(expected_friendIfA))
  }

  // MARK: Merged Fields

  func test__selections__givenIncludeIfVariable_onEntityField_mergedFromParent_createsMergedSelectionWithInclusionCondition() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
      friend: Animal!
    }

    interface Pet {
      species: String!
    }
    """

    document = """
    query Test($a: Boolean!) {
      allAnimals {
        friend @include(if: $a) {
          species
        }
        ... on Pet {
          species
        }
      }
    }
    """

    // when
    try buildSubjectRootField()

    let actual = self.subject[field: "allAnimals"]?[as: "Pet"]?[field: "friend"]

    let expected: IR.InclusionConditions = try XCTUnwrap(.mock([.include(if: "a")]))

    // then
    expect(actual?.inclusionConditions).to(equal(AnyOf(expected)))
    expect(actual?.selectionSet?.inclusionConditions).to(equal(expected))

    expect(actual?[field: "species"]).toNot(beNil())
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
        .inlineFragment(parentType: Interface_Animal,
                              inclusionConditions: [.include(if: "a")])
      ]
    )

    let expected_allAnimal_ifA = SelectionSetMatcher.directOnly(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "a")],
      directSelections: [
        .field("species", type: .nonNull(.scalar(.string()))),
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
        .inlineFragment(parentType: Interface_Animal,
                              inclusionConditions: [.include(if: "a")]),
      ]
    )

    let expected_allAnimal_ifA = SelectionSetMatcher.directOnly(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "a")],
      directSelections: [
        .field("a", type: .nonNull(.scalar(.string()))),
        .field("b", type: .nonNull(.scalar(.string()))),
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
        .inlineFragment(parentType: Interface_Animal,
                              inclusionConditions: [.include(if: "a")]),
        .inlineFragment(parentType: Interface_Animal,
                              inclusionConditions: [.include(if: "a"), .include(if: "b")])
      ],
      mergedSelections: [],
      mergedSources: []
    )

    let expected_allAnimal_ifA = SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "a")],
      directSelections: [
        .field("a", type: .nonNull(.scalar(.string()))),
      ],
      mergedSelections: [],
      mergedSources: []
    )

    let expected_allAnimal_ifAAndB = try SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "a"), .include(if: "b")],
      directSelections: [
        .field("b", type: .nonNull(.scalar(.string()))),
      ],
      mergedSelections: [
        .field("a", type: .nonNull(.scalar(.string()))),
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
        .inlineFragment(parentType: Interface_Animal,
                        inclusionConditions: [.include(if: "a")]),
        .inlineFragment(parentType: Interface_Animal,
                        inclusionConditions: [.include(if: "b")])
      ],
      mergedSelections: [],
      mergedSources: []
    )

    let expected_allAnimal_ifA = SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "a")],
      directSelections: [
        .field("a", type: .nonNull(.scalar(.string()))),
      ],
      mergedSelections: [],
      mergedSources: []
    )

    let expected_allAnimal_ifB = SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "b")],
      directSelections: [
        .field("b", type: .nonNull(.scalar(.string()))),
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
        .inlineFragment(parentType: Interface_Animal,
                              inclusionConditions: [.include(if: "a")]),
        .inlineFragment(parentType: Interface_Animal,
                              inclusionConditions: [.include(if: "b")]),
      ],
      mergedSelections: [],
      mergedSources: []
    )

    let expected_allAnimal_ifA = SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "a")],
      directSelections: [
        .field("a", type: .nonNull(.scalar(.string()))),
        .inlineFragment(parentType: Interface_Animal,
                              inclusionConditions: [.include(if: "b")]),
      ],
      mergedSelections: [],
      mergedSources: []
    )

    let expected_allAnimal_ifB = SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "b")],
      directSelections: [
        .field("b1", type: .nonNull(.scalar(.string()))),
      ],
      mergedSelections: [],
      mergedSources: []
    )

    let expected_allAnimal_ifA_ifB = try SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "b")],
      directSelections: [
        .field("b2", type: .nonNull(.scalar(.string()))),
      ],
      mergedSelections: [
        .field("a", type: .nonNull(.scalar(.string()))),
        .field("b1", type: .nonNull(.scalar(.string()))),
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
        .inlineFragment(parentType: Interface_Animal,
                              inclusionConditions: [.include(if: "a")]),
        .inlineFragment(parentType: Interface_Animal,
                              inclusionConditions: [.include(if: "c")]),
      ],
      mergedSelections: [],
      mergedSources: []
    )

    let expected_allAnimal_ifA = SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "a")],
      directSelections: [
        .field("a", type: .nonNull(.scalar(.string()))),
        .inlineFragment(parentType: Interface_Animal,
                              inclusionConditions: [.include(if: "b")]),
      ],
      mergedSelections: [],
      mergedSources: []
    )

    let expected_allAnimal_ifC = SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "c")],
      directSelections: [
        .field("c", type: .nonNull(.scalar(.string()))),
      ],
      mergedSelections: [],
      mergedSources: []
    )

    let expected_allAnimal_ifA_ifB = try SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "b")],
      directSelections: [
        .field("b", type: .nonNull(.scalar(.string()))),
      ],
      mergedSelections: [
        .field("a", type: .nonNull(.scalar(.string()))),
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
        .inlineFragment(parentType: Interface_Pet,
                              inclusionConditions: nil),
        .inlineFragment(parentType: Interface_Animal,
                              inclusionConditions: [.include(if: "b")])
      ],
      mergedSelections: [],
      mergedSources: []
    )

    let expected_allAnimal_asPet = SelectionSetMatcher(
      parentType: Interface_Pet,
      inclusionConditions: nil,
      directSelections: [
        .field("a", type: .nonNull(.scalar(.string()))),
      ],
      mergedSelections: [],
      mergedSources: []
    )

    let expected_allAnimal_ifB = SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "b")],
      directSelections: [
        .field("b", type: .nonNull(.scalar(.string()))),
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
        .inlineFragment(parentType: Interface_Pet,
                              inclusionConditions: [.include(if: "b")]),
        .inlineFragment(parentType: Interface_Animal,
                              inclusionConditions: [.include(if: "b")])
      ],
      mergedSelections: [],
      mergedSources: []
    )

    let expected_allAnimal_asPet = try SelectionSetMatcher(
      parentType: Interface_Pet,
      inclusionConditions: [.include(if: "b")],
      directSelections: [
        .field("a", type: .nonNull(.scalar(.string()))),
      ],
      mergedSelections: [
        .field("b", type: .nonNull(.scalar(.string()))),
      ],
      mergedSources: [
        .mock(allAnimals?[if: "b"])
      ]
    )

    let expected_allAnimal_ifB = SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "b")],
      directSelections: [
        .field("b", type: .nonNull(.scalar(.string()))),
      ],
      mergedSelections: [],
      mergedSources: []
    )

    // then
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
        .inlineFragment(parentType: Interface_Pet,
                              inclusionConditions: [.include(if: "a")]),
        .inlineFragment(parentType: Interface_Animal,
                              inclusionConditions: [.include(if: "b")])
      ],
      mergedSelections: [],
      mergedSources: []
    )

    let expected_allAnimal_asPet = SelectionSetMatcher(
      parentType: Interface_Pet,
      inclusionConditions: [.include(if: "a")],
      directSelections: [
        .field("a", type: .nonNull(.scalar(.string()))),
      ],
      mergedSelections: [],
      mergedSources: []
    )

    let expected_allAnimal_ifB = SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "b")],
      directSelections: [
        .field("b", type: .nonNull(.scalar(.string()))),
      ],
      mergedSelections: [],
      mergedSources: []
    )

    // then
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

    let expected_allAnimal = SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: nil,
      directSelections: [
        .fragmentSpread(FragmentA, inclusionConditions: [.include(if: "a")]),
      ],
      mergedSelections: [
        .inlineFragment(parentType: Interface_Animal,
                              inclusionConditions: [.include(if: "a")]),
      ],
      mergedSources: []
    )

    let expected_allAnimal_ifA = try SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "a")],
      directSelections: nil,
      mergedSelections: [
        .field("a", type: .nonNull(.scalar(.string()))),
        .fragmentSpread(FragmentA, inclusionConditions: [.include(if: "a")]),
      ],
      mergedSources: [
        .mock(allAnimals),
        .mock(allAnimals?[fragment: "FragmentA"]),
      ]
    )

    // then
    expect(allAnimals?.selectionSet).to(shallowlyMatch(expected_allAnimal))

    expect(allAnimals?[if: "a"]).to(shallowlyMatch(expected_allAnimal_ifA))
  }

  func test__selections__givenIncludeIfVariable_onNamedFragmentOfDifferentType_createsTypeCaseSelectionWithInclusionCondition_typeCaseDoesNotContainAdditionalInlineFragmentForInclusionCondition() throws {
    // given
    schemaSDL = """
     type Query {
       allAnimals: [Animal!]
     }

     interface Animal {
       a: String!
       friend: Animal!
     }

     type Dog implements Animal {
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

     fragment FragmentA on Dog {
       a
     }
     """

    // when
    try buildSubjectRootField()

    let Interface_Animal = try XCTUnwrap(schema[interface: "Animal"])
    let Object_Dog = try XCTUnwrap(schema[object: "Dog"])
    let FragmentA = try XCTUnwrap(ir.compilationResult[fragment: "FragmentA"])

    let allAnimals = self.subject[field: "allAnimals"]

    let expected_allAnimal = SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: nil,
      directSelections: [
        .inlineFragment(parentType: Object_Dog,
                              inclusionConditions: [.include(if: "a")])
      ],
      mergedSelections: [
      ],
      mergedSources: []
    )

    let expected_allAnimal_asDog = try SelectionSetMatcher(
      parentType: Object_Dog,
      inclusionConditions: [.include(if: "a")],
      directSelections: [
        .fragmentSpread(FragmentA, inclusionConditions: [.include(if: "a")]),
      ],
      mergedSelections: [
        .field("a", type: .nonNull(.scalar(.string()))),
      ],
      mergedSources: [
        .mock(allAnimals?[as: "Dog", if: "a"]?[fragment: "FragmentA"]),
      ]
    )

    // then
    expect(allAnimals?.selectionSet).to(shallowlyMatch(expected_allAnimal))

    expect(allAnimals?[as: "Dog", if: "a"]).to(shallowlyMatch(expected_allAnimal_asDog))
  }

  func test__selections__givenDuplicateIncludeIfVariable_onNamedFragment_createsSelectionWithDeduplicatedInclusionCondition() throws {
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

    let expected_allAnimal = SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: nil,
      directSelections: [
        .fragmentSpread(FragmentA, inclusionConditions: [.include(if: "a")]),
      ],
      mergedSelections: [
        .inlineFragment(parentType: Interface_Animal,
                              inclusionConditions: [.include(if: "a")]),
      ],
      mergedSources: []
    )

    let expected_allAnimal_ifA = try SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "a")],
      directSelections: nil,
      mergedSelections: [
        .field("a", type: .nonNull(.scalar(.string()))),
        .fragmentSpread(FragmentA, inclusionConditions: [.include(if: "a")]),
      ],
      mergedSources: [
        .mock(allAnimals),
        .mock(allAnimals?[fragment: "FragmentA"]),
      ]
    )

    // then
    expect(allAnimals?.selectionSet).to(shallowlyMatch(expected_allAnimal))

    expect(allAnimals?[if: "a"]).to(shallowlyMatch(expected_allAnimal_ifA))
  }

  func test__selections__givenDuplicateNamedFragmentWithDifferentConditions_createsDeduplicatedInclusionCondition() throws {
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
        ...FragmentA @include(if: $b)
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
    let fragmentASpread: ShallowSelectionMatcher = .fragmentSpread(
      FragmentA,
      inclusionConditions: AnyOf([
        .init(.include(if: "a")),
        .init(.include(if: "b"))
      ]))

    let expected_allAnimal = SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: nil,
      directSelections: [
        fragmentASpread
      ],
      mergedSelections: [
        .inlineFragment(parentType: Interface_Animal,
                        inclusionConditions: [.include(if: "a")]),
        .inlineFragment(parentType: Interface_Animal,
                        inclusionConditions: [.include(if: "b")]),
      ],
      mergedSources: []
    )

    let expected_allAnimal_ifA = try SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "a")],
      directSelections: nil,
      mergedSelections: [
        .field("a", type: .nonNull(.scalar(.string()))),
        fragmentASpread
      ],
      mergedSources: [
        .mock(allAnimals),
        .mock(allAnimals?[fragment: "FragmentA"]),
      ]
    )

    let expected_allAnimal_ifB = try SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "b")],
      directSelections: nil,
      mergedSelections: [
        .field("a", type: .nonNull(.scalar(.string()))),
        fragmentASpread
      ],
      mergedSources: [
        .mock(allAnimals),
        .mock(allAnimals?[fragment: "FragmentA"]),
      ]
    )

    // then
    expect(allAnimals?.selectionSet).to(shallowlyMatch(expected_allAnimal))
    expect(allAnimals?[if: "a"]).to(shallowlyMatch(expected_allAnimal_ifA))
    expect(allAnimals?[if: "b"]).to(shallowlyMatch(expected_allAnimal_ifB))
  }

  func test__selections__givenNamedFragmentWithCompoundConditionsAndDuplicateWithDifferentConditions_createsDeduplicatedInclusionCondition() throws {
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
        ...FragmentA @include(if: $a) @include(if: $b)
        ...FragmentA @include(if: $c)
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
    let fragmentASpread: ShallowSelectionMatcher = .fragmentSpread(
      FragmentA,
      inclusionConditions: AnyOf([
        try .allOf([IR.InclusionCondition.include(if: "a"),
                    IR.InclusionCondition.include(if: "b")]).conditions.xctUnwrapped(),
        .init(.include(if: "c"))
      ]))

    let expected_allAnimal = SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: nil,
      directSelections: [
        fragmentASpread
      ],
      mergedSelections: [
        .inlineFragment(parentType: Interface_Animal,
                        inclusionConditions: [.include(if: "a"), .include(if: "b")]),
        .inlineFragment(parentType: Interface_Animal,
                        inclusionConditions: [.include(if: "c")]),
      ],
      mergedSources: []
    )

    let expected_allAnimal_ifAAndB = try SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "a"), .include(if: "b")],
      directSelections: nil,
      mergedSelections: [
        .field("a", type: .nonNull(.scalar(.string()))),
        fragmentASpread
      ],
      mergedSources: [
        .mock(allAnimals),
        .mock(allAnimals?[fragment: "FragmentA"]),
      ]
    )

    let expected_allAnimal_ifC = try SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "c")],
      directSelections: nil,
      mergedSelections: [
        .field("a", type: .nonNull(.scalar(.string()))),
        fragmentASpread
      ],
      mergedSources: [
        .mock(allAnimals),
        .mock(allAnimals?[fragment: "FragmentA"]),
      ]
    )

    // then
    expect(allAnimals?.selectionSet).to(shallowlyMatch(expected_allAnimal))
    expect(allAnimals?[if: "a" && "b"]).to(shallowlyMatch(expected_allAnimal_ifAAndB))
    expect(allAnimals?[if: "c"]).to(shallowlyMatch(expected_allAnimal_ifC))
  }

  func test__selections__givenTwoIncludeIfNamedFragments_withSameCondition_createsSelectionWithInclusionCondition() throws {
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
        ...FragmentA @include(if: $a)
        ...FragmentB @include(if: $a)
      }
    }

    fragment FragmentA on Animal {
      a
    }

    fragment FragmentB on Animal {
      b
    }
    """

    // when
    try buildSubjectRootField()

    let Interface_Animal = try XCTUnwrap(schema[interface: "Animal"])
    let FragmentA = try XCTUnwrap(ir.compilationResult[fragment: "FragmentA"])
    let FragmentB = try XCTUnwrap(ir.compilationResult[fragment: "FragmentB"])

    let allAnimals = self.subject[field: "allAnimals"]

    let expected_allAnimal = SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: nil,
      directSelections: [
        .fragmentSpread(FragmentA, inclusionConditions: [.include(if: "a")]),
        .fragmentSpread(FragmentB, inclusionConditions: [.include(if: "a")]),
      ],
      mergedSelections: [
        .inlineFragment(parentType: Interface_Animal,
                              inclusionConditions: [.include(if: "a")]),
      ],
      mergedSources: []
    )

    let expected_allAnimal_ifA = try SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "a")],
      directSelections: nil,
      mergedSelections: [
        .field("a", type: .nonNull(.scalar(.string()))),
        .field("b", type: .nonNull(.scalar(.string()))),
        .fragmentSpread(FragmentA, inclusionConditions: [.include(if: "a")]),
        .fragmentSpread(FragmentB, inclusionConditions: [.include(if: "a")]),
      ],
      mergedSources: [
        .mock(allAnimals),
        .mock(allAnimals?[fragment: "FragmentA"]),
        .mock(allAnimals?[fragment: "FragmentB"]),
      ]
    )

    // then
    expect(allAnimals?.selectionSet).to(shallowlyMatch(expected_allAnimal))

    expect(allAnimals?[if: "a"]).to(shallowlyMatch(expected_allAnimal_ifA))
  }

  func test__selections__namedFragmentWithConditionMergedIntoTypeCase_doesNotMergeNamedFragment() throws {
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

    interface Pet {
      b: String!
    }
    """

    document = """
    query Test($a: Boolean!) {
      allAnimals {
        ...FragmentA @include(if: $a)
        ... on Pet {
          b
        }
      }
    }

    fragment FragmentA on Animal {
      a
    }
    """

    // when
    try buildSubjectRootField()

    let Interface_Animal = try XCTUnwrap(schema[interface: "Animal"])
    let Interface_Pet = try XCTUnwrap(schema[interface: "Pet"])
    let FragmentA = try XCTUnwrap(ir.compilationResult[fragment: "FragmentA"])

    let allAnimals = self.subject[field: "allAnimals"]

    let expected_allAnimal = SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: nil,
      directSelections: [
        .fragmentSpread(FragmentA, inclusionConditions: [.include(if: "a")]),
        .inlineFragment(parentType: Interface_Pet),
      ],
      mergedSelections: [
        .inlineFragment(parentType: Interface_Animal,
                        inclusionConditions: [.include(if: "a")]),],
      mergedSources: []
    )

    let expected_allAnimal_ifA = try SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "a")],
      directSelections: nil,
      mergedSelections: [
        .field("a", type: .nonNull(.scalar(.string()))),
        .fragmentSpread(FragmentA, inclusionConditions: [.include(if: "a")]),
      ],
      mergedSources: [
        .mock(allAnimals?[fragment: "FragmentA"]),
        .mock(allAnimals),
      ]
    )

    let expected_allAnimal_asPet = try SelectionSetMatcher(
      parentType: Interface_Pet,
      inclusionConditions: nil,
      directSelections: [
        .field("b", type: .nonNull(.scalar(.string()))),
      ],
      mergedSelections: [
        .fragmentSpread(FragmentA, inclusionConditions: [.include(if: "a")]),
      ],
      mergedSources: [
        .mock(allAnimals),
      ]
    )

    // then
    expect(allAnimals?.selectionSet).to(shallowlyMatch(expected_allAnimal))
    expect(allAnimals?[if: "a"]).to(shallowlyMatch(expected_allAnimal_ifA))
    expect(allAnimals?[as: "Pet"]).to(shallowlyMatch(expected_allAnimal_asPet))
    expect(allAnimals?[as: "Pet"]?[if: "a"]).to(beNil())
  }

  // MARK: Merged Named Fragments

  func test__selections__givenIncludeIfVariableOnNamedFragment_merged_createsSelectionWithInclusionCondition() throws {
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

    let expected_allAnimal = SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: nil,
      directSelections: [
        .fragmentSpread(FragmentA, inclusionConditions: [.include(if: "a")]),
      ],
      mergedSelections: [
        .inlineFragment(parentType: Interface_Animal,
                              inclusionConditions: [.include(if: "a")]),
      ],
      mergedSources: []
    )

    let expected_allAnimal_ifA = try SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: [.include(if: "a")],
      directSelections: nil,
      mergedSelections: [
        .field("a", type: .nonNull(.scalar(.string()))),
        .fragmentSpread(FragmentA, inclusionConditions: [.include(if: "a")]),
      ],
      mergedSources: [
        .mock(allAnimals),
        .mock(allAnimals?[fragment: "FragmentA"]),
      ]
    )

    // then
    expect(allAnimals?.selectionSet).to(shallowlyMatch(expected_allAnimal))

    expect(allAnimals?[if: "a"]).to(shallowlyMatch(expected_allAnimal_ifA))
  }

  func test__selections__givenNonNullFieldMergedFromNestedEntityInNamedFragmentWithIncludeCondition_createsSelections() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    type Animal {
      child: Child!
    }

    type Child {
      a: String!
      b: String!
      c: String!
    }
    """

    document = """
    query TestOperation($a: Boolean!) {
      allAnimals {
        ...ChildFragment @include(if: $a)
        ...ChildFragment @include(if: $b)
        child {
          a
        }
        child @include(if: $c) {
          c
        }
      }
    }

    fragment ChildFragment on Animal {
      child {
        b
      }
    }
    """

    // when
    try buildSubjectRootField()

    let allAnimals = try XCTUnwrap(
      self.subject[field: "allAnimals"] as? IR.EntityField
    )

    let allAnimals_child = try XCTUnwrap(
      allAnimals[field: "child"] as? IR.EntityField
    )

    let Object_Child = try XCTUnwrap(schema[object: "Child"])
    let ChildFragment = try XCTUnwrap(allAnimals[fragment: "ChildFragment"])

    let expected_allAnimals_child = SelectionSetMatcher(
      parentType: Object_Child,
      inclusionConditions: nil,
      directSelections: [
        .field("a", type: .nonNull(.scalar(.string()))),
        .inlineFragment(parentType: Object_Child,
                        inclusionConditions: [.include(if: "c")]),
      ],
      mergedSelections: [],
      mergedSources: []
    )

    let expected_allAnimals_child_ifC = try SelectionSetMatcher(
      parentType: Object_Child,
      inclusionConditions: [.include(if: "c")],
      directSelections: [
        .field("c", type: .nonNull(.scalar(.string()))),
      ],
      mergedSelections: [
        .field("a", type: .nonNull(.scalar(.string()))),
      ],
      mergedSources: [
        .mock(allAnimals[field: "child"]),
      ]
    )

    let expected_allAnimals_ifA_child = try SelectionSetMatcher(
      parentType: Object_Child,
      inclusionConditions: nil,
      directSelections: nil,
      mergedSelections: [
        .field("a", type: .nonNull(.scalar(.string()))),
        .field("b", type: .nonNull(.scalar(.string()))),
        .inlineFragment(parentType: Object_Child,
                        inclusionConditions: [.include(if: "c")]),
      ],
      mergedSources: [
        .mock(allAnimals[field: "child"]),
        .mock(for: ChildFragment.fragment[field: "child"],
              from: ChildFragment),
      ]
    )

    let expected_allAnimals_ifB_child = try SelectionSetMatcher(
      parentType: Object_Child,
      inclusionConditions: nil,
      directSelections: nil,
      mergedSelections: [
        .field("a", type: .nonNull(.scalar(.string()))),
        .field("b", type: .nonNull(.scalar(.string()))),
        .inlineFragment(parentType: Object_Child,
                        inclusionConditions: [.include(if: "c")]),
      ],
      mergedSources: [
        .mock(allAnimals[field: "child"]),
        .mock(for: ChildFragment.fragment[field: "child"],
              from: ChildFragment),
      ]
    )

    // then
    expect(allAnimals_child.selectionSet).to(shallowlyMatch(expected_allAnimals_child))
    expect(allAnimals_child[if: "c"])
      .to(shallowlyMatch(expected_allAnimals_child_ifC))
    expect(allAnimals[if: "a"]?[field: "child"]?.selectionSet)
      .to(shallowlyMatch(expected_allAnimals_ifA_child))
    expect(allAnimals[if: "b"]?[field: "child"]?.selectionSet)
      .to(shallowlyMatch(expected_allAnimals_ifB_child))
  }

  func test__selections__givenFragmentMergedInEntityRootWithInclusionConditionAndInOtherFragmentWithOtherInclusionCondition_mergesSelections() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      child: Child!
    }

    interface WarmBlooded implements Animal {
      child: Child!
    }

    type Child {
      a: String!
      b: String!
      c: String!
    }
    """

    document = """
    query TestOperation($b: Boolean!, $c: Boolean!) {
      allAnimals {
        child {
          a
        }
        ...ChildFragment @skip(if: $b)
        ...FragmentContainingChildFragment @include(if: $c)
      }
    }

    fragment ChildFragment on Animal {
      child {
        b
      }
    }

    fragment FragmentContainingChildFragment on WarmBlooded {
       ...ChildFragment
    }
    """

    // when
    try buildSubjectRootField()

    let allAnimals = try XCTUnwrap(
      self.subject[field: "allAnimals"] as? IR.EntityField
    )

    let allAnimals_child = try XCTUnwrap(
      allAnimals[field: "child"] as? IR.EntityField
    )

    let allAnimals_asWarmBloodedIfC = allAnimals[as: "WarmBlooded", if: "c"]

    let Interface_Animal = try XCTUnwrap(schema[interface: "Animal"])
    let Interface_WarmBlooded = try XCTUnwrap(schema[interface: "WarmBlooded"])
    let Object_Child = try XCTUnwrap(schema[object: "Child"])
    let ChildFragment = try XCTUnwrap(allAnimals[fragment: "ChildFragment"])
    let FragmentContainingChildFragment = try XCTUnwrap(
      allAnimals[as: "WarmBlooded", if: "c"]?[fragment: "FragmentContainingChildFragment"]
    )

    let expected_allAnimals = SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: nil,
      directSelections: [
        .field("child", type: .nonNull(.entity(Object_Child))),
        .inlineFragment(parentType: Interface_WarmBlooded,
                        inclusionConditions: [.include(if: "c")]),
        .fragmentSpread(ChildFragment.definition,
                        inclusionConditions: [.skip(if: "b")]),
      ],
      mergedSelections: [
        .inlineFragment(parentType: Interface_Animal,
                        inclusionConditions: [.skip(if: "b")]),
      ],
      mergedSources: []
    )

    let expected_allAnimals_child = SelectionSetMatcher(
      parentType: Object_Child,
      inclusionConditions: nil,
      directSelections: [
        .field("a", type: .nonNull(.scalar(.string())))        
      ],
      mergedSelections: [],
      mergedSources: []
    )

    let expected_allAnimals_ifB = try SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: [.skip(if: "b")],
      directSelections: nil,
      mergedSelections: [
        .field("child", type: .nonNull(.entity(Object_Child))),
        .fragmentSpread(ChildFragment.definition,
                        inclusionConditions: [.skip(if: "b")])
      ],
      mergedSources: [
        .mock(allAnimals),
        .mock(for: ChildFragment.fragment.rootField,
              from: ChildFragment),
      ]
    )

    let expected_allAnimals_ifB_child = try SelectionSetMatcher(
      parentType: Object_Child,
      inclusionConditions: nil,
      directSelections: nil,
      mergedSelections: [
        .field("a", type: .nonNull(.scalar(.string()))),
        .field("b", type: .nonNull(.scalar(.string()))),
      ],
      mergedSources: [
        .mock(allAnimals[field: "child"]),
        .mock(for: ChildFragment.fragment[field: "child"],
              from: ChildFragment),
      ]
    )

    let expected_allAnimals_ifWarmBloodedAndC = try SelectionSetMatcher(
      parentType: Interface_WarmBlooded,
      inclusionConditions: [.include(if: "c")],
      directSelections: [
        .fragmentSpread(FragmentContainingChildFragment.definition,
                        inclusionConditions: [.include(if: "c")]),
      ],
      mergedSelections: [
        .field("child", type: .nonNull(.entity(Object_Child))),
        .fragmentSpread(ChildFragment.definition),
      ],
      mergedSources: [
        .mock(allAnimals),
        .mock(FragmentContainingChildFragment),
        .mock(ChildFragment)
      ]
    )

    let expected_allAnimals_ifWarmBloodedAndC_child = try SelectionSetMatcher(
      parentType: Object_Child,
      inclusionConditions: nil,
      directSelections: nil,
      mergedSelections: [
        .field("a", type: .nonNull(.scalar(.string()))),
        .field("b", type: .nonNull(.scalar(.string()))),
      ],
      mergedSources: [
        .mock(allAnimals[field: "child"]),
        .mock(for: ChildFragment.fragment[field: "child"],
              from: ChildFragment),
      ]
    )

    // then
    expect(allAnimals.selectionSet).to(shallowlyMatch(expected_allAnimals))
    expect(allAnimals_child.selectionSet).to(shallowlyMatch(expected_allAnimals_child))
    expect(allAnimals[if: !"b"]).to(shallowlyMatch(expected_allAnimals_ifB))
    expect(allAnimals[if: !"b"]?[field: "child"]?.selectionSet)
      .to(shallowlyMatch(expected_allAnimals_ifB_child))
    expect(allAnimals_asWarmBloodedIfC).to(shallowlyMatch(expected_allAnimals_ifWarmBloodedAndC))
    expect(allAnimals[as: "WarmBlooded", if: "c"]?[field: "child"]?.selectionSet)
      .to(shallowlyMatch(expected_allAnimals_ifWarmBloodedAndC_child))
  }

  func test__selections__givenFragmentMergedFromEntityRootWithInclusionConditionAndFromInTypeCaseWithNoInclusionCondition_mergesFragmentIntoBothConditionalSelectionSets() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      child: Child!
    }

    interface Pet implements Animal {
      child: Child!
    }

    interface WarmBlooded implements Animal {
      child: Child!
    }

    type Child {
      a: String!
      b: String!
      c: String!
    }
    """

    document = """
    query TestOperation($b: Boolean!, $c: Boolean!) {
      allAnimals {
        child {
          a
        }
        ...WarmBloodedDetails @skip(if: $b)
        ... on Pet {
          ...WarmBloodedDetails
        }
      }
    }

    fragment WarmBloodedDetails on WarmBlooded {
      child {
        b
      }
    }
    """

    // when
    try buildSubjectRootField()

    let allAnimals = try XCTUnwrap(
      self.subject[field: "allAnimals"] as? IR.EntityField
    )

    let allAnimals_asPet = try XCTUnwrap(
      allAnimals[as: "Pet"]
    )

    let allAnimals_asPet_asWarmBlooded = try XCTUnwrap(
      allAnimals_asPet[as: "WarmBlooded"]
    )

    let allAnimals_child = try XCTUnwrap(
      allAnimals[field: "child"] as? IR.EntityField
    )

    let allAnimals_asWarmBloodedIfNotB = allAnimals[as: "WarmBlooded", if: !"b"]

    let Interface_Animal = try XCTUnwrap(schema[interface: "Animal"])
    let Interface_WarmBlooded = try XCTUnwrap(schema[interface: "WarmBlooded"])
    let Interface_Pet = try XCTUnwrap(schema[interface: "Pet"])
    let Object_Child = try XCTUnwrap(schema[object: "Child"])
    let WarmBloodedDetails = try XCTUnwrap(
      allAnimals[as: "WarmBlooded", if: !"b"]?[fragment: "WarmBloodedDetails"]
    )

    let expected_allAnimals = SelectionSetMatcher(
      parentType: Interface_Animal,
      inclusionConditions: nil,
      directSelections: [
        .field("child", type: .nonNull(.entity(Object_Child))),
        .inlineFragment(parentType: Interface_WarmBlooded,
                        inclusionConditions: [.skip(if: "b")]),
        .inlineFragment(parentType: Interface_Pet),
      ],
      mergedSelections: [
      ],
      mergedSources: []
    )

    let expected_allAnimals_child = SelectionSetMatcher(
      parentType: Object_Child,
      inclusionConditions: nil,
      directSelections: [
        .field("a", type: .nonNull(.scalar(.string())))
      ],
      mergedSelections: [],
      mergedSources: []
    )

    let expected_allAnimals_asPet = try SelectionSetMatcher(
      parentType: Interface_Pet,
      inclusionConditions: nil,
      directSelections: [
        .inlineFragment(parentType: Interface_WarmBlooded),
      ],
      mergedSelections: [
        .field("child", type: .nonNull(.entity(Object_Child))),
      ],
      mergedSources: [
        .mock(allAnimals),
      ]
    )

    let expected_allAnimals_asPet_asWarmBlooded = try SelectionSetMatcher(
      parentType: Interface_WarmBlooded,
      inclusionConditions: nil,
      directSelections: [
        .fragmentSpread(WarmBloodedDetails.definition)
      ],
      mergedSelections: [
        .field("child", type: .nonNull(.entity(Object_Child))),
      ],
      mergedSources: [
        .mock(allAnimals),
        .mock(WarmBloodedDetails),
      ]
    )

    let expected_allAnimals_ifWarmBloodedAndNotB = try SelectionSetMatcher(
      parentType: Interface_WarmBlooded,
      inclusionConditions: [.skip(if: "b")],
      directSelections: [
        .fragmentSpread(WarmBloodedDetails.definition,
                        inclusionConditions: [.skip(if: "b")]),
      ],
      mergedSelections: [
        .field("child", type: .nonNull(.entity(Object_Child))),
      ],
      mergedSources: [
        .mock(allAnimals),
        .mock(WarmBloodedDetails),
      ]
    )

    let expected_allAnimals_ifWarmBloodedAndNotB_child = try SelectionSetMatcher(
      parentType: Object_Child,
      inclusionConditions: nil,
      directSelections: nil,
      mergedSelections: [
        .field("a", type: .nonNull(.scalar(.string()))),
        .field("b", type: .nonNull(.scalar(.string()))),
      ],
      mergedSources: [
        .mock(allAnimals[field: "child"]),
        .mock(for: WarmBloodedDetails.fragment[field: "child"],
              from: WarmBloodedDetails),
      ]
    )

    // then
    expect(allAnimals.selectionSet).to(shallowlyMatch(expected_allAnimals))
    expect(allAnimals_child.selectionSet).to(shallowlyMatch(expected_allAnimals_child))
    expect(allAnimals_asPet).to(shallowlyMatch(expected_allAnimals_asPet))
    expect(allAnimals_asPet_asWarmBlooded).to(shallowlyMatch(expected_allAnimals_asPet_asWarmBlooded))
    expect(allAnimals_asWarmBloodedIfNotB).to(shallowlyMatch(expected_allAnimals_ifWarmBloodedAndNotB))
    expect(allAnimals_asWarmBloodedIfNotB?[field: "child"]?.selectionSet)
      .to(shallowlyMatch(expected_allAnimals_ifWarmBloodedAndNotB_child))
  }

  // MARK: - Group By Inclusion Conditions

  func test__groupedByInclusionConditions__groupsInclusionConditionsCorrectly() throws {
    // given
    schemaSDL = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      a: String
      b: String
      c: String
      d: String
      e: String
      f: String
      g: String
      h: String
      i: String
      j: String
      k: String
      l: String
    }

    interface Pet {
      pet1: String
      pet2: String
      pet3: String
    }
    """

    document = """
    fragment FragB on Animal {
      b
    }

    fragment FragG on Animal {
      g
    }

    query Test {
      allAnimals {
        a @include(if: $a)
        ...FragB @include(if: $a)
        ... on Pet @include(if: $a) {
          pet1
        }
        c @include(if: $c)
        d @include(if: $d)
        ... on Pet @include(if: $e) {
          pet2
        }
        f
        ...FragG
        ... on Pet {
          pet3
        }
        h @include(if: $h1)
        h @include(if: $h2)
        i @include(if: $i1) @skip(if: $i2)
        i @skip(if: $i3)
        j @include(if: $j) @skip(if: $j)
        k
        k @include(if: $k)
        l @skip(if: $l)
      }
    }
    """

    // when
    try buildSubjectRootField()

    let Interface_Pet = try XCTUnwrap(schema[interface: "Pet"])
    let FragmentB = try XCTUnwrap(ir.compilationResult[fragment: "FragB"])
    let FragmentG = try XCTUnwrap(ir.compilationResult[fragment: "FragG"])
    let allAnimals = self.subject[field: "allAnimals"]

    let expectedUnconditional: SelectionMatcherTuple = (
      fields: [
        .mock("f", type: .string()),
        .mock("k", type: .string())
      ],
      typeCases: [
        .mock(parentType: Interface_Pet)
      ],
      fragments: [
        .mock(FragmentG)
      ]
    )

    let h1Orh2Condition: AnyOf<IR.InclusionConditions> = AnyOf([
      .init(.include(if: "h1")),
      .init(.include(if: "h2"))
    ])

    let i1Andi2Ori3Condition: AnyOf<IR.InclusionConditions> = try AnyOf([
      (.include(if: "i1") && .skip(if: "i2")).conditions.xctUnwrapped(),
      .init(.skip(if: "i3"))
    ])

    let expectedInclusionGroups:
    OrderedDictionary<AnyOf<IR.InclusionConditions>, SelectionMatcherTuple> = [
      AnyOf(.include(if: "a")): (
        fields: [
          .mock("a", type: .string(), inclusionConditions: AnyOf(.include(if: "a"))),
        ],
        typeCases: [
          .mock(parentType: Interface_Pet, inclusionConditions: [.include(if: "a")])
        ],
        fragments: [
          .mock(FragmentB, inclusionConditions: AnyOf(.include(if: "a")))
        ]),
      AnyOf(.include(if: "c")): (
        fields: [
          .mock("c", type: .string(), inclusionConditions: AnyOf(.include(if: "c"))),
        ],
        typeCases: [],
        fragments: []),
      AnyOf(.include(if: "d")): (
        fields: [
          .mock("d", type: .string(), inclusionConditions: AnyOf(.include(if: "d"))),
        ],
        typeCases: [],
        fragments: []),
      AnyOf(.include(if: "e")): (
        fields: [],
        typeCases: [
          .mock(parentType: Interface_Pet, inclusionConditions: [.include(if: "e")])
        ],
        fragments: []),
      h1Orh2Condition: (
        fields: [
          .mock("h", type: .string(), inclusionConditions: h1Orh2Condition),
        ],
        typeCases: [],
        fragments: []),
      i1Andi2Ori3Condition: (
        fields: [
          .mock("i", type: .string(), inclusionConditions: i1Andi2Ori3Condition),
        ],
        typeCases: [],
        fragments: []),
      AnyOf(.skip(if: "l")): (
        fields: [
          .mock("l", type: .string(), inclusionConditions: AnyOf(.skip(if: "l"))),
        ],
        typeCases: [],
        fragments: []),
    ]

    let actual = allAnimals?.selectionSet?.selections.direct?.groupedByInclusionCondition

    // then
    expect(actual?.unconditionalSelections).to(shallowlyMatch(expectedUnconditional))

    expect(actual?.inclusionConditionGroups.count).to(equal(expectedInclusionGroups.count))
    for conditionGroup in expectedInclusionGroups.keys {
      let expectedGroup = try expectedInclusionGroups[conditionGroup].xctUnwrapped()
      let actualGroup = try actual?.inclusionConditionGroups[conditionGroup].xctUnwrapped()
      expect(actualGroup).to(shallowlyMatch(expectedGroup))
    }
  }

}
