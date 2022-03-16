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

    let expected: AnyOf<IR.InclusionConditions> = try AnyOf(
      XCTUnwrap(.mock([.include(if: "a")]))
    )

    // then
    expect(actual?.inclusionConditions).to(equal(expected))
    /// The field is conditonally included, so the inclusion conditions should be on the field.
    /// But the field's selection set is not conditionally included - if the field is present,
    /// the selection set is present, so the selection set has `nil` inclusion conditions.
    ///
    /// When merging conditionally included fields together the field root, will have
    /// `nil` inclusion conditions and also empty direct selections. The selection set will have
    /// multiple nested selection sets with conditional inclusion conditions.
    expect(actual?.selectionSet?.scope.inclusionConditions).to(beNil())

    expect(actual?[field: "species"]).toNot(beNil())
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

    let actual = self.subject[field: "allAnimals"]?[field: "friend"]

    let friend_expected: AnyOf<IR.InclusionConditions> = try AnyOf([
      XCTUnwrap(.mock([.include(if: "a")])),
      XCTUnwrap(.mock([.skip(if: "a")]))
    ])

    let friend_ifA_expected: IR.InclusionConditions = try XCTUnwrap(.mock([
      .include(if: "a")
    ]))

    let friend_ifNotA_expected: IR.InclusionConditions = try XCTUnwrap(.mock([
      .skip(if: "a")
    ]))

    // then
    expect(actual?.inclusionConditions).to(equal(friend_expected))
    expect(actual?.selectionSet?.scope.inclusionConditions).to(beNil())

    expect(actual?[field: "a"]).to(beNil())
    expect(actual?[field: "b"]).to(beNil())

    expect(actual?[field: "a"]?[if: "a"]?.inclusionConditions).to(equal(friend_ifA_expected))
    expect(actual?[field: "b"]?[if: !"a"]?.inclusionConditions).to(equal(friend_ifNotA_expected))
  }
  
}
