import XCTest
import Nimble
import OrderedCollections
@testable import ApolloCodegenLib
import ApolloTestSupport
import ApolloCodegenTestSupport
import ApolloAPI

class IROperationBuilderTests: XCTestCase {

  var schema: String!
  var document: String!
  var ir: IR!
  var operation: CompilationResult.OperationDefinition!
  var subject: IR.Operation!

  var compilationResult: CompilationResult { ir.compilationResult }

  override func setUp() {
    super.setUp()
  }

  override func tearDown() {
    schema = nil
    document = nil
    operation = nil
    subject = nil
    super.tearDown()
  }

  // MARK: = Helpers

  func buildSubjectOperation() throws {
    ir = try .mock(schema: schema, document: document)
    operation = try XCTUnwrap(compilationResult.operations.first)
    subject = ir.build(operation: operation)
  }

  // MARK: - Children Computation

  // MARK: Children - Fragment Type

  func test__children__initWithNamedFragmentOnTheSameType_hasNoChildTypeCase() throws {
    // given
    schema = """
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
        ...AnimalDetails
      }
    }

    fragment AnimalDetails on Animal {
      species
    }
    """

    // when
    try buildSubjectOperation()

    let allAnimals = self.subject[field: "query"]?[field: "allAnimals"]?.selectionSet

    // then
    expect(allAnimals?.selections.typeCases).to(beEmpty())
  }

  func test__children__initWithNamedFragmentOnMoreSpecificType_hasChildTypeCase() throws {
    // given
    schema = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
    }

    type Bird implements Animal {
      species: String!
    }
    """

    document = """
    query Test {
      allAnimals {
        ...BirdDetails
      }
    }

    fragment BirdDetails on Bird {
      species
    }
    """

    // when
    try buildSubjectOperation()

    let Object_Bird = try XCTUnwrap(compilationResult[object: "Bird"])
    let Fragment_BirdDetails = try XCTUnwrap(compilationResult[fragment: "BirdDetails"])

    let allAnimals = self.subject[field: "query"]?[field: "allAnimals"]?.selectionSet

    // then
    expect(allAnimals?.selections.typeCases.count).to(equal(1))

    let child = allAnimals?[as: "Bird"]
    expect(child?.parentType).to(equal(Object_Bird))
    expect(child?.selections.fragments).to(shallowlyMatch([Fragment_BirdDetails]))
  }

  func test__children__isObjectType_initWithNamedFragmentOnLessSpecificMatchingType_hasNoChildTypeCase() throws {
    // given
    schema = """
    type Query {
      birds: [Bird!]
    }

    interface Animal {
      species: String!
    }

    type Bird implements Animal {
      species: String!
    }
    """

    document = """
    query Test {
      birds {
        ...AnimalDetails
      }
    }

    fragment AnimalDetails on Animal {
      species
    }
    """

    // when
    try buildSubjectOperation()

    let birds = self.subject[field: "query"]?[field: "birds"]?.selectionSet

    // then
    expect(birds?.selections.typeCases).to(beEmpty())
  }

  func test__children__isInterfaceType_initWithNamedFragmentOnLessSpecificMatchingType_hasNoChildTypeCase() throws {
    // given
    schema = """
    type Query {
      flyingAnimals: [FlyingAnimal!]
    }

    interface Animal {
      species: String!
    }

    interface FlyingAnimal implements Animal {
      species: String!
    }
    """

    document = """
    query Test {
      flyingAnimals {
        ...AnimalDetails
      }
    }

    fragment AnimalDetails on Animal {
      species
    }
    """

    // when
    try buildSubjectOperation()

    let flyingAnimals = self.subject[field: "query"]?[field: "flyingAnimals"]?.selectionSet

    // then
    expect(flyingAnimals?.selections.typeCases).to(beEmpty())
  }

  func test__children__initWithNamedFragmentOnUnrelatedType_hasChildTypeCase() throws {
    // given
    schema = """
    type Query {
      rocks: [Rock!]
    }

    interface Animal {
      species: String!
    }

    type Rock {
      name: String!
    }
    """

    document = """
    query Test {
     rocks {
       ...AnimalDetails
      }
    }

    fragment AnimalDetails on Animal {
      species
    }
    """

    // when
    try buildSubjectOperation()

    let Interface_Animal = try XCTUnwrap(compilationResult[interface: "Animal"])
    let Fragment_AnimalDetails = try XCTUnwrap(compilationResult[fragment: "AnimalDetails"])

    let rocks = self.subject[field: "query"]?[field: "rocks"]?.selectionSet

    // then
    expect(rocks?.selections.typeCases.count).to(equal(1))

    let child = rocks?[as: "Animal"]
    expect(child?.parentType).to(equal(Interface_Animal))
    expect(child?.selections.fragments.count).to(equal(1))
    expect(child?.selections.fragments.values[0].definition).to(equal(Fragment_AnimalDetails))
  }

  // MARK: Children Computation - Union Type

  func test__children__givenIsUnionType_withNestedTypeCaseOfObjectType_hasChildrenForTypeCase() throws {
    // given
    schema = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
    }

    type Bird {
      species: String!
    }

    union ClassroomPet = Bird
    """

    document = """
    query Test {
      allAnimals {
        ... on ClassroomPet {
          ... on Bird {
            species
          }
        }
      }
    }
    """

    // when
    try buildSubjectOperation()

    let Object_Bird = try XCTUnwrap(compilationResult[object: "Bird"])
    let Union_ClassroomPet = try XCTUnwrap(compilationResult[union: "ClassroomPet"])

    let Scalar_String = try XCTUnwrap(compilationResult[scalar: "String"])
    let Field_Species: CompilationResult.Selection = .field(.mock(
      "species", type: .nonNull(.scalar(Scalar_String)))
    )

    let onClassroomPet = subject[field: "query"]?[field: "allAnimals"]?[as: "ClassroomPet"]
    let onClassroomPet_onBird = onClassroomPet?[as:"Bird"]

    // then
    expect(onClassroomPet?.parentType).to(beIdenticalTo(Union_ClassroomPet))
    expect(onClassroomPet?.selections.typeCases.count).to(equal(1))

    expect(onClassroomPet_onBird?.parentType).to(beIdenticalTo(Object_Bird))
    expect(onClassroomPet_onBird?.selections.fields).to(shallowlyMatch([Field_Species]))
  }

  // MARK: Children - Type Cases

  func test__children__givenInlineFragment_onSameType_mergesTypeCaseIn_doesNotHaveTypeCaseChild() throws {
    // given
    schema = """
    type Query {
      aField: [A!]
    }

    type A {
      A: String!
      B: String!
    }
    """

    document = """
    query Test {
      aField { # On A
        A
        ... on A {
          B
        }
      }
    }
    """

    // when
    try buildSubjectOperation()

    let aField = subject[field: "query"]?[field: "aField"]

    // then
    expect(aField?.selectionSet?.selections.typeCases).to(beEmpty())
  }

  func test__children__givenInlineFragment_onMatchingType_mergesTypeCaseIn_doesNotHaveTypeCaseChild() throws {
    // given
    schema = """
    type Query {
      bField: [B!]
    }

    interface A {
      A: String!
      B: String!
    }

    type B implements A {
      A: String!
      B: String!
    }
    """

    document = """
    query Test {
      bField { # On B
        A
        ... on A {
          B
        }
      }
    }
    """

    // when
    try buildSubjectOperation()

    let bField = subject[field: "query"]?[field: "bField"]

    // then
    expect(bField?.selectionSet?.selections.typeCases).to(beEmpty())
  }

  /// Example:
  ///
  /// Expected:
  /// aField.typeCases: {
  ///   ... on B
  /// }
  func test__children__givenInlineFragment_onNonMatchingType_doesNotMergeTypeCaseIn_hasChildTypeCase() throws {
    // given
    schema = """
    type Query {
      aField: [A!]
    }

    interface A {
      A: String!
      B: String!
    }

    type B {
      A: String
      B: String
    }
    """

    document = """
    query Test {
      aField { # On A
        A
        ... on B {
          B
        }
      }
    }
    """

    // when
    try buildSubjectOperation()

    let Object_B = try XCTUnwrap(compilationResult[object: "B"])
    let Scalar_String = try XCTUnwrap(compilationResult[scalar: "String"])

    let aField = subject[field: "query"]?[field: "aField"] as? IR.EntityField

    let expected = [
      CompilationResult.SelectionSet.mock(
        parentType: Object_B,
        selections: [
          .field(.mock("B", type: .scalar(Scalar_String))),
        ])
    ]

    // then
    expect(aField?.selectionSet.selections.typeCases).to(shallowlyMatch(expected))
  }

  // MARK: Children - Group Duplicate Type Cases

  func test__children__givenInlineFragmentsWithSameType_deduplicatesChildren() throws {
    // given
    schema = """
    type Query {
      bField: [B!]
    }

    interface InterfaceA {
      A: String
      B: String
    }

    type B {
      name: String
    }
    """

    document = """
    query Test {
      bField {
        ... on InterfaceA {
          A
        }
        ... on InterfaceA {
          B
        }
      }
    }
    """

    // when
    try buildSubjectOperation()

    let Scalar_String = try XCTUnwrap(compilationResult[scalar: "String"])

    let expectedChildren: [CompilationResult.Selection] = [
      .field(.mock("A", type: .scalar(Scalar_String))),
      .field(.mock("B", type: .scalar(Scalar_String))),
    ]

    let bField = subject[field: "query"]?[field: "bField"] as? IR.EntityField
    let bField_asInterfaceA = bField?[as: "InterfaceA"]

    // then
    expect(bField?.selectionSet.selections.typeCases.count).to(equal(1))
    expect(bField_asInterfaceA?.parentType).to(equal(GraphQLInterfaceType.mock("InterfaceA")))
    expect(bField_asInterfaceA?.selections).to(shallowlyMatch(expectedChildren))
  }

  func test__children__givenInlineFragmentsWithDifferentType_hasSeperateChildTypeCases() throws {
    // given
    schema = """
    type Query {
      aField: [A!]
    }

    interface InterfaceA {
      A: String
    }

    interface InterfaceB {
      B: String
    }

    type A {
      name: String
    }
    """

    document = """
    query Test {
      aField {
        ... on InterfaceA {
          A
        }
        ... on InterfaceB {
          B
        }
      }
    }
    """

    // when
    try buildSubjectOperation()

    let Scalar_String = try XCTUnwrap(compilationResult[scalar: "String"])
    let Field_A: CompilationResult.Selection = .field(.mock("A", type: .scalar(Scalar_String)))
    let Field_B: CompilationResult.Selection = .field(.mock("B", type: .scalar(Scalar_String)))

    let aField = subject[field: "query"]?[field: "aField"] as? IR.EntityField
    let aField_asInterfaceA = aField?[as: "InterfaceA"]
    let aField_asInterfaceB = aField?[as: "InterfaceB"]

    // then
    expect(aField?.selectionSet.selections.typeCases.count).to(equal(2))

    expect(aField_asInterfaceA?.parentType).to(equal(GraphQLInterfaceType.mock("InterfaceA")))
    expect(aField_asInterfaceA?.selections).to(shallowlyMatch([Field_A]))

    expect(aField_asInterfaceB?.parentType).to(equal(GraphQLInterfaceType.mock("InterfaceB")))
    expect(aField_asInterfaceB?.selections).to(shallowlyMatch([Field_B]))
  }

  // MARK: Children - Group Duplicate Fragments

  func test__children__givenDuplicateNamedFragments_onNonMatchingParentType_hasDeduplicatedTypeCaseWithChildFragment() throws {
    // given
    schema = """
    type Query {
      aField: [InterfaceA!]
    }

    interface InterfaceA {
      a: String
    }

    interface InterfaceB {
      b: String
    }
    """

    document = """
    fragment FragmentB on InterfaceB {
      b
    }

    query Test {
      aField {
        ... FragmentB
        ... FragmentB
      }
    }
    """
    // when
    try buildSubjectOperation()

    let InterfaceB = try XCTUnwrap(compilationResult[interface: "InterfaceB"])
    let FragmentB = try XCTUnwrap(compilationResult[fragment: "FragmentB"])

    let aField = subject[field: "query"]?[field: "aField"] as? IR.EntityField
    let aField_asInterfaceB = aField?[as: "InterfaceB"]

    // then
    expect(aField?.selectionSet.selections.typeCases.count).to(equal(1))

    expect(aField_asInterfaceB?.parentType).to(equal(InterfaceB))
    expect(aField_asInterfaceB?.selections).to(shallowlyMatch([.fragmentSpread(FragmentB)]))
  }

  func test__children__givenTwoNamedFragments_onSameNonMatchingParentType_hasDeduplicatedTypeCaseWithBothChildFragments() throws {
    // given
    schema = """
    type Query {
      aField: [InterfaceA!]
    }

    interface InterfaceA {
      a: String
    }

    interface InterfaceB {
      b: String
      c: String
    }
    """

    document = """
    fragment FragmentB1 on InterfaceB {
      b
    }

    fragment FragmentB2 on InterfaceB {
      c
    }

    query Test {
      aField {
        ... FragmentB1
        ... FragmentB2
      }
    }
    """

    // when
    try buildSubjectOperation()

    let InterfaceB = try XCTUnwrap(compilationResult[interface: "InterfaceB"])
    let FragmentB1 = try XCTUnwrap(compilationResult[fragment: "FragmentB1"])
    let FragmentB2 = try XCTUnwrap(compilationResult[fragment: "FragmentB2"])

    let aField = subject[field: "query"]?[field: "aField"] as? IR.EntityField
    let aField_asInterfaceB = aField?[as: "InterfaceB"]

    // then
    expect(aField?.selectionSet.selections.typeCases.count).to(equal(1))

    expect(aField_asInterfaceB?.parentType).to(equal(InterfaceB))
    expect(aField_asInterfaceB?.selections).to(shallowlyMatch([
      .fragmentSpread(FragmentB1),
      .fragmentSpread(FragmentB2)
    ]))
  }

  // MARK: - Selections

  // MARK: Selections - Group Duplicate Fields

  func test__selections__givenFieldSelectionsWithSameName_scalarType_deduplicatesSelection() throws {
    // given
    schema = """
    type Query {
      aField: [A!]
    }

    type A {
      a: String
    }
    """

    document = """
    query Test {
      aField {
        a
        a
      }
    }
    """

    let expected: [CompilationResult.Selection] = [
      .field(.mock("a", type: .scalar(.string())))
    ]

    // when
    try buildSubjectOperation()

    let aField = subject[field: "query"]?[field: "aField"] as? IR.EntityField

    // then
    expect(aField?.selectionSet.selections).to(shallowlyMatch(expected))
  }

  func test__selections__givenFieldSelectionsWithSameNameDifferentAlias_scalarType_doesNotDeduplicateSelection() throws {
    // given
    schema = """
    type Query {
      aField: [A!]
    }

    type A {
      a: String
    }
    """

    document = """
    query Test {
      aField {
        b: a
        c: a
      }
    }
    """

    let expected: [CompilationResult.Selection] = [
      .field(.mock("a", alias: "b", type: .scalar(.string()))),
      .field(.mock("a", alias: "c", type: .scalar(.string())))
    ]

    // when
    try buildSubjectOperation()

    let aField = subject[field: "query"]?[field: "aField"] as? IR.EntityField

    // then
    expect(aField?.selectionSet.selections).to(shallowlyMatch(expected))
  }

  func test__selections__givenFieldSelectionsWithSameResponseKey_onObjectWithDifferentChildSelections_mergesChildSelectionsIntoOneField() throws {
    // given
    schema = """
    type Query {
      aField: [A!]
    }

    type A {
      a: A
      b: String
      c: Int
    }
    """

    document = """
    query Test {
      aField {
        a {
          b
        }
        a {
          c
        }
      }
    }
    """

    let expectedAFields: [CompilationResult.Selection] = [
      .field(.mock("b", type: .scalar(.string()))),
      .field(.mock("c", type: .scalar(.integer())))
    ]

    // when
    try buildSubjectOperation()

    let Object_A = try XCTUnwrap(compilationResult[object: "A"])

    let aField = subject[field: "query"]?[field: "aField"] as? IR.EntityField
    let aField_a = aField?[field: "a"] as? IR.EntityField

    // then
    expect(aField?.selectionSet.selections.fields.count).to(equal(1))
    expect(aField?.selectionSet.parentType).to(equal(Object_A))
    expect(aField_a?.selectionSet.parentType).to(equal(Object_A))
    expect(aField_a?.selectionSet.selections).to(shallowlyMatch(expectedAFields))
  }

  func test__selections__givenFieldSelectionsWithSameResponseKey_onObjectWithSameAndDifferentChildSelections_mergesChildSelectionsAndDoesNotDuplicateFields() throws {
    // given
    schema = """
    type Query {
      aField: [A!]
    }

    type A {
      a: A
      b: Int
      c: Boolean
      d: String
    }
    """

    document = """
    query Test {
      aField {
        a {
          b
          c
        }
        a {
          b
          d
        }
      }
    }
    """

    let expectedAFields: [CompilationResult.Selection] = [
      .field(.mock("b", type: GraphQLScalarType.integer())),
      .field(.mock("c", type: GraphQLScalarType.boolean())),
      .field(.mock("d", type: GraphQLScalarType.string())),
    ]

    // when
    try buildSubjectOperation()

    let Object_A = try XCTUnwrap(compilationResult[object: "A"])

    let aField = subject[field: "query"]?[field: "aField"] as? IR.EntityField
    let aField_a = aField?[field: "a"] as? IR.EntityField

    // then
    expect(aField?.selectionSet.selections.fields.count).to(equal(1))
    expect(aField?.selectionSet.parentType).to(equal(Object_A))
    expect(aField_a?.selectionSet.parentType).to(equal(Object_A))
    expect(aField_a?.selectionSet.selections).to(shallowlyMatch(expectedAFields))
  }

  // MARK: Selections - Type Cases

  func test__selections__givenInlineFragment_onSameType_mergesTypeCaseIn() throws {
    // given
    schema = """
    type Query {
      aField: [A!]
    }

    type A {
      a: String
      b: Int
    }
    """

    document = """
    query Test {
      aField {
        a
        ... on A {
          b
        }
      }
    }
    """

    let expected: [CompilationResult.Selection] = [
      .field(.mock("a", type: GraphQLScalarType.string())),
      .field(.mock("b", type: GraphQLScalarType.integer())),
    ]

    // when
    try buildSubjectOperation()

    let aField = subject[field: "query"]?[field: "aField"] as? IR.EntityField

    // then
    expect(aField?.selectionSet.selections).to(shallowlyMatch(expected))
  }

  func test__selections__givenInlineFragment_onMatchingType_mergesTypeCaseIn() throws {
    // given
    schema = """
    type Query {
      bField: [B!]
    }

    interface A {
      a: String
    }

    type B implements A {
      a: String
      b: Int
    }
    """

    document = """
    query Test {
      bField {
        b
        ... on A {
          a
        }
      }
    }
    """

    let expected: [CompilationResult.Selection] = [
      .field(.mock("b", type: GraphQLScalarType.integer())),
      .field(.mock("a", type: GraphQLScalarType.string())),
    ]

    // when
    try buildSubjectOperation()

    let bField = subject[field: "query"]?[field: "bField"] as? IR.EntityField

    // then
    expect(bField?.selectionSet.selections).to(shallowlyMatch(expected))
  }

  func test__selections__givenInlineFragment_onNonMatchingType_doesNotMergeTypeCaseIn() throws {
    // given
    schema = """
    type Query {
      aField: [A!]
    }

    interface A {
      a: String
    }

    type B {
      a: String
      b: Int
    }
    """

    document = """
    query Test {
      aField {
        a
        ... on B {
          b
        }
      }
    }
    """

    // when
    try buildSubjectOperation()

    let aField = subject[field: "query"]?[field: "aField"] as? IR.EntityField
    let aField_asB = aField?[as: "B"]

    // then
    expect(aField?.selectionSet.selections.fields).to(shallowlyMatch([
      .field(.mock("a", type: .string()))
    ]))
    expect(aField?.selectionSet.selections.typeCases.count).to(equal(1))

    expect(aField_asB?.selections).to(shallowlyMatch([
      .field(.mock("b", type: .integer()))
    ]))
  }

  // MARK: Selections - Group Duplicate Type Cases

  func test__selections__givenInlineFragmentsWithSameInterfaceType_deduplicatesSelection() throws {
    // given
    schema = """
    type Query {
      bField: [B!]
    }

    interface A {
      a: String
    }

    type B {
      b: Int
    }
    """

    document = """
    query Test {
      bField {
        ... on A { a }
        ... on A { a }
      }
    }
    """

    // when
    try buildSubjectOperation()

    let Interface_A = try XCTUnwrap(compilationResult[interface: "A"])

    let expected: [CompilationResult.Selection] = [
      .inlineFragment(.mock(parentType: Interface_A))
    ]

    let bField = subject[field: "query"]?[field: "bField"] as? IR.EntityField

    // then
    expect(bField?.selectionSet.selections).to(shallowlyMatch(expected))
  }

  func test__selections__givenInlineFragmentsWithSameObjectType_deduplicatesSelection() throws {
    // given
    schema = """
    type Query {
      bField: [B!]
    }

    type A {
      a: String
    }

    type B {
      b: Int
    }
    """

    document = """
    query Test {
      bField {
        ... on A { a }
        ... on A { a }
      }
    }
    """

    // when
    try buildSubjectOperation()

    let Object_A = try XCTUnwrap(compilationResult[object: "A"])

    let expected: [CompilationResult.Selection] = [
      .inlineFragment(.mock(parentType: Object_A))
    ]

    let bField = subject[field: "query"]?[field: "bField"] as? IR.EntityField

    // then
    expect(bField?.selectionSet.selections).to(shallowlyMatch(expected))
  }

  func test__selections__givenInlineFragmentsWithSameUnionType_deduplicatesSelection() throws {
    // given
    schema = """
    type Query {
      bField: [B!]
    }

    type A {
      a1: String
      a2: String
    }

    union UnionA = A

    type B {
      b: Int
    }
    """

    document = """
    query Test {
      bField {
        ... on UnionA { ...on A { a1 } }
        ... on UnionA { ...on A { a2 } }
      }
    }
    """

    // when
    try buildSubjectOperation()

    let Union_A = try XCTUnwrap(compilationResult[union: "UnionA"])

    let expected: [CompilationResult.Selection] = [
      .inlineFragment(.mock(parentType: Union_A))
    ]

    let bField = subject[field: "query"]?[field: "bField"] as? IR.EntityField

    // then
    expect(bField?.selectionSet.selections).to(shallowlyMatch(expected))
  }

  func test__selections__givenInlineFragmentsWithDifferentType_doesNotDeduplicateSelection() throws {
    schema = """
    type Query {
      objField: [Object!]
    }

    type Object {
      name: String
    }

    interface A {
      a: String
    }

    interface B {
      b: String
    }
    """

    document = """
    query Test {
      objField {
        ... on A { a }
        ... on B { b }
      }
    }
    """

    // when
    try buildSubjectOperation()

    let Interface_A = try XCTUnwrap(compilationResult[interface: "A"])
    let Interface_B = try XCTUnwrap(compilationResult[interface: "B"])

    let expected: [CompilationResult.Selection] = [
      .inlineFragment(.mock(parentType: Interface_A)),
      .inlineFragment(.mock(parentType: Interface_B)),
    ]

    let objField = subject[field: "query"]?[field: "objField"] as? IR.EntityField

    // then
    expect(objField?.selectionSet.selections).to(shallowlyMatch(expected))
  }

  func test__selections__givenInlineFragmentsWithSameType_withSameAndDifferentChildSelections_mergesChildSelectionsIntoOneTypeCaseAndDeduplicatesChildSelections() throws {
    // given
    schema = """
    type Query {
      aField: [A!]
    }

    type A {
      a: A
    }

    interface B {
      b: Int
      c: Boolean
      d: String
    }
    """

    document = """
    query Test {
      aField {
        ... on B {
          b
          c
        }
        ... on B {
          b
          d
        }
      }
    }
    """

    let expected: [CompilationResult.Selection] = [
      .field(.mock("b", type: GraphQLScalarType.integer())),
      .field(.mock("c", type: GraphQLScalarType.boolean())),
      .field(.mock("d", type: GraphQLScalarType.string())),
    ]

    // when
    try buildSubjectOperation()

    let Interface_B = try XCTUnwrap(compilationResult[interface:"B"])

    let aField = subject[field: "query"]?[field: "aField"] as? IR.EntityField
    let aField_asB = aField?[as: "B"]

    // then
    expect(aField_asB?.parentType).to(equal(Interface_B))
    expect(aField_asB?.selections).to(shallowlyMatch(expected))
  }

  // MARK: Selections - Fragments

  func test__selections__givenNamedFragmentWithSelectionSet_onMatchingParentType_hasFragmentSelection() throws {
    // given
    schema = """
    type Query {
      aField: [A!]
    }

    type A {
      a: Int
    }
    """

    document = """
    fragment FragmentA on A {
      a
    }

    query Test {
      aField {
        ...FragmentA
      }
    }
    """

    // when
    try buildSubjectOperation()

    let Object_A = try XCTUnwrap(compilationResult[object: "A"])

    let expected: [CompilationResult.Selection] = [
      .fragmentSpread(.mock("FragmentA", type: Object_A)),
    ]

    let aField = subject[field: "query"]?[field: "aField"] as? IR.EntityField

    // then
    expect(aField?.selectionSet.selections).to(shallowlyMatch(expected))
  }

  // MARK: Selections - Group Duplicate Fragments

  func test__selections__givenNamedFragmentsWithSameName_onMatchingParentType_deduplicatesSelection() throws {
    // given
    schema = """
    type Query {
      aField: [A!]
    }

    type A {
      a: Int
    }
    """

    document = """
    fragment FragmentA on A {
      a
    }

    query Test {
      aField {
        ...FragmentA
        ...FragmentA
      }
    }
    """

    // when
    try buildSubjectOperation()

    let Object_A = try XCTUnwrap(compilationResult[object: "A"])

    let expected: [CompilationResult.Selection] = [
      .fragmentSpread(.mock("FragmentA", type: Object_A)),
    ]

    let aField = subject[field: "query"]?[field: "aField"] as? IR.EntityField

    // then
    expect(aField?.selectionSet.selections).to(shallowlyMatch(expected))
  }

  func test__selections__givenNamedFragmentsWithDifferentNames_onMatchingParentType_doesNotDeduplicateSelection() throws {
    // given
    schema = """
    type Query {
      aField: [A!]
    }

    type A {
      a: Int
      b: String
    }
    """

    document = """
    fragment FragmentA1 on A {
      a
    }

    fragment FragmentA2 on A {
      b
    }

    query Test {
      aField {
        ...FragmentA1
        ...FragmentA2
      }
    }
    """

    // when
    try buildSubjectOperation()

    let Object_A = try XCTUnwrap(compilationResult[object: "A"])

    let expected: [CompilationResult.Selection] = [
      .fragmentSpread(.mock("FragmentA1", type: Object_A)),
      .fragmentSpread(.mock("FragmentA2", type: Object_A)),
    ]

    let aField = subject[field: "query"]?[field: "aField"] as? IR.EntityField

    // then
    expect(aField?.selectionSet.selections).to(shallowlyMatch(expected))
  }

  func test__selections__givenNamedFragmentsWithSameName_onNonMatchingParentType_deduplicatesSelectionIntoSingleTypeCase() throws {
    // given
    schema = """
    type Query {
      aField: [A!]
    }

    type A {
      a: Int
      b: String
    }

    interface B {
      b: String
    }
    """

    document = """
    fragment FragmentB on B {
      b
    }

    query Test {
      aField {
        ...FragmentB
        ...FragmentB
      }
    }
    """

    // when
    try buildSubjectOperation()

    let Interface_B = try XCTUnwrap(compilationResult[interface: "B"])

    let expected: [CompilationResult.Selection] = [
      .fragmentSpread(.mock("FragmentB", type: Interface_B))
    ]

    let aField = subject[field: "query"]?[field: "aField"] as? IR.EntityField

    // then
    expect(aField?.selectionSet.selections.fields.count).to(equal(0))
    expect(aField?.selectionSet.selections.typeCases.count).to(equal(1))
    expect(aField?[as: "B"]?.selections).to(shallowlyMatch(expected))
  }

  func test__selections__givenNamedFragmentsWithDifferentNamesAndSameParentType_onNonMatchingParentType_deduplicatesSelectionIntoSingleTypeCaseWithBothFragments() throws {
    // given
    schema = """
    type Query {
      aField: [A!]
    }

    type A {
      a: Int
    }

    interface B {
      b1: String
      b2: String
    }
    """

    document = """
    fragment FragmentB1 on B {
      b1
    }

    fragment FragmentB2 on B {
      b2
    }

    query Test {
      aField {
        ...FragmentB1
        ...FragmentB2
      }
    }
    """

    // when
    try buildSubjectOperation()

    let Fragment_B1 = try XCTUnwrap(compilationResult[fragment: "FragmentB1"])
    let Fragment_B2 = try XCTUnwrap(compilationResult[fragment: "FragmentB2"])

    let expected: [CompilationResult.Selection] = [
      .fragmentSpread(Fragment_B1),
      .fragmentSpread(Fragment_B2),
    ]

    let aField = subject[field: "query"]?[field: "aField"] as? IR.EntityField

    // then
    expect(aField?.selectionSet.selections.fields.count).to(equal(0))
    expect(aField?.selectionSet.selections.typeCases.count).to(equal(1))
    expect(aField?[as: "B"]?.selections).to(shallowlyMatch(expected))
  }

  func test__selections__givenNamedFragmentsWithDifferentNamesAndDifferentParentType_onNonMatchingParentType_doesNotDeduplicate_hasTypeCaseForEachFragment() throws {
    // given
    schema = """
    type Query {
      aField: [A!]
    }

    type A {
      a: Int
    }

    interface B {
      b: String
    }

    interface C {
      c: String
    }
    """

    document = """
    fragment FragmentB on B {
      b
    }

    fragment FragmentC on C {
      c
    }

    query Test {
      aField {
        ...FragmentB
        ...FragmentC
      }
    }
    """

    // when
    try buildSubjectOperation()

    let Fragment_B = try XCTUnwrap(compilationResult[fragment: "FragmentB"])
    let Fragment_C = try XCTUnwrap(compilationResult[fragment: "FragmentC"])

    let aField = subject[field: "query"]?[field: "aField"] as? IR.EntityField

    // then
    expect(aField?.selectionSet.selections.fields.count).to(equal(0))
    expect(aField?.selectionSet.selections.typeCases.count).to(equal(2))
    expect(aField?[as: "B"]?.selections).to(shallowlyMatch([.fragmentSpread(Fragment_B)]))
    expect(aField?[as: "C"]?.selections).to(shallowlyMatch([.fragmentSpread(Fragment_C)]))
  }

  // MARK: - Merged Selections

  func test__mergedSelections__givenSelectionSetWithSelections_returnsSelections() throws {
    // given
    schema = """
    type Query {
      aField: [A!]
    }

    type A {
      a: Int
    }
    """

    document = """
    query Test {
      aField {
        a
      }
    }
    """

    // when
    try buildSubjectOperation()

    let expected: [CompilationResult.Selection] = [
      .field(.mock("a", type: .scalar(.integer())))
    ]

    let aField = subject[field: "query"]?[field: "aField"] as? IR.EntityField

    // then
    expect(aField?.selectionSet.mergedSelections).to(shallowlyMatch(expected))
  }

  func test__mergedSelections__givenSelectionSetWithSelectionsAndParentFields_returnsSelfAndParentFields() throws {
    // given
    schema = """
    type Query {
      aField: [A!]
    }

    type A {
      a: Int
    }

    type B {
      b: Int
    }
    """

    document = """
    query Test {
      aField {
        a
        ... on B {
          b
        }
      }
    }
    """

    let expected: [CompilationResult.Selection] = [
      .field(.mock("b", type: .scalar(.integer()))),
      .field(.mock("a", type: .scalar(.integer()))),
    ]

    // when
    try buildSubjectOperation()

    let actual = subject[field: "query"]?[field: "aField"]?[as: "B"]?.mergedSelections

    // then
    expect(actual).to(shallowlyMatch(expected))
  }

  // MARK: - Merged Selections - Siblings

  // MARK: Merged Selections - Siblings - Object Type <-> Object Type

  func test__mergedSelections__givenIsObjectType_siblingSelectionSetIsTheSameObjectType_mergesSiblingSelections() throws {
    // given
    schema = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String
    }

    type Bird implements Animal {
      species: String
      wingspan: Int
    }
    """

    document = """
    query Test {
      allAnimals {
        ... on Bird {
          wingspan
        }
        ... on Bird {
          species
        }
      }
    }
    """

    let expected: [CompilationResult.Selection] = [
      .field(.mock("wingspan", type: .scalar(.integer()))),
      .field(.mock("species", type: .scalar(.string()))),
    ]

    // when
    try buildSubjectOperation()

    let allAnimals = subject[field: "query"]?[field: "allAnimals"]
    let actual = allAnimals?[as: "Bird"]?.mergedSelections

    // then
    expect(allAnimals?.selectionSet?.selections.typeCases.count).to(equal(1))
    expect(actual).to(shallowlyMatch(expected))
  }

  func test__mergedSelections__givenIsObjectType_siblingSelectionSetIsDifferentObjectType_doesNotMergesSiblingSelections() throws {
    // given
    schema = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String
    }

    type Bird implements Animal {
      species: String
      wingspan: Int
    }

    type Cat implements Animal {
      species: String
    }
    """

    document = """
    query Test {
      allAnimals {
        ... on Bird {
          wingspan
        }
        ... on Cat {
          species
        }
      }
    }
    """

    let asBirdExpected: [CompilationResult.Selection] = [
      .field(.mock("wingspan", type: .scalar(.integer()))),
    ]
    let asCatExpected: [CompilationResult.Selection] = [
      .field(.mock("species", type: .scalar(.string()))),
    ]

    // when
    try buildSubjectOperation()

    let allAnimals = subject[field: "query"]?[field: "allAnimals"]
    let asBird = allAnimals?[as: "Bird"]?.mergedSelections
    let asCat = allAnimals?[as: "Cat"]?.mergedSelections

    // then
    expect(asBird).to(shallowlyMatch(asBirdExpected))
    expect(asCat).to(shallowlyMatch(asCatExpected))
  }

  // MARK: Merged Selections - Siblings - Object Type -> Interface Type

  func test__mergedSelections__givenIsObjectType_siblingSelectionSetIsImplementedInterface_mergesSiblingSelections() throws {
    // given
    schema = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String
    }

    interface Pet {
      species: String
    }

    type Bird implements Pet {
      species: String
      wingspan: Int
    }
    """

    document = """
    query Test {
      allAnimals {
        ... on Bird {
          wingspan
        }
        ... on Pet {
          species
        }
      }
    }
    """

    let asBirdExpected: [CompilationResult.Selection] = [
      .field(.mock("wingspan", type: .scalar(.integer()))),
      .field(.mock("species", type: .scalar(.string()))),
    ]

    let asPetExpected: [CompilationResult.Selection] = [
      .field(.mock("species", type: .scalar(.string()))),
    ]

    // when
    try buildSubjectOperation()

    let allAnimals = subject[field: "query"]?[field: "allAnimals"]
    let asBird = allAnimals?[as: "Bird"]?.mergedSelections
    let asPet = allAnimals?[as: "Pet"]?.mergedSelections

    // then
    expect(asBird).to(shallowlyMatch(asBirdExpected))
    expect(asPet).to(shallowlyMatch(asPetExpected))
  }

  func test__mergedSelections__givenIsObjectType_siblingSelectionSetIsUnimplementedInterface_doesNotMergeSiblingSelections() throws {
    // given
    schema = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String
    }

    interface Pet {
      species: String
    }

    type Bird {
      species: String
      wingspan: Int
    }
    """

    document = """
    query Test {
      allAnimals {
        ... on Bird {
          wingspan
        }
        ... on Pet { # Bird does not implement Pet
          species
        }
      }
    }
    """

    let asBirdExpected: [CompilationResult.Selection] = [
      .field(.mock("wingspan", type: .scalar(.integer()))),
    ]

    let asPetExpected: [CompilationResult.Selection] = [
      .field(.mock("species", type: .scalar(.string()))),
    ]

    // when
    try buildSubjectOperation()

    let allAnimals = subject[field: "query"]?[field: "allAnimals"]
    let asBird = allAnimals?[as: "Bird"]?.mergedSelections
    let asPet = allAnimals?[as: "Pet"]?.mergedSelections

    // then
    expect(asBird).to(shallowlyMatch(asBirdExpected))
    expect(asPet).to(shallowlyMatch(asPetExpected))
  }

  // MARK: Merged Selections - Siblings - Interface Type -> Interface Type

  func test__mergedSelections__givenIsInterfaceType_siblingSelectionSetIsImplementedInterface_mergesSiblingSelections() throws {
    // given
    schema = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String
    }

    interface Pet {
      species: String
    }

    interface HousePet implements Pet {
      species: String
      humanName: String
    }
    """

    document = """
    query Test {
      allAnimals {
        ... on HousePet {
          humanName
        }
        ... on Pet { # HousePet Implements Pet
          species
        }
      }
    }
    """

    let asHousePetExpected: [CompilationResult.Selection] = [
      .field(.mock("humanName", type: .scalar(.string()))),
      .field(.mock("species", type: .scalar(.string()))),
    ]

    let asPetExpected: [CompilationResult.Selection] = [
      .field(.mock("species", type: .scalar(.string()))),
    ]

    // when
    try buildSubjectOperation()

    let allAnimals = subject[field: "query"]?[field: "allAnimals"]
    let asHousePet = allAnimals?[as: "HousePet"]?.mergedSelections
    let asPet = allAnimals?[as: "Pet"]?.mergedSelections

    // then
    expect(asHousePet).to(shallowlyMatch(asHousePetExpected))
    expect(asPet).to(shallowlyMatch(asPetExpected))
  }

  func test__mergedSelections__givenIsInterfaceType_siblingSelectionSetIsUnimplementedInterface_doesNotMergeSiblingSelections() throws {
    // given
    schema = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String
    }

    interface Pet {
      species: String
    }

    interface HousePet {
      humanName: String
    }
    """

    document = """
    query Test {
      allAnimals {
        ... on HousePet {
          humanName
        }
        ... on Pet { # HousePet does not implement Pet
          species
        }
      }
    }
    """

    let asHousePetExpected: [CompilationResult.Selection] = [
      .field(.mock("humanName", type: .scalar(.string()))),
    ]

    let asPetExpected: [CompilationResult.Selection] = [
      .field(.mock("species", type: .scalar(.string()))),
    ]

    // when
    try buildSubjectOperation()

    let allAnimals = subject[field: "query"]?[field: "allAnimals"]
    let asHousePet = allAnimals?[as: "HousePet"]?.mergedSelections
    let asPet = allAnimals?[as: "Pet"]?.mergedSelections

    // then
    expect(asHousePet).to(shallowlyMatch(asHousePetExpected))
    expect(asPet).to(shallowlyMatch(asPetExpected))
  }

  // MARK: - Merged Selections - Parent's Sibling

  func test__mergedSelections__givenIsNestedInterfaceType_uncleSelectionSetIsTheSameInterfaceType_mergesUncleSelections() throws {
    // given
    schema = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String
    }

    interface WarmBlooded {
      bodyTemperature: Int
    }

    interface Pet implements Animal {
      species: String
      humanName: String
    }
    """

    document = """
    query Test {
      allAnimals {
        ... on WarmBlooded {
          ... on Pet {
            humanName
          }
        }
        ... on Pet {
          species
        }
      }
    }
    """

    let onWarmBlooded_onPet_expected: [CompilationResult.Selection] = [.field(.mock("humanName", type: .string())),
      CompilationResult.Selection.field(.mock("species", type: .string()))
    ]

    let onPet_expected: [CompilationResult.Selection] = [.field(.mock("species", type: .string()))
    ]

    // when
    try buildSubjectOperation()

    let allAnimals = subject[field: "query"]?[field: "allAnimals"]

    let onWarmBlooded_onPet_actual = allAnimals?[as:"WarmBlooded"]?[as: "Pet"]?
      .mergedSelections

    let onPet_actual = allAnimals?[as: "Pet"]?
      .mergedSelections

    // then
    expect(onWarmBlooded_onPet_actual).to(shallowlyMatch(onWarmBlooded_onPet_expected))
    expect(onPet_actual).to(shallowlyMatch(onPet_expected))
  }

  func test__mergedSelections__givenIsObjectInInterfaceType_uncleSelectionSetIsMatchingInterfaceType_mergesUncleSelections() throws {
    // given
    schema = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String
    }

    interface WarmBlooded {
      bodyTemperature: Int
    }

    interface Pet {
      humanName: String
      species: String
    }

    type Bird implements Pet {
      wingspan: Int
      humanName: String
      species: String
    }
    """

    document = """
    query Test {
      allAnimals {
        ... on WarmBlooded {
          ... on Bird {
            wingspan
          }
        }
        ... on Pet { # Bird Implements Pet
          species
        }
      }
    }
    """

    let onWarmBlooded_onBird_expected: [CompilationResult.Selection] = [.field(.mock("wingspan", type: .integer())),
      CompilationResult.Selection.field(.mock("species", type: .string()))
    ]

    let onPet_expected: [CompilationResult.Selection] = [.field(.mock("species", type: .string()))
    ]

    // when
    try buildSubjectOperation()

    let allAnimals = subject[field: "query"]?[field: "allAnimals"]

    let asWarmBlooded_asBird_actual = allAnimals?[as: "WarmBlooded"]?[as: "Bird"]?
      .mergedSelections

    let asPet_actual = allAnimals?[as: "Pet"]?
      .mergedSelections

    // then
    expect(asWarmBlooded_asBird_actual).to(shallowlyMatch(onWarmBlooded_onBird_expected))
    expect(asPet_actual).to(shallowlyMatch(onPet_expected))
  }

  func test__mergedSelections__givenIsObjectInInterfaceType_uncleSelectionSetIsNonMatchingInterfaceType_doesNotMergeUncleSelections() throws {
    // given
    schema = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String
    }

    interface WarmBlooded {
      bodyTemperature: Int
    }

    interface Pet {
      humanName: String
      species: String
    }

    type Bird {
      wingspan: Int
    }
    """

    document = """
    query Test {
      allAnimals {
        ... on WarmBlooded {
          ... on Bird {
            wingspan
          }
        }
        ... on Pet { # Bird Does Not Implement Pet
          species
        }
      }
    }
    """

    let asWarmBlooded_asBird_expected: [CompilationResult.Selection] = [.field(.mock("wingspan", type: .integer())),
    ]

    let asPet_expected: [CompilationResult.Selection] = [.field(.mock("species", type: .string()))
    ]

    // when
    try buildSubjectOperation()

    let allAnimals = subject[field: "query"]?[field: "allAnimals"]

    let asWarmBlooded_asBird_actual = allAnimals?[as: "WarmBlooded"]?[as: "Bird"]?
      .mergedSelections

    let asPet_actual = allAnimals?[as: "Pet"]?
      .mergedSelections

    // then
    expect(asWarmBlooded_asBird_actual).to(shallowlyMatch(asWarmBlooded_asBird_expected))
    expect(asPet_actual).to(shallowlyMatch(asPet_expected))
  }

  // MARK: Merged Selections - Parent's Sibling - Object Type <-> Object in Union Type

  func test__mergedSelections__givenIsObjectType_siblingSelectionSetIsUnionTypeWithNestedTypeCaseOfSameObjectType_mergesSiblingChildSelectionsInBothDirections() throws {
    // given
    schema = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String
    }

    type Bird implements Animal {
      wingspan: Int
      species: String
    }

    union ClassroomPet = Bird
    """

    document = """
    query Test {
      allAnimals {
        ... on Bird {
          wingspan
        }
        ... on ClassroomPet {
          ... on Bird {
            species
          }
        }
      }
    }
    """

    let Field_Wingspan: CompilationResult.Selection =
      .field(.mock("wingspan", type: .integer()))
    let Field_Species: CompilationResult.Selection =
      .field(.mock("species", type: .string()))

    let asBirdExpected = [
      Field_Wingspan,
      Field_Species
    ]

    let asClassroomPet_asBirdExpected = [
      Field_Species,
      Field_Wingspan
    ]

    // when
    try buildSubjectOperation()

    let allAnimals = subject[field: "query"]?[field: "allAnimals"]

    let asBirdActual = allAnimals?[as: "Bird"]?.mergedSelections
    let asClassroomPet_asBirdActual = allAnimals?[as: "ClassroomPet"]?[as: "Bird"]?
      .mergedSelections

    // then
    expect(asBirdActual).to(shallowlyMatch(asBirdExpected))
    expect(asClassroomPet_asBirdActual).to(shallowlyMatch(asClassroomPet_asBirdExpected))
  }

  func test__mergedSelections__givenIsObjectType_siblingSelectionSetIsUnionTypeWithNestedTypeCaseOfDifferentObjectType_doesNotMergeSiblingChildSelectionsInEitherDirection() throws {
    // given
    schema = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String
    }

    type Bird implements Animal {
      wingspan: Int
      species: String
    }

    type Cat implements Animal {
      species: String
    }

    union ClassroomPet = Bird | Cat
    """

    document = """
    query Test {
      allAnimals {
        ... on Bird {
          wingspan
        }
        ... on ClassroomPet {
          ... on Cat {
            species
          }
        }
      }
    }
    """

    let Field_Wingspan: CompilationResult.Selection =
      .field(.mock("wingspan", type: .integer()))
    let Field_Species: CompilationResult.Selection =
      .field(.mock("species", type: .string()))

    let asBirdExpected = [
      Field_Wingspan
    ]

    let asClassroomPet_asCatExpected = [
      Field_Species
    ]

    // when
    try buildSubjectOperation()

    let allAnimals = subject[field: "query"]?[field: "allAnimals"]

    let asBirdActual = allAnimals?[as: "Bird"]?.mergedSelections
    let asClassroomPet_asCatActual = allAnimals?[as: "ClassroomPet"]?[as: "Cat"]?
      .mergedSelections

    // then
    expect(asBirdActual).to(shallowlyMatch(asBirdExpected))
    expect(asClassroomPet_asCatActual).to(shallowlyMatch(asClassroomPet_asCatExpected))
  }

  // MARK: Merged Selections - Parent's Sibling - Interface in Union Type

  func test__mergedSelections__givenInterfaceTypeInUnion_uncleSelectionSetIsMatchingInterfaceType_mergesUncleSelections() throws {
    // given
    schema = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String
    }

    interface WarmBlooded implements Animal {
      bodyTemperature: Int
      species: String
    }

    type Bird implements Animal {
      wingspan: Int
      species: String
    }

    union ClassroomPet = Bird
    """

    document = """
    query Test {
      allAnimals {
        ... on WarmBlooded {
          bodyTemperature
        }
        ... on ClassroomPet {
          ... on WarmBlooded {
            species
          }
        }
      }
    }
    """

    let asWarmBlooded_expected: [CompilationResult.Selection] = [
      .field(.mock("bodyTemperature", type: .integer())),
    ]

    let asClassroomPet_asWarmBlooded_expected: [CompilationResult.Selection] = [
      .field(.mock("species", type: .string())),
      .field(.mock("bodyTemperature", type: .integer())),
    ]

    // when
    try buildSubjectOperation()

    let allAnimals = subject[field: "query"]?[field: "allAnimals"]

    let asWarmBlooded_actual = allAnimals?[as: "WarmBlooded"]!
      .mergedSelections

    let asClassroomPet_asWarmBlooded_actual = allAnimals?[as: "ClassroomPet"]?[as: "WarmBlooded"]?
      .mergedSelections

    // then
    expect(asWarmBlooded_actual).to(shallowlyMatch(asWarmBlooded_expected))
    expect(asClassroomPet_asWarmBlooded_actual).to(shallowlyMatch(asClassroomPet_asWarmBlooded_expected))
  }

  func test__mergedSelections__givenInterfaceTypeInUnion_uncleSelectionSetIsChildMatchingInterfaceType_mergesUncleSelections() throws {
    // given
    schema = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String
    }

    interface Pet {
      humanName: String
      species: String
    }

    interface WarmBloodedPet implements Pet {
      bodyTemperature: Int
      species: String
      humanName: String
    }

    type Cat implements WarmBloodedPet & Pet {
      bodyTemperature: Int
      species: String
      humanName: String
    }

    union ClassroomPet = Cat
    """

    document = """
    query Test {
     allAnimals {
       ... on Pet {
         humanName
       }
       ... on ClassroomPet {
         ... on WarmBloodedPet { # WarmBloodedPet implements Pet
           species
         }
       }
      }
    }
    """

    let asPet_expected: [CompilationResult.Selection] = [
      .field(.mock("humanName", type: .string())),
    ]

    let asClassroomPet_asWarmBloodedPet_expected: [CompilationResult.Selection] = [
      .field(.mock("species", type: .string())),
      .field(.mock("humanName", type: .string())),
    ]

    // when
    try buildSubjectOperation()

    let allAnimals = subject[field: "query"]?[field: "allAnimals"]

    let asPet_actual = allAnimals?[as: "Pet"]?
      .mergedSelections

    let asClassroomPet_asWarmBloodedPet_actual = allAnimals?[as: "ClassroomPet"]?[as: "WarmBloodedPet"]?
      .mergedSelections

    // then
    expect(asPet_actual).to(shallowlyMatch(asPet_expected))
    expect(asClassroomPet_asWarmBloodedPet_actual).to(shallowlyMatch(asClassroomPet_asWarmBloodedPet_expected))
  }

  func test__mergedSelections__givenInterfaceTypeInUnion_uncleSelectionSetIsNonMatchingInterfaceType_doesNotMergesUncleSelections() throws {
    // given
    schema = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String!
    }

    interface Pet {
      humanName: String
      species: String
    }

    interface WarmBlooded {
      bodyTemperature: Int
      species: String
      humanName: String
    }

    type Cat implements WarmBlooded & Pet {
      bodyTemperature: Int
      species: String
      humanName: String
    }

    union ClassroomPet = Cat
    """

    document = """
    query Test {
      allAnimals {
        ... on WarmBlooded {
          bodyTemperature
        }
        ... on ClassroomPet {
          ... on Pet {
            species
          }
        }
      }
    }
    """

    let asWarmBlooded_expected: [CompilationResult.Selection] = [
      .field(.mock("bodyTemperature", type: .integer())),
    ]

    let asClassroomPet_asPet_expected: [CompilationResult.Selection] = [
      .field(.mock("species", type: .string())),
    ]

    // when
    try buildSubjectOperation()

    let allAnimals = subject[field: "query"]?[field: "allAnimals"]

    let asWarmBlooded_actual = allAnimals?[as: "WarmBlooded"]?
      .mergedSelections

    let asClassroomPet_asPet_actual = allAnimals?[as: "ClassroomPet"]?[as: "Pet"]?
      .mergedSelections

    // then
    expect(asWarmBlooded_actual).to(shallowlyMatch(asWarmBlooded_expected))
    expect(asClassroomPet_asPet_actual).to(shallowlyMatch(asClassroomPet_asPet_expected))
  }

  // MARK: - Merged Selections - Child Fragment

  func test__mergedSelections__givenChildIsNamedFragmentOnSameType_mergesFragmentFieldsAndMaintainsFragment() throws {
    // given
    schema = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String
    }
    """

    document = """
    query Test {
      allAnimals {
        ...AnimalDetails
      }
    }

    fragment AnimalDetails on Animal {
      species
    }
    """

    // when
    try buildSubjectOperation()

    let Field_Species = CompilationResult.Field.mock("species", type: .string())

    let Fragment_AnimalDetails = try XCTUnwrap(compilationResult[fragment: "AnimalDetails"])

    let expected: [CompilationResult.Selection] = [
      .field(Field_Species),
      .fragmentSpread(Fragment_AnimalDetails)
    ]

    let allAnimals = subject[field: "query"]?[field: "allAnimals"]
    let actual = allAnimals?.selectionSet?.mergedSelections

    // then
    expect(actual).to(shallowlyMatch(expected))
  }

  func test__mergedSelections__givenChildIsNamedFragmentOnMoreSpecificType_doesNotMergeFragmentFields_hasTypeCaseForNamedFragmentType() throws {
    // given
    schema = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String
    }

    type Bird implements Animal {
      species: String
    }
    """

    document = """
    query Test {
      allAnimals {
        ...BirdDetails
      }
    }

    fragment BirdDetails on Bird {
      species
    }
    """

    // when
    try buildSubjectOperation()

    let Object_Bird = try XCTUnwrap(compilationResult[object: "Bird"])
    let Fragment_BirdDetails = try XCTUnwrap(compilationResult[fragment: "BirdDetails"])

    let expected: [CompilationResult.Selection] = [
      .inlineFragment(.init(parentType: Object_Bird,
                            selections: [.fragmentSpread(Fragment_BirdDetails)]))
    ]

    let allAnimals = subject[field: "query"]?[field: "allAnimals"]
    let actual = allAnimals?.selectionSet?.mergedSelections

    // then
    expect(actual).to(shallowlyMatch(expected))
  }

  func test__mergedSelections__givenIsObjectType_childIsNamedFragmentOnLessSpecificMatchingType_mergesFragmentFields() throws {
    // given
    schema = """
    type Query {
      birds: [Bird!]
    }

    interface Animal {
      species: String
    }

    type Bird implements Animal {
      species: String
    }
    """

    document = """
    fragment AnimalDetails on Animal {
      species
    }

    query Test {
      birds {
        ...AnimalDetails
      }
    }
    """

    // when
    try buildSubjectOperation()

    let Field_Species = CompilationResult.Field.mock("species", type: .string())
    let Fragment_AnimalDetails = try XCTUnwrap(compilationResult[fragment: "AnimalDetails"])

    let expected: [CompilationResult.Selection] = [
      .field(Field_Species),
      .fragmentSpread(Fragment_AnimalDetails)
    ]

    let birds = subject[field: "query"]?[field: "birds"]
    let actual = birds?.selectionSet?.mergedSelections

    // then
    expect(actual).to(shallowlyMatch(expected))
  }

  func test__mergedSelections__givenIsInterfaceType_childIsNamedFragmentOnLessSpecificMatchingType_mergesFragmentFields() throws {
    // given
    schema = """
    type Query {
      flyingAnimals: [Animal!]
    }

    interface Animal {
      species: String
    }

    interface FlyingAnimal implements Animal {
      species: String
    }
    """

    document = """
    fragment AnimalDetails on Animal {
      species
    }

    query Test {
      flyingAnimals {
        ...AnimalDetails
      }
    }
    """

    // when
    try buildSubjectOperation()

    let Field_Species = CompilationResult.Field.mock("species", type: .string())
    let Fragment_AnimalDetails = try XCTUnwrap(compilationResult[fragment: "AnimalDetails"])

    let expected: [CompilationResult.Selection] = [
      .field(Field_Species),
      .fragmentSpread(Fragment_AnimalDetails)
    ]

    let flyingAnimals = subject[field: "query"]?[field: "flyingAnimals"]
    let actual = flyingAnimals?.selectionSet?.mergedSelections

    // then
    expect(actual).to(shallowlyMatch(expected))
  }

  func test__mergedSelections__givenChildIsNamedFragmentOnUnrelatedType_doesNotMergeFragmentFields_hasTypeCaseForNamedFragmentType() throws {
    // given
    schema = """
    type Query {
      rocks: [Rock!]
    }

    interface Animal {
      species: String
    }

    type Bird implements Animal {
      species: String
    }

    type Rock {
      name: String
    }
    """

    document = """
    fragment BirdDetails on Bird {
      species
    }

    query Test {
      rocks {
        ...BirdDetails
      }
    }
    """

    // when
    try buildSubjectOperation()

    let Object_Bird = try XCTUnwrap(compilationResult[object: "Bird"])

    let Fragment_BirdDetails = try XCTUnwrap(compilationResult[fragment: "BirdDetails"])

    let expected: [CompilationResult.Selection] = [
      .inlineFragment(.init(parentType: Object_Bird,
                            selections: [.fragmentSpread(Fragment_BirdDetails)]))
    ]

    let rocks = subject[field: "query"]?[field: "rocks"]
    let actual = rocks?.selectionSet?.mergedSelections

    // then
    expect(actual).to(shallowlyMatch(expected))
  }

  // MARK: - Nested Entity Field - Merged Selections

  func test__mergedSelections__givenEntityFieldOnObjectAndTypeCase_withOtherNestedFieldInTypeCase_mergesParentFieldIntoNestedSelectionsInTypeCase() throws {
    // given
    schema = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      height: Height
    }

    interface Pet implements Animal {
      height: Height
    }

    type Height {
      feet: Int
      meters: Int
    }
    """

    document = """
    query Test {
      allAnimals {
        height {
          feet
        }
        ... on Pet {
          height {
            meters
          }
        }
      }
    }
    """

    // when
    try buildSubjectOperation()

    let allAnimals = subject[field: "query"]?[field: "allAnimals"]

    let allAnimals_expected: [CompilationResult.Selection] = [
      .field(.mock("feet", type: .integer()))
    ]

    let allAnimals_asPet_expected: [CompilationResult.Selection] = [
      .field(.mock("meters", type: .integer())),
      .field(.mock("feet", type: .integer())),
    ]

    let allAnimals_height_actual = allAnimals?[field: "height"]?.selectionSet?.mergedSelections
    let allAnimals_asPet_height_actual = allAnimals?[as: "Pet"]?[field: "height"]?.selectionSet?.mergedSelections

    // then
    expect(allAnimals_height_actual).to(shallowlyMatch(allAnimals_expected))
    expect(allAnimals_asPet_height_actual).to(shallowlyMatch(allAnimals_asPet_expected))
  }

  func test__mergedSelections__givenEntityFieldOnObjectWithSelectionSetIncludingSameFieldNameAndDifferentSelections_doesNotMergeFieldIntoNestedFieldsSelections() throws {
    // given
    schema = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      height: Height
      predators: [Animal!]
    }

    type Height {
      feet: Int
      meters: Int
    }
    """

    document = """
    query Test {
      allAnimals {
        height {
          feet
        }
        predators {
          height {
            meters
          }
        }
      }
    }
    """

    // when
    try buildSubjectOperation()

    let allAnimals = subject[field: "query"]?[field: "allAnimals"]

    let allAnimals_expected: [CompilationResult.Selection] = [
      .field(.mock("feet", type: .integer()))
    ]

    let predators_expected: [CompilationResult.Selection] = [
      .field(.mock("meters", type: .integer())),
    ]

    let allAnimals_height_actual = allAnimals?[field: "height"]?.selectionSet?.mergedSelections
    let predators_height_actual = allAnimals?[field: "predators"]?[field: "height"]?.selectionSet?.mergedSelections

    // then
    expect(allAnimals_height_actual).to(shallowlyMatch(allAnimals_expected))
    expect(predators_height_actual).to(shallowlyMatch(predators_expected))
  }

  func test__mergedSelections__givenEntityFieldOnInterfaceAndTypeCase_withOtherNestedFieldInTypeCase_mergesParentFieldIntoNestedSelectionsInObjectTypeCaseMatchingInterfaceTypeCase() throws {
    // given
    schema = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String
      height: Height
    }

    interface Pet implements Animal {
      height: Height
      species: String
    }

    type Cat implements Pet & Animal {
      species: String
      height: Height
    }

    type Height {
      feet: Int
      meters: Int
    }
    """

    document = """
    query Test {
      allAnimals {
        height {
          feet
        }
        ... on Pet {
          height {
            meters
          }
        }
        ... on Cat {
          species
        }
      }
    }
    """

    // when
    try buildSubjectOperation()

    let allAnimals = subject[field: "query"]?[field: "allAnimals"]

    let allAnimals_asCat_expected: [CompilationResult.Selection] = [
      .field(.mock("feet", type: .integer())),
      .field(.mock("meters", type: .integer())),
    ]

    let allAnimals_asCat_height_actual = allAnimals?[as: "Cat"]?[field: "height"]?.selectionSet?.mergedSelections

    // then
    expect(allAnimals_asCat_height_actual).to(shallowlyMatch(allAnimals_asCat_expected))
  }

  func test__mergedSelections__givenEntityFieldOnInterfaceAndTypeCase_withOtherNestedFieldInTypeCase_doesNotMergeParentFieldIntoNestedSelectionsInObjectTypeCaseNotMatchingInterfaceTypeCase() throws {
    // given
    schema = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String
      height: Height
    }

    interface Pet implements Animal {
      height: Height
      species: String
    }

    type Elephant implements Animal {
      species: String
      height: Height
    }

    type Height {
      feet: Int
      meters: Int
    }
    """

    document = """
    query Test {
      allAnimals {
        height {
          feet
        }
        ... on Pet {
          height {
            meters
          }
        }
        ... on Elephant { # does not implement Pet
          species
        }
      }
    }
    """

    // when
    try buildSubjectOperation()

    let allAnimals = subject[field: "query"]?[field: "allAnimals"]

    let allAnimals_asElephant_expected: [CompilationResult.Selection] = [
      .field(.mock("feet", type: .integer()))
    ]

    let allAnimals_asElephant_height_actual = allAnimals?[as: "Elephant"]?[field: "height"]?.selectionSet?.mergedSelections

    // then
    expect(allAnimals_asElephant_height_actual).to(shallowlyMatch(allAnimals_asElephant_expected))
  }

  func test__mergedSelections__givenEntityFieldOnEntityWithDeepNestedTypeCases_eachTypeCaseHasDifferentNestedEntityFields_mergesFieldIntoMatchingNestedTypeCases() throws {
    // given
    schema = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String
      height: Height
    }

    interface Pet implements Animal {
      height: Height
      species: String
    }

    interface WarmBlooded {
      height: Height
    }

    type Height {
      feet: Int
      meters: Int
      inches: Int
      yards: Int
    }
    """

    document = """
    query Test {
      allAnimals {
        height {
          feet
        }
        ... on Pet {
          height {
            meters
          }
          ... on WarmBlooded {
            height {
              inches
            }
          }
        }
        ... on WarmBlooded {
          height {
            yards
          }
        }
      }
    }
    """

    // when
    try buildSubjectOperation()

    let allAnimals = subject[field: "query"]?[field: "allAnimals"]

    let allAnimals_height_expected: [CompilationResult.Selection] = [
      .field(.mock("feet", type: .integer()))
    ]

    let allAnimals_asPet_height_expected: [CompilationResult.Selection] = [
      .field(.mock("meters", type: .integer())),
      .field(.mock("feet", type: .integer())),
    ]

    let allAnimals_asPet_asWarmBlooded_height_expected: [CompilationResult.Selection] = [
      .field(.mock("inches", type: .integer())),
      .field(.mock("feet", type: .integer())),
      .field(.mock("meters", type: .integer())),
      .field(.mock("yards", type: .integer())),
    ]

    let allAnimals_asWarmBlooded_height_expected: [CompilationResult.Selection] = [
      .field(.mock("yards", type: .integer())),
      .field(.mock("feet", type: .integer())),
    ]

    let allAnimals_height_actual = allAnimals?[field: "height"]?.selectionSet?.mergedSelections

    let allAnimals_asPet_height_actual =
    allAnimals?[as: "Pet"]?[field: "height"]?.selectionSet?.mergedSelections

    let allAnimals_asPet_asWarmBlooded_height_actual =
    allAnimals?[as: "Pet"]?[as: "WarmBlooded"]?[field: "height"]?.selectionSet?.mergedSelections

    let allAnimals_asWarmBlooded_height_actual =
    allAnimals?[as: "WarmBlooded"]?[field: "height"]?.selectionSet?.mergedSelections

    // then
    expect(allAnimals_height_actual)
      .to(shallowlyMatch(allAnimals_height_expected))
    expect(allAnimals_asPet_height_actual)
      .to(shallowlyMatch(allAnimals_asPet_height_expected))
    expect(allAnimals_asPet_asWarmBlooded_height_actual)
      .to(shallowlyMatch(allAnimals_asPet_asWarmBlooded_height_expected))
    expect(allAnimals_asWarmBlooded_height_actual)
      .to(shallowlyMatch(allAnimals_asWarmBlooded_height_expected))
  }

  // MARK: - Referenced Fragments

  func test__referencedFragments__givenUsesNoFragments_isEmpty() throws {
    // given
    schema = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String
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

    // then
    expect(self.subject.referencedFragments).to(beEmpty())
  }

  func test__referencedFragments__givenUsesFragmentAtRoot_includesFragment() throws {
    // given
    schema = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String
    }
    """

    document = """
    fragment QueryDetails on Query {
      allAnimals {
        species
      }
    }

    query Test {
      ...QueryDetails
    }
    """

    // when
    try buildSubjectOperation()

    let expected: OrderedSet = [
      try compilationResult[fragment: "QueryDetails"].xctUnwrapped
    ]

    // then
    expect(self.subject.referencedFragments).to(equal(expected))
  }

  func test__referencedFragments__givenUsesFragmentOnEntityField_includesFragment() throws {
    // given
    schema = """
    type Query {
      allAnimals: [Animal!]
    }

    interface Animal {
      species: String
    }
    """

    document = """
    fragment AnimalDetails on Animal {
      species
    }

    query Test {
      allAnimals {
        ...AnimalDetails
      }
    }
    """

    // when
    try buildSubjectOperation()

    let expected: OrderedSet = [
      try compilationResult[fragment: "AnimalDetails"].xctUnwrapped
    ]

    // then
    expect(self.subject.referencedFragments).to(equal(expected))
  }

  func test__referencedFragments__givenUsesMultipleFragmentsOnEntityField_includesFragments() throws {
    // given
    schema = """
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
    }

    fragment AnimalName on Animal {
      name
    }

    query Test {
      allAnimals {
        ...AnimalDetails
        ...AnimalName
      }
    }
    """

    // when
    try buildSubjectOperation()

    let expected: OrderedSet = [
      try compilationResult[fragment: "AnimalDetails"].xctUnwrapped,
      try compilationResult[fragment: "AnimalName"].xctUnwrapped,
    ]

    // then
    expect(self.subject.referencedFragments).to(equal(expected))
  }

  func test__referencedFragments__givenUsesFragmentsReferencingOtherFragment_includesBothFragments() throws {
    // given
    schema = """
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

    query Test {
      allAnimals {
        ...AnimalDetails
      }
    }
    """

    // when
    try buildSubjectOperation()

    let expected: OrderedSet = [
      try compilationResult[fragment: "AnimalDetails"].xctUnwrapped,
      try compilationResult[fragment: "AnimalName"].xctUnwrapped,
    ]

    // then
    expect(self.subject.referencedFragments).to(equal(expected))
  }
}
