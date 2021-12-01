import XCTest
import Nimble
import OrderedCollections
@testable import ApolloCodegenLib
import ApolloTestSupport
import ApolloCodegenTestSupport
import ApolloAPI

class IROperationBuilderTests: XCTestCase {

  var mockCompilationResult: CompilationResult!
  var operation: CompilationResult.OperationDefinition!
  var subject: IR.Operation!

  override func setUp() {
    super.setUp()
    mockCompilationResult = CompilationResult.mock()
    operation = CompilationResult.OperationDefinition.mock()
  }

  override func tearDown() {
    mockCompilationResult = nil
    operation = nil
    subject = nil
    super.tearDown()
  }

  // MARK: = Helpers

  func buildSubjectOperation() {
    subject = IR(compilationResult: mockCompilationResult).build(operation: operation)
  }

  // MARK: - Children Computation

  // MARK: Children - Fragment Type

  /// Example:
  /// query {
  ///  allAnimals {
  ///    ...AnimalDetails
  ///  }
  /// }
  ///
  /// fragment AnimalDetails on Animal {
  ///   species
  /// }
  /// Expected:
  /// Animal.children should not include a type case for asAnimal
  func test__children__initWithNamedFragmentOnTheSameType_hasNoChildTypeCase() {
    // given
    let Interface_Animal = GraphQLInterfaceType.mock("Animal")

    let animalDetails = CompilationResult.FragmentDefinition.mock("AnimalDetails", type: Interface_Animal)

    operation = .mock(selections: [
      .field(.mock(
        "allAnimals",
        selectionSet: .mock(
          parentType: Interface_Animal,
          selections: [
            .fragmentSpread(animalDetails),
          ]
        )))])

    // when
    buildSubjectOperation()

    let allAnimals = self.subject[field: "query"]?[field: "allAnimals"]?.selectionSet

    // then
    expect(allAnimals?.selections.typeCases).to(beEmpty())
  }

  /// Example:
  /// query {
  ///  allAnimals {
  ///    ...BirdDetails
  /// }
  ///
  /// fragment BirdDetails on Bird {
  ///   species
  /// }
  /// Expected:
  /// AllAnimals.children: [AsBird]
  func test__children__initWithNamedFragmentOnMoreSpecificType_hasChildTypeCase() {
    // given
    let Interface_Animal = GraphQLInterfaceType.mock("Animal")
    let Object_Bird = GraphQLObjectType.mock("Bird")
    
    let birdDetails = CompilationResult.FragmentDefinition.mock("BirdDetails", type: Object_Bird)

    operation = .mock(selections: [
      .field(.mock(
        "allAnimals",
        selectionSet: .mock(
          parentType: Interface_Animal,
          selections: [
            .fragmentSpread(birdDetails),
          ]
        )))])

    // when
    buildSubjectOperation()

    let allAnimals = self.subject[field: "query"]?[field: "allAnimals"]?.selectionSet

    // then
    expect(allAnimals?.selections.typeCases.count).to(equal(1))

    let child = allAnimals?[as: "Bird"]
    expect(child?.parentType).to(equal(Object_Bird))
    expect(child?.selections.fragments).to(shallowlyMatch([birdDetails]))
  }

  /// Example:
  /// query {
  ///  birds {
  ///    ...AnimalDetails
  /// }
  ///
  /// fragment AnimalDetails on Animal {
  ///   species
  /// }
  /// Expected:
  /// Children should not include a type case for asAnimal
  func test__children__isObjectType_initWithNamedFragmentOnLessSpecificMatchingType_hasNoChildTypeCase() {
    // given
    let Interface_Animal = GraphQLInterfaceType.mock("Animal")
    let Object_Bird = GraphQLObjectType.mock("Bird", interfaces: [Interface_Animal])
    let animalDetails = CompilationResult.FragmentDefinition.mock("AnimalDetails", type: Interface_Animal)

    operation = .mock(selections: [
      .field(.mock(
        "allAnimals",
        selectionSet: .mock(
          parentType: Object_Bird,
          selections: [
            .fragmentSpread(animalDetails),
          ]
        )))])

    // when
    buildSubjectOperation()

    let allAnimals = self.subject[field: "query"]?[field: "allAnimals"]?.selectionSet

    // then
    expect(allAnimals?.selections.typeCases).to(beEmpty())
  }

  /// Example:
  /// query {
  ///  flyingAnimals {
  ///    ...AnimalDetails
  /// }
  ///
  /// fragment AnimalDetails on Animal {
  ///   species
  /// }
  /// Expected:
  /// Children should not include a type case for asAnimal
  func test__children__isInterfaceType_initWithNamedFragmentOnLessSpecificMatchingType_hasNoChildTypeCase() {
    // given
    let Interface_Animal = GraphQLInterfaceType.mock("Animal")
    let Interface_FlyingAnimal = GraphQLInterfaceType.mock("FlyingAnimal", interfaces: [Interface_Animal])
    let animalDetails = CompilationResult.FragmentDefinition.mock("AnimalDetails", type: Interface_Animal)

    operation = .mock(selections: [
      .field(.mock(
        "allAnimals",
        selectionSet: .mock(
          parentType: Interface_FlyingAnimal,
          selections: [
            .fragmentSpread(animalDetails),
          ]
        )))])

    // when
    buildSubjectOperation()

    let allAnimals = self.subject[field: "query"]?[field: "allAnimals"]?.selectionSet

    // then
    expect(allAnimals?.selections.typeCases).to(beEmpty())
  }

  /// Example:
  /// query {
  ///  rocks {
  ///    ...AnimalDetails
  /// }
  ///
  /// fragment AnimalDetails on Animal {
  ///   species
  /// }
  /// Expected:
  /// Children should not include a type case for asAnimal
  func test__children__initWithNamedFragmentOnUnrelatedType_hasChildTypeCase() {
    // given
    let Interface_Animal = GraphQLInterfaceType.mock("Animal")
    let Object_Rock = GraphQLObjectType.mock("Rock")
    let animalDetails = CompilationResult.FragmentDefinition.mock("AnimalDetails", type: Interface_Animal)

    operation = .mock(selections: [
      .field(.mock(
        "rocks",
        selectionSet: .mock(
          parentType: Object_Rock,
          selections: [
            .fragmentSpread(animalDetails),
          ]
        )))])

    // when
    buildSubjectOperation()

    let rocks = self.subject[field: "query"]?[field: "rocks"]?.selectionSet

    // then
    expect(rocks?.selections.typeCases.count).to(equal(1))

    let child = rocks?[as: "Animal"]
    expect(child?.parentType).to(equal(Interface_Animal))
    expect(child?.selections.fragments.count).to(equal(1))
    expect(child?.selections.fragments.values[0].definition).to(equal(animalDetails))
  }

  // MARK: Children Computation - Union Type

  /// Example:
  /// query {
  ///  allAnimals {
  ///    ... on ClassroomPet {
  ///      ... on Bird {
  ///        species
  ///      }
  ///    }
  ///   }
  /// }
  func test__children__givenIsUnionType_withNestedTypeCaseOfObjectType_hasChildrenForTypeCase() {
    // given
    let Object_Bird = GraphQLObjectType.mock("Bird")
    let Union_ClassroomPet = GraphQLUnionType.mock("ClassroomPet", types: [Object_Bird])

    let Field_Species: CompilationResult.Selection = .field(.mock("species"))

    operation = .mock(selections: [
      .field(.mock(
        "allAnimals",
        selectionSet: .mock(
          parentType: GraphQLInterfaceType.mock("Animal"),
          selections: [
            .inlineFragment(.mock(
              parentType: Union_ClassroomPet,
              selections: [
                .inlineFragment(.mock(
                  parentType: Object_Bird,
                  selections: [Field_Species]
                ))]
            )),
          ]
        )))])

    // when
    buildSubjectOperation()

    let onClassroomPet = subject[field: "query"]?[field: "allAnimals"]?[as: "ClassroomPet"]
    let onClassroomPet_onBird = onClassroomPet?[as:"Bird"]

    // then
    expect(onClassroomPet?.parentType).to(beIdenticalTo(Union_ClassroomPet))
    expect(onClassroomPet?.selections.typeCases.count).to(equal(1))

    expect(onClassroomPet_onBird?.parentType).to(beIdenticalTo(Object_Bird))
    expect(onClassroomPet_onBird?.selections.fields).to(shallowlyMatch([Field_Species]))
  }

  // MARK: Children - Type Cases

  /// Example:
  /// query {
  ///   aField { // On A
  ///     A
  ///     ... on A {
  ///       B
  ///     }
  ///   }
  /// }
  ///
  /// Expected:
  /// Query.Children: { }
  func test__children__givenInlineFragment_onSameType_mergesTypeCaseIn_doesNotHaveTypeCaseChild() {
    // given
    let Object_A = GraphQLObjectType.mock("A")

    operation = .mock(selections: [
      .field(.mock(
        "aField",
        selectionSet: .mock(
          parentType: Object_A,
          selections: [
            .field(.mock("A")),
            .inlineFragment(.mock(
              parentType: Object_A,
              selections: [
                .field(.mock("B")),
              ]
            ))
          ])))])

    // when
    buildSubjectOperation()

    let aField = subject[field: "query"]?[field: "aField"]

    // then
    expect(aField?.selectionSet?.selections.typeCases).to(beEmpty())
  }

  /// Example:
  /// type B implements A {}
  ///
  /// query {
  ///   bField { // On B
  ///     A
  ///     ... on A {
  ///       B
  ///     }
  ///   }
  /// }
  ///
  /// Expected:
  /// Query.Children: { }
  func test__children__givenInlineFragment_onMatchingType_mergesTypeCaseIn_doesNotHaveTypeCaseChild() {
    // given
    let Interface_A = GraphQLInterfaceType.mock("A")
    let Object_B = GraphQLObjectType.mock("B", interfaces: [Interface_A])

    operation = .mock(selections: [
      .field(.mock(
        "bField",
        selectionSet: .mock(
          parentType: Object_B,
          selections: [
            .field(.mock("A")),
            .inlineFragment(.mock(
              parentType: Interface_A,
              selections: [
                .field(.mock("B")),
              ]
            ))
          ])))])

    // when
    buildSubjectOperation()

    let bField = subject[field: "query"]?[field: "bField"]

    // then
    expect(bField?.selectionSet?.selections.typeCases).to(beEmpty())
  }

  /// Example:
  /// query {
  ///   aField { // On A
  ///     A
  ///     ... on B {
  ///       B
  ///     }
  ///   }
  /// }
  ///
  /// Expected:
  /// aField.typeCases: {
  ///   ... on B
  /// }
  func test__children__givenInlineFragment_onNonMatchingType_doesNotMergeTypeCaseIn_hasChildTypeCase() {
    // given
    let Object_A = GraphQLObjectType.mock("A")
    let Object_B = GraphQLObjectType.mock("B")

    operation = .mock(selections: [
      .field(.mock(
        "aField",
        selectionSet: .mock(
          parentType: Object_A,
          selections: [
            .field(.mock("A")),
            .inlineFragment(.mock(
              parentType: Object_B,
              selections: [
                .field(.mock("B")),
              ]
            ))
          ])))])

    // when
    buildSubjectOperation()

    let aField = subject[field: "query"]?[field: "aField"] as? IR.EntityField

    let expected = [
      CompilationResult.SelectionSet.mock(
        parentType: Object_B,
        selections: [
          .field(.mock("B")),
        ])
    ]

    // then
    expect(aField?.selectionSet.selections.typeCases).to(shallowlyMatch(expected))
  }

  // MARK: Children - Group Duplicate Type Cases

  /// Example:
  /// query {
  ///   aField {
  ///     ... on InterfaceA {
  ///       A
  ///     }
  ///     ... on InterfaceA {
  ///       B
  ///     }
  ///   }
  /// }
  ///
  /// Expected:
  /// aField.TypeCases: {
  ///   ... on InterfaceA {
  ///     A
  ///     B
  ///   }
  /// }
  func test__children__givenInlineFragmentsWithSameType_deduplicatesChildren() {
    // given
    operation = .mock(selections: [
      .field(.mock(
        "aField",
        selectionSet: .mock(
          selections: [
            .inlineFragment(.mock(
              parentType: GraphQLInterfaceType.mock("InterfaceA"),
              selections: [
                .field(.mock("A")),
              ])),
            .inlineFragment(.mock(
              parentType: GraphQLInterfaceType.mock("InterfaceA"),
              selections: [
                .field(.mock("B")),
              ])),
          ])))])

    let expectedChildren: [CompilationResult.Selection] = [
      .field(.mock("A")),
      .field(.mock("B")),
    ]

    // when
    buildSubjectOperation()

    let aField = subject[field: "query"]?[field: "aField"] as? IR.EntityField
    let aField_asInterfaceA = aField?[as: "InterfaceA"]

    // then
    expect(aField?.selectionSet.selections.typeCases.count).to(equal(1))
    expect(aField_asInterfaceA?.parentType).to(equal(GraphQLInterfaceType.mock("InterfaceA")))
    expect(aField_asInterfaceA?.selections).to(shallowlyMatch(expectedChildren))
  }

  /// Example:
  /// query {
  ///   aField {
  ///     ... on InterfaceA {
  ///       A
  ///     }
  ///     ... on InterfaceB {
  ///       B
  ///     }
  ///   }
  /// }
  ///
  /// Expected:
  /// aField.typeCases: {
  ///   ... on InterfaceA {
  ///     A
  ///   }
  ///   ... on InterfaceB {
  ///     B
  ///   }
  /// }
  func test__children__givenInlineFragmentsWithDifferentType_hasSeperateChildrenChildren() {
    // given
    operation = .mock(selections: [
      .field(.mock(
        "aField",
        selectionSet: .mock(
          selections: [
            .inlineFragment(.mock(
              parentType: GraphQLInterfaceType.mock("InterfaceA"),
              selections: [
                .field(.mock("A")),
              ])),
            .inlineFragment(.mock(
              parentType: GraphQLInterfaceType.mock("InterfaceB"),
              selections: [
                .field(.mock("B")),
              ])),
          ])))])

    // when
    buildSubjectOperation()

    let aField = subject[field: "query"]?[field: "aField"] as? IR.EntityField
    let aField_asInterfaceA = aField?[as: "InterfaceA"]
    let aField_asInterfaceB = aField?[as: "InterfaceB"]

    // then
    expect(aField?.selectionSet.selections.typeCases.count).to(equal(2))

    expect(aField_asInterfaceA?.parentType).to(equal(GraphQLInterfaceType.mock("InterfaceA")))
    expect(aField_asInterfaceA?.selections).to(shallowlyMatch([.field(.mock("A"))]))

    expect(aField_asInterfaceB?.parentType).to(equal(GraphQLInterfaceType.mock("InterfaceB")))
    expect(aField_asInterfaceB?.selections).to(shallowlyMatch([.field(.mock("B"))]))
  }

  // MARK: Children - Group Duplicate Fragments

  /// Example:
  /// fragment FragmentB on B {
  ///   C
  /// }
  ///
  /// query {
  ///   aField { // on A
  ///     ... FragmentB
  ///     ... FragmentB
  ///   }
  /// }
  ///
  /// Expected:
  /// aField.typeCases: {
  ///   ... on B {
  ///     selections: [FragmentB]
  ///   }
  /// }
  func test__children__givenDuplicateNamedFragments_onNonMatchingParentType_hasDeduplicatedTypeCaseWithChildFragment() {
    // given
    let InterfaceA = GraphQLInterfaceType.mock("InterfaceA")
    let InterfaceB = GraphQLInterfaceType.mock("InterfaceB")
    let FragmentB = CompilationResult.FragmentDefinition.mock(
      "FragmentB",
      type: InterfaceB,
      selections: [
        .field(.mock("C"))
      ]
    )

    operation = .mock(selections: [
      .field(.mock(
        "aField",
        selectionSet: .mock(
          parentType: InterfaceA,
          selections: [
            .fragmentSpread(FragmentB),
            .fragmentSpread(FragmentB),
          ])))])

    // when
    buildSubjectOperation()

    let aField = subject[field: "query"]?[field: "aField"] as? IR.EntityField
    let aField_asInterfaceB = aField?[as: "InterfaceB"]

    // then
    expect(aField?.selectionSet.selections.typeCases.count).to(equal(1))

    expect(aField_asInterfaceB?.parentType).to(equal(InterfaceB))
    expect(aField_asInterfaceB?.selections).to(shallowlyMatch([.fragmentSpread(FragmentB)]))
  }

  /// Example:
  /// fragment FragmentB1 on B {
  ///   B
  /// }
  ///
  /// fragment FragmentB2 on B {
  ///   C
  /// }
  ///
  /// query {
  ///   aField {// on A
  ///     ... FragmentB1
  ///     ... FragmentB2
  ///   }
  /// }
  ///
  /// Expected:
  /// aField.typeCaes: {
  ///   ... on B {
  ///     selections: [FragmentB1, FragmentB2]
  ///   }
  /// }
  func test__children__givenTwoNamedFragments_onSameNonMatchingParentType_hasDeduplicatedTypeCaseWithBothChildFragments() {
    // given
    let InterfaceA = GraphQLInterfaceType.mock("InterfaceA")
    let InterfaceB = GraphQLInterfaceType.mock("InterfaceB")
    let FragmentB1 = CompilationResult.FragmentDefinition.mock(
      "FragmentB1",
      type: InterfaceB,
      selections: [
        .field(.mock("B"))
      ]
    )
    let FragmentB2 = CompilationResult.FragmentDefinition.mock(
      "FragmentB2",
      type: InterfaceB,
      selections: [
        .field(.mock("C"))
      ]
    )
    operation = .mock(selections: [
      .field(.mock(
        "aField",
        selectionSet: .mock(
          parentType: InterfaceA,
          selections: [
            .fragmentSpread(FragmentB1),
            .fragmentSpread(FragmentB2),
          ])))])

    // when
    buildSubjectOperation()

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

  func test__selections__givenFieldSelectionsWithSameName_scalarType_deduplicatesSelection() {
    // given
    operation = .mock(selections: [
        .field(.mock("A", type: GraphQLScalarType.integer())),
        .field(.mock("A", type: GraphQLScalarType.integer()))
      ]
    )

    let expected: [CompilationResult.Selection] = [
      .field(.mock("A", type: GraphQLScalarType.integer()))
    ]

    // when
    buildSubjectOperation()

    // then
    expect(self.subject.rootField.selectionSet.selections).to(shallowlyMatch(expected))
  }

  func test__selections__givenFieldSelectionsWithSameNameDifferentAlias_scalarType_doesNotDeduplicateSelection() {
    // given
    operation = .mock(selections: [
        .field(.mock("A", alias: "B", type: GraphQLScalarType.integer())),
        .field(.mock("A", alias: "C", type: GraphQLScalarType.integer()))
      ]
    )

    let expected: [CompilationResult.Selection] = [
      .field(.mock("A", alias: "B", type: GraphQLScalarType.integer())),
      .field(.mock("A", alias: "C", type: GraphQLScalarType.integer()))
    ]

    // when
    buildSubjectOperation()

    // then
    expect(self.subject.rootField.selectionSet.selections).to(shallowlyMatch(expected))
  }

  func test__selections__givenFieldSelectionsWithSameResponseKey_onObjectWithDifferentChildSelections_mergesChildSelectionsIntoOneField() {
    // given
    let Object_A = GraphQLObjectType.mock("A")

    operation = .mock(selections: [
        .field(.mock(
          "A",
          type: .entity(Object_A),
          selectionSet: .mock(
            parentType: Object_A,
            selections: [
              .field(.mock("B", type: GraphQLScalarType.integer()))
            ]
          ))),
        .field(.mock(
          "A",
          type: .entity(Object_A),
          selectionSet: .mock(
            parentType: Object_A,
            selections: [
              .field(.mock("C", type: GraphQLScalarType.integer()))
            ]
          )))
      ]
    )

    let expectedAFields: [CompilationResult.Selection] = [
      .field(.mock("B", type: GraphQLScalarType.integer())),
      .field(.mock("C", type: GraphQLScalarType.integer()))
    ]

    // when
    buildSubjectOperation()

    let queryField = subject[field: "query"] as? IR.EntityField
    let aField = queryField?[field: "A"] as? IR.EntityField

    // then
    expect(queryField?.selectionSet.selections.fields.count).to(equal(1))
    expect(aField?.selectionSet.parentType).to(equal(Object_A))
    expect(aField?.selectionSet.selections).to(shallowlyMatch(expectedAFields))
  }

  /// Example:
  /// query {
  ///   A {
  ///     B
  ///     C
  ///   }
  ///   A {
  ///     B
  ///     D
  ///   }
  /// }
  ///
  /// Expected:
  /// Query.Selections: {
  ///   A {
  ///     B
  ///     C
  ///     D
  ///   }
  /// }
  func test__selections__givenFieldSelectionsWithSameResponseKey_onObjectWithSameAndDifferentChildSelections_mergesChildSelectionsAndDoesNotDuplicateFields() {
    // given
    let Object_A = GraphQLObjectType.mock("A")

    operation = .mock(selections: [
        .field(.mock(
          "A",
          type: .entity(Object_A),
          selectionSet: .mock(
            parentType: Object_A,
            selections: [
              .field(.mock("B", type: GraphQLScalarType.integer())),
              .field(.mock("C", type: GraphQLScalarType.integer())),
            ]
          ))),
        .field(.mock(
          "A",
          type: .entity(Object_A),
          selectionSet: .mock(
            parentType: Object_A,
            selections: [
              .field(.mock("B", type: GraphQLScalarType.integer())),
              .field(.mock("D", type: GraphQLScalarType.integer())),
            ]
          )))
      ]
    )

    let expectedAFields: [CompilationResult.Selection] = [
      .field(.mock("B", type: GraphQLScalarType.integer())),
      .field(.mock("C", type: GraphQLScalarType.integer())),
      .field(.mock("D", type: GraphQLScalarType.integer())),
    ]

    // when
    buildSubjectOperation()

    let queryField = subject[field: "query"] as? IR.EntityField
    let aField = queryField?[field: "A"] as? IR.EntityField

    // then
    expect(queryField?.selectionSet.selections.fields.count).to(equal(1))
    expect(aField?.selectionSet.parentType).to(equal(Object_A))
    expect(aField?.selectionSet.selections).to(shallowlyMatch(expectedAFields))
  }

  // MARK: Selections - Type Cases

  /// Example:
  /// query {
  ///   aField { // On A
  ///     A
  ///     ... on A {
  ///       B
  ///     }
  ///   }
  /// }
  ///
  /// Expected:
  /// aField.Selections: {
  ///   A
  ///   B
  /// }
  func test__selections__givenInlineFragment_onSameType_mergesTypeCaseIn() {
    // given
    let Object_A = GraphQLObjectType.mock("A")

    operation = .mock(selections: [
      .field(.mock(
        "aField",
        selectionSet: .mock(
          parentType: Object_A,
          selections: [
            .field(.mock("A")),
            .inlineFragment(.mock(
              parentType: Object_A,
              selections: [
                .field(.mock("B")),
              ]
            ))
          ])
      ))])

    let expected: [CompilationResult.Selection] = [
      .field(.mock("A")),
      .field(.mock("B")),
    ]

    // when
    buildSubjectOperation()

    let aField = subject[field: "query"]?[field: "aField"] as? IR.EntityField

    // then
    expect(aField?.selectionSet.selections).to(shallowlyMatch(expected))
  }

  /// Example:
  /// type B implements A {}
  ///
  /// query {
  ///   bField { // On B
  ///     A
  ///     ... on A {
  ///       B
  ///     }
  ///   }
  /// }
  ///
  /// Expected:
  /// bField.Selections: {
  ///   A
  ///   B
  /// }
  func test__selections__givenInlineFragment_onMatchingType_mergesTypeCaseIn() {
    // given
    let Interface_A = GraphQLInterfaceType.mock("A")
    let Object_B = GraphQLObjectType.mock("B", interfaces: [Interface_A])

    operation = .mock(selections: [
      .field(.mock(
        "bField",
        selectionSet: .mock(
          parentType: Object_B,
          selections: [
            .field(.mock("A")),
            .inlineFragment(.mock(
              parentType: Interface_A,
              selections: [
                .field(.mock("B")),
              ]
            ))
          ])))])

    let expected: [CompilationResult.Selection] = [
      .field(.mock("A")),
      .field(.mock("B")),
    ]

    // when
    buildSubjectOperation()

    let bField = subject[field: "query"]?[field: "bField"] as? IR.EntityField

    // then
    expect(bField?.selectionSet.selections).to(shallowlyMatch(expected))
  }

  /// Example:
  /// query {
  ///   aField { // On A
  ///     A
  ///     ... on B {
  ///       B
  ///     }
  ///   }
  /// }
  ///
  /// Expected:
  /// aField.Selections: {
  ///     A
  ///     ... on B {
  ///       B
  ///     }
  ///   }
  /// }
  func test__selections__givenInlineFragment_onNonMatchingType_doesNotMergeTypeCaseIn() {
    // given
    let Object_A = GraphQLObjectType.mock("A")
    let Object_B = GraphQLObjectType.mock("B")

    operation = .mock(selections: [
      .field(.mock(
        "aField",
        selectionSet: .mock(
          parentType: Object_A,
          selections: [
            .field(.mock("A")),
            .inlineFragment(.mock(
              parentType: Object_B,
              selections: [
                .field(.mock("B")),
              ]
            ))
          ])))])


    // when
    buildSubjectOperation()

    let aField = subject[field: "query"]?[field: "aField"] as? IR.EntityField
    let aField_asB = aField?[as: "B"]

    // then
    expect(aField?.selectionSet.selections.fields).to(shallowlyMatch([.field(.mock("A"))]))
    expect(aField?.selectionSet.selections.typeCases.count).to(equal(1))

    expect(aField_asB?.selections).to(shallowlyMatch([.field(.mock("B"))]))
  }

  // MARK: Selections - Group Duplicate Type Cases

  /// Example:
  /// query {
  ///   ... on InterfaceA {}
  ///   ... on InterfaceA {}
  /// }
  ///
  /// Expected:
  /// Query.Selections: {
  ///   ... on InterfaceA {}
  /// }
  func test__selections__givenInlineFragmentsWithSameInterfaceType_deduplicatesSelection() {
    // given
    operation = .mock(selections: [
        .inlineFragment(.mock(parentType: GraphQLInterfaceType.mock("InterfaceA"))),
        .inlineFragment(.mock(parentType: GraphQLInterfaceType.mock("InterfaceA"))),
      ]
    )

    let expected: [CompilationResult.Selection] = [
      .inlineFragment(.mock(parentType: GraphQLInterfaceType.mock("InterfaceA")))
    ]

    // when
    buildSubjectOperation()

    // then
    expect(self.subject.rootField.selectionSet.selections).to(shallowlyMatch(expected))
  }

  /// Example:
  /// query {
  ///   ... on ObjectA {}
  ///   ... on ObjectA {}
  /// }
  ///
  /// Expected:
  /// Query.Selections: {
  ///   ... on ObjectA {}
  /// }
  func test__selections__givenInlineFragmentsWithSameObjectType_deduplicatesSelection() {
    // given
    operation = .mock(selections: [
        .inlineFragment(.mock(parentType: GraphQLObjectType.mock("ObjectA"))),
        .inlineFragment(.mock(parentType: GraphQLObjectType.mock("ObjectA"))),
      ]
    )

    let expected: [CompilationResult.Selection] = [
      .inlineFragment(.mock(parentType: GraphQLObjectType.mock("ObjectA"))),
    ]

    // when
    buildSubjectOperation()

    // then
    expect(self.subject.rootField.selectionSet.selections).to(shallowlyMatch(expected))
  }

  /// Example:
  /// query {
  ///   ... on UnionA {}
  ///   ... on UnionA {}
  /// }
  ///
  /// Expected:
  /// Query.Selections: {
  ///   ... on UnionA {}
  /// }
  func test__selections__givenInlineFragmentsWithSameUnionType_deduplicatesSelection() {
    // given
    operation = .mock(selections: [
        .inlineFragment(.mock(parentType: GraphQLUnionType.mock("UnionA"))),
        .inlineFragment(.mock(parentType: GraphQLUnionType.mock("UnionA"))),
      ]
    )

    let expected: [CompilationResult.Selection] = [
      .inlineFragment(.mock(parentType: GraphQLUnionType.mock("UnionA"))),
    ]

    // when
    buildSubjectOperation()

    // then
    expect(self.subject.rootField.selectionSet.selections).to(shallowlyMatch(expected))
  }

  /// Example:
  /// query {
  ///   ... on InterfaceA {}
  ///   ... on InterfaceB {}
  /// }
  ///
  /// Expected:
  /// Query.Selections: {
  ///   ... on InterfaceA {}
  ///   ... on InterfaceB {}
  /// }
  func test__selections__givenInlineFragmentsWithDifferentType_doesNotDeduplicateSelection() {
    // given
    operation = .mock(selections: [
        .inlineFragment(.mock(parentType: GraphQLInterfaceType.mock("InterfaceA"))),
        .inlineFragment(.mock(parentType: GraphQLInterfaceType.mock("InterfaceB"))),
      ]
    )

    let expected: [CompilationResult.Selection] = [
      .inlineFragment(.mock(parentType: GraphQLInterfaceType.mock("InterfaceA"))),
      .inlineFragment(.mock(parentType: GraphQLInterfaceType.mock("InterfaceB"))),
    ]

    // when
    buildSubjectOperation()

    // then
    expect(self.subject.rootField.selectionSet.selections).to(shallowlyMatch(expected))
  }

  /// Example:
  /// query {
  ///   ... on A {
  ///     B
  ///     C
  ///   }
  ///   ... on A {
  ///     B
  ///     D
  ///   }
  /// }
  ///
  /// Expected:
  /// Query.Selections: {
  ///   ... on A {
  ///     B
  ///     C
  ///     D
  ///   }
  /// }
  func test__selections__givenInlineFragmentsWithSameType_withSameAndDifferentChildSelections_mergesChildSelectionsIntoOneTypeCaseAndDeduplicatesChildSelections() {
    // given
    let Object_A = GraphQLObjectType.mock("A")

    operation = .mock(selections: [
        .inlineFragment(.mock(
          parentType: Object_A,
          selections: [
            .field(.mock("B", type: GraphQLScalarType.integer())),
            .field(.mock("C", type: GraphQLScalarType.integer())),
          ]
        )),
        .inlineFragment(.mock(
          parentType: Object_A,
          selections: [
            .field(.mock("B", type: GraphQLScalarType.integer())),
            .field(.mock("D", type: GraphQLScalarType.integer())),
          ]
        ))
      ]
    )

    let expected: [CompilationResult.Selection] = [
      .field(.mock("B", type: GraphQLScalarType.integer())),
      .field(.mock("C", type: GraphQLScalarType.integer())),
      .field(.mock("D", type: GraphQLScalarType.integer())),
    ]

    // when
    buildSubjectOperation()

    let rootField_asA = subject[as: "A"]

    // then
    expect(rootField_asA?.parentType).to(equal(Object_A))
    expect(rootField_asA?.selections).to(shallowlyMatch(expected))
  }

  // MARK: Selections - Fragments

  func test__selections__givenNamedFragmentWithSelectionSet_onMatchingParentType_hasFragmentSelection() {
    // given
    let Object_A = GraphQLObjectType.mock("A")

    operation = .mock(selections: [
      .field(.mock(
        "aField",
        selectionSet: .mock(
          parentType: Object_A,
          selections: [
            .fragmentSpread(.mock(
              "FragmentA",
              type: Object_A,
              selections: [
                .field(.mock("A")),
              ])),
          ]
        )))])

    let expected: [CompilationResult.Selection] = [
      .fragmentSpread(.mock("FragmentA", type: Object_A)),
    ]

    // when
    buildSubjectOperation()

    let aField = subject[field: "query"]?[field: "aField"] as? IR.EntityField

    // then
    expect(aField?.selectionSet.selections).to(shallowlyMatch(expected))
  }

  // MARK: Selections - Group Duplicate Fragments

  func test__selections__givenNamedFragmentsWithSameName_onMatchingParentType_deduplicatesSelection() {
    // given
    let Object_A = GraphQLObjectType.mock("A")

    operation = .mock(selections: [
      .field(.mock(
        "aField",
        selectionSet: .mock(
          parentType: Object_A,
          selections: [
            .fragmentSpread(.mock("FragmentA", type: Object_A)),
            .fragmentSpread(.mock("FragmentA", type: Object_A)),
          ]
        )))])

    let expected: [CompilationResult.Selection] = [
      .fragmentSpread(.mock("FragmentA", type: Object_A)),
    ]

    // when
    buildSubjectOperation()

    let aField = subject[field: "query"]?[field: "aField"] as? IR.EntityField

    // then
    expect(aField?.selectionSet.selections).to(shallowlyMatch(expected))
  }

  func test__selections__givenNamedFragmentsWithDifferentNames_onMatchingParentType_doesNotDeduplicateSelection() {
    // given
    let Object_A = GraphQLObjectType.mock("A")

    operation = .mock(selections: [
      .field(.mock(
        "aField",
        selectionSet: .mock(
          parentType: Object_A,
          selections: [
            .fragmentSpread(.mock("FragmentA", type: Object_A)),
            .fragmentSpread(.mock("FragmentB", type: Object_A)),
          ]
        )))])

    let expected: [CompilationResult.Selection] = [
      .fragmentSpread(.mock("FragmentA", type: Object_A)),
      .fragmentSpread(.mock("FragmentB", type: Object_A)),
    ]

    // when
    buildSubjectOperation()

    let aField = subject[field: "query"]?[field: "aField"] as? IR.EntityField

    // then
    expect(aField?.selectionSet.selections).to(shallowlyMatch(expected))
  }

  func test__selections__givenNamedFragmentsWithSameName_onNonMatchingParentType_deduplicatesSelectionIntoSingleTypeCase() {
    // given
    let Object_A = GraphQLObjectType.mock("A")
    let Interface_B = GraphQLInterfaceType.mock("B")

    operation = .mock(selections: [
      .field(.mock(
        "aField",
        selectionSet: .mock(
          parentType: Object_A,
          selections: [
            .fragmentSpread(.mock("FragmentA", type: Interface_B)),
            .fragmentSpread(.mock("FragmentA", type: Interface_B)),
          ]
        )))])

    let expected: [CompilationResult.Selection] = [
      .fragmentSpread(.mock("FragmentA", type: Interface_B))
    ]

    // when
    buildSubjectOperation()

    let aField = subject[field: "query"]?[field: "aField"] as? IR.EntityField

    // then
    expect(aField?.selectionSet.selections.fields.count).to(equal(0))
    expect(aField?.selectionSet.selections.typeCases.count).to(equal(1))
    expect(aField?[as: "B"]?.selections).to(shallowlyMatch(expected))
  }

  /// Example:
  /// FragmentA on B {
  ///   B
  /// }
  ///
  /// FragmentB on B {
  ///   C
  /// }
  ///
  /// query {
  ///   aField { // on A
  ///     ...FragmentA
  ///     ...FragmentB
  ///   }
  /// }
  ///
  /// Expected:
  /// aField.selections = {
  ///   ... on B {
  ///     ...FragmentA
  ///     ...FragmentB
  ///   }
  /// }
  func test__selections__givenNamedFragmentsWithDifferentNamesAndSameParentType_onNonMatchingParentType_deduplicatesSelectionIntoSingleTypeCaseWithBothFragments() {
    // given
    let Object_A = GraphQLObjectType.mock("A")
    let Interface_B = GraphQLInterfaceType.mock("B")
    let Fragment_A = CompilationResult.FragmentDefinition.mock(
      "FragmentA",
      type: Interface_B,
      selections: [
        .field(.mock("B", type: GraphQLScalarType.integer())),
      ])
    let Fragment_B = CompilationResult.FragmentDefinition.mock(
      "FragmentB",
      type: Interface_B,
      selections: [
        .field(.mock("C", type: GraphQLScalarType.integer())),
      ])

    operation = .mock(selections: [
      .field(.mock(
        "aField",
        selectionSet: .mock(
          parentType: Object_A,
          selections: [
            .fragmentSpread(Fragment_A),
            .fragmentSpread(Fragment_B),
          ]
        )))])

    let expected: [CompilationResult.Selection] = [
      .fragmentSpread(Fragment_A),
      .fragmentSpread(Fragment_B),
    ]

    // when
    buildSubjectOperation()

    let aField = subject[field: "query"]?[field: "aField"] as? IR.EntityField

    // then
    expect(aField?.selectionSet.selections.fields.count).to(equal(0))
    expect(aField?.selectionSet.selections.typeCases.count).to(equal(1))
    expect(aField?[as: "B"]?.selections).to(shallowlyMatch(expected))
  }

  func test__selections__givenNamedFragmentsWithDifferentNamesAndDifferentParentType_onNonMatchingParentType_doesNotDeduplicate_hasTypeCaseForEachFragment() {
    // given
    let Object_A = GraphQLObjectType.mock("A")
    let Interface_B = GraphQLInterfaceType.mock("B")
    let Interface_C = GraphQLInterfaceType.mock("C")
    let Fragment_B = CompilationResult.FragmentDefinition.mock(
      "FragmentB",
      type: Interface_B,
      selections: [
        .field(.mock("B", type: GraphQLScalarType.integer())),
      ])
    let Fragment_C = CompilationResult.FragmentDefinition.mock(
      "FragmentC",
      type: Interface_C,
      selections: [
        .field(.mock("C", type: GraphQLScalarType.integer())),
      ])

    operation = .mock(selections: [
      .field(.mock(
        "aField",
        selectionSet: .mock(
      parentType: Object_A,
      selections: [
        .fragmentSpread(Fragment_B),
        .fragmentSpread(Fragment_C),
      ]
    )))])

    // when
    buildSubjectOperation()

    let aField = subject[field: "query"]?[field: "aField"] as? IR.EntityField

    // then
    expect(aField?.selectionSet.selections.fields.count).to(equal(0))
    expect(aField?.selectionSet.selections.typeCases.count).to(equal(2))
    expect(aField?[as: "B"]?.selections).to(shallowlyMatch([.fragmentSpread(Fragment_B)]))
    expect(aField?[as: "C"]?.selections).to(shallowlyMatch([.fragmentSpread(Fragment_C)]))
  }

  // MARK: - Merged Selections

  func test__mergedSelections__givenSelectionSetWithNoSelectionsAndNoParent_returnsNil() {
    // given
    operation = .mock(selections: [])
    
    // when
    buildSubjectOperation()

    // then
    expect(self.subject.rootField.selectionSet.mergedSelections.isEmpty).to(beTrue())
  }

  func test__mergedSelections__givenSelectionSetWithSelections_returnsSelections() {
    // given
    let expected = [CompilationResult.Selection.field(.mock())]

    operation = .mock(selections: expected)

    // when
    buildSubjectOperation()

    // then
    expect(self.subject.rootField.selectionSet.mergedSelections).to(shallowlyMatch(expected))
  }

  func test__mergedSelections__givenSelectionSetWithSelectionsAndParentFields_returnsSelfAndParentFields() {
    // given
    operation = .mock(selections: [
      .field(.mock(
        "aField",
        selectionSet: .mock(
          parentType: GraphQLObjectType.mock("A"),
          selections: [
            .field(.mock("A")),
            .inlineFragment(.mock(
              parentType: GraphQLObjectType.mock("B"),
              selections: [.field(.mock("B"))]
            ))
          ]
        )))])

    let expected: [CompilationResult.Selection] = [
      .field(.mock("B")),
      .field(.mock("A")),
    ]

    // when
    buildSubjectOperation()

    let actual = subject[field: "query"]?[field: "aField"]?[as: "B"]?.mergedSelections

    // then
    expect(actual).to(shallowlyMatch(expected))
  }

  // MARK: - Merged Selections - Siblings

  // MARK: Merged Selections - Siblings - Object Type <-> Object Type

  /// Example:
  /// query {
  ///  allAnimals {
  ///    ... on Bird {
  ///      wingspan
  ///    }
  ///    ... on Bird {
  ///      species
  ///    }
  ///   }
  /// }
  /// Expected:
  /// One merged typecase selection set with mergedSelections [wingspan, species]
  func test__mergedSelections__givenIsObjectType_siblingSelectionSetIsTheSameObjectType_mergesSiblingSelections() {
    // given
    operation = .mock(selections: [
      .field(.mock(
        "allAnimals",
        selectionSet: .mock(
          parentType: GraphQLInterfaceType.mock("Animal"),
          selections: [
            .inlineFragment(.mock(
              parentType: GraphQLObjectType.mock("Bird"),
              selections: [.field(.mock("wingspan"))]
            )),
            .inlineFragment(.mock(
              parentType: GraphQLObjectType.mock("Bird"),
              selections: [.field(.mock("species"))]
            )),
          ]
        )))])

    let expected = [
      CompilationResult.Selection.field(.mock("wingspan")),
      CompilationResult.Selection.field(.mock("species"))
    ]

    // when
    buildSubjectOperation()

    let allAnimals = subject[field: "query"]?[field: "allAnimals"]
    let actual = allAnimals?[as: "Bird"]?.mergedSelections

    // then
    expect(allAnimals?.selectionSet?.selections.typeCases.count).to(equal(1))
    expect(actual).to(shallowlyMatch(expected))
  }

  /// Example:
  /// query {
  ///  allAnimals {
  ///    ... on Bird {
  ///      wingspan
  ///    }
  ///    ... on Cat {
  ///      species
  ///    }
  ///   }
  /// }
  /// Expected:
  /// Bird and Cat selections sets should not merge each other's selections
  func test__mergedSelections__givenIsObjectType_siblingSelectionSetIsDifferentObjectType_doesNotMergesSiblingSelections() {
    // given
    operation = .mock(selections: [
      .field(.mock(
        "allAnimals",
        selectionSet: .mock(
          parentType: GraphQLInterfaceType.mock("Animal"),
          selections: [
            .inlineFragment(.mock(
              parentType: GraphQLObjectType.mock("Bird"),
              selections: [.field(.mock("wingspan"))]
            )),
            .inlineFragment(.mock(
              parentType: GraphQLObjectType.mock("Cat"),
              selections: [.field(.mock("species"))]
            )),
          ]
        )))])

    let asBirdExpected: [CompilationResult.Selection] = [.field(.mock("wingspan"))]
    let asCatExpected: [CompilationResult.Selection] = [.field(.mock("species"))]

    // when
    buildSubjectOperation()

    let allAnimals = subject[field: "query"]?[field: "allAnimals"]
    let asBird = allAnimals?[as: "Bird"]?.mergedSelections
    let asCat = allAnimals?[as: "Cat"]?.mergedSelections

    // then
    expect(asBird).to(shallowlyMatch(asBirdExpected))
    expect(asCat).to(shallowlyMatch(asCatExpected))
  }

  // MARK: Merged Selections - Siblings - Object Type -> Interface Type

  /// Example:
  /// query {
  ///  allAnimals {
  ///    ... on Bird {
  ///      wingspan
  ///    }
  ///    ... on Pet { // Bird Implements Pet
  ///      species
  ///    }
  ///   }
  /// }
  /// Expected:
  /// Bird mergedSelections: [wingspan, species]
  /// Pet mergedSelections: [species]
  func test__mergedSelections__givenIsObjectType_siblingSelectionSetIsImplementedInterface_mergesSiblingSelections() {
    // given
    let Pet = GraphQLInterfaceType.mock("Pet")
    let Bird = GraphQLObjectType.mock("Bird", interfaces: [Pet])

    operation = .mock(selections: [
      .field(.mock(
        "allAnimals",
        selectionSet: .mock(
          parentType: GraphQLInterfaceType.mock("Animal"),
          selections: [
            .inlineFragment(.mock(
              parentType: Bird,
              selections: [.field(.mock("wingspan"))]
            )),
            .inlineFragment(.mock(
              parentType: Pet,
              selections: [.field(.mock("species"))]
            )),
          ]
        )))])

    let asBirdExpected: [CompilationResult.Selection] = [
      .field(.mock("wingspan")),
      .field(.mock("species"))
    ]

    let asPetExpected: [CompilationResult.Selection] = [
      .field(.mock("species"))
    ]

    // when
    buildSubjectOperation()

    let allAnimals = subject[field: "query"]?[field: "allAnimals"]
    let asBird = allAnimals?[as: "Bird"]?.mergedSelections
    let asPet = allAnimals?[as: "Pet"]?.mergedSelections

    // then
    expect(asBird).to(shallowlyMatch(asBirdExpected))
    expect(asPet).to(shallowlyMatch(asPetExpected))
  }

  /// Example:
  /// query {
  ///  allAnimals {
  ///    ... on Bird {
  ///      wingspan
  ///    }
  ///    ... on Pet { // Bird does not implement Pet
  ///      species
  ///    }
  /// }
  /// Expected:
  /// Bird mergedSelections: [wingspan]
  /// Pet mergedSelections: [species]
  func test__mergedSelections__givenIsObjectType_siblingSelectionSetIsUnimplementedInterface_doesNotMergeSiblingSelections() {
    // given
    let Pet = GraphQLInterfaceType.mock("Pet")
    let Bird = GraphQLObjectType.mock("Bird")

    operation = .mock(selections: [
      .field(.mock(
        "allAnimals",
        selectionSet: .mock(
          parentType: GraphQLInterfaceType.mock("Animal"),
          selections: [
            .inlineFragment(.mock(
              parentType: Bird,
              selections: [.field(.mock("wingspan"))]
            )),
            .inlineFragment(.mock(
              parentType: Pet,
              selections: [.field(.mock("species"))]
            )),
          ]
        )))])

    let asBirdExpected: [CompilationResult.Selection] = [.field(.mock("wingspan"))]

    let asPetExpected: [CompilationResult.Selection] = [.field(.mock("species"))]

    // when
    buildSubjectOperation()

    let allAnimals = subject[field: "query"]?[field: "allAnimals"]
    let asBird = allAnimals?[as: "Bird"]?.mergedSelections
    let asPet = allAnimals?[as: "Pet"]?.mergedSelections

    // then
    expect(asBird).to(shallowlyMatch(asBirdExpected))
    expect(asPet).to(shallowlyMatch(asPetExpected))
  }

  // MARK: Merged Selections - Siblings - Interface Type -> Interface Type

  /// Example:
  /// query {
  ///  allAnimals {
  ///    ... on HousePet {
  ///      humanName
  ///    }
  ///    ... on Pet { // HousePet Implements Pet
  ///      species
  ///    }
  ///   }
  /// }
  /// Expected:
  /// HousePet mergedSelections: [humanName, species]
  /// Pet mergedSelections: [species]
  func test__mergedSelections__givenIsInterfaceType_siblingSelectionSetIsImplementedInterface_mergesSiblingSelections() {
    // given
    let Pet = GraphQLInterfaceType.mock("Pet")
    let HousePet = GraphQLInterfaceType.mock("HousePet", interfaces: [Pet])

    operation = .mock(selections: [
      .field(.mock(
        "allAnimals",
        selectionSet: .mock(
          parentType: GraphQLInterfaceType.mock("Animal"),
          selections: [
            .inlineFragment(.mock(
              parentType: HousePet,
              selections: [.field(.mock("humanName"))]
            )),
            .inlineFragment(.mock(
              parentType: Pet,
              selections: [.field(.mock("species"))]
            )),
          ]
    )))])

    let asHousePetExpected: [CompilationResult.Selection] = [
      .field(.mock("humanName")),
      .field(.mock("species"))
    ]

    let asPetExpected: [CompilationResult.Selection] = [
      .field(.mock("species"))
    ]

    // when
    buildSubjectOperation()

    let allAnimals = subject[field: "query"]?[field: "allAnimals"]
    let asHousePet = allAnimals?[as: "HousePet"]?.mergedSelections
    let asPet = allAnimals?[as: "Pet"]?.mergedSelections

    // then
    expect(asHousePet).to(shallowlyMatch(asHousePetExpected))
    expect(asPet).to(shallowlyMatch(asPetExpected))
  }

  /// Example:
  /// query {
  ///  allAnimals {
  ///    ... on HousePet {
  ///      humanName
  ///    }
  ///    ... on Pet { // HousePet does not implement Pet
  ///      species
  ///    }
  ///   }
  /// }
  /// Expected:
  /// HousePet mergedSelections: [humanName]
  /// Pet mergedSelections: [species]
  func test__mergedSelections__givenIsInterfaceType_siblingSelectionSetIsUnimplementedInterface_doesNotMergeSiblingSelections() {
    // given
    let Pet = GraphQLInterfaceType.mock("Pet")
    let HousePet = GraphQLInterfaceType.mock("HousePet")

    operation = .mock(selections: [
      .field(.mock(
        "allAnimals",
        selectionSet: .mock(
          parentType: GraphQLInterfaceType.mock("Animal"),
          selections: [
            .inlineFragment(.mock(
              parentType: HousePet,
              selections: [.field(.mock("humanName"))]
            )),
            .inlineFragment(.mock(
              parentType: Pet,
              selections: [.field(.mock("species"))]
            )),
          ]
        )))])

    let asHousePetExpected: [CompilationResult.Selection] = [.field(.mock("humanName"))]

    let asPetExpected: [CompilationResult.Selection] = [.field(.mock("species"))]

    // when
    buildSubjectOperation()

    let allAnimals = subject[field: "query"]?[field: "allAnimals"]
    let asHousePet = allAnimals?[as: "HousePet"]?.mergedSelections
    let asPet = allAnimals?[as: "Pet"]?.mergedSelections

    // then
    expect(asHousePet).to(shallowlyMatch(asHousePetExpected))
    expect(asPet).to(shallowlyMatch(asPetExpected))
  }

  // MARK: - Merged Selections - Parent's Sibling

  /// Example:
  /// query {
  ///  allAnimals {
  ///    ... on WarmBlooded {
  ///      ... on Pet {
  ///        humanName
  ///      }
  ///    }
  ///    ... on Pet {
  ///      species
  ///    }
  /// }
  /// Expected:
  /// Bird mergedSelections: [humanName, species]
  /// Pet mergedSelections: [species]
  func test__mergedSelections__givenIsNestedInterfaceType_uncleSelectionSetIsTheSameInterfaceType_mergesUncleSelections() {
    // given
    operation = .mock(selections: [
      .field(.mock(
        "allAnimals",
        selectionSet: .mock(
          parentType: GraphQLInterfaceType.mock("Animal"),
          selections: [
            .inlineFragment(.mock(
              parentType: GraphQLInterfaceType.mock("WarmBlooded"),
              selections: [
                .inlineFragment(.mock(
                  parentType: GraphQLInterfaceType.mock("Pet"),
                  selections: [.field(.mock("humanName", type: .string()))]
                )),
              ]
            )),
            .inlineFragment(.mock(
              parentType: GraphQLInterfaceType.mock("Pet"),
              selections: [.field(.mock("species", type: .string()))]
            )),
          ]
        )))])

    let onWarmBlooded_onPet_expected = [
      CompilationResult.Selection.field(.mock("humanName", type: .string())),
      CompilationResult.Selection.field(.mock("species", type: .string()))
    ]

    let onPet_expected = [
      CompilationResult.Selection.field(.mock("species", type: .string()))
    ]

    // when
    buildSubjectOperation()

    let allAnimals = subject[field: "query"]?[field: "allAnimals"]

    let onWarmBlooded_onPet_actual = allAnimals?[as:"WarmBlooded"]?[as: "Pet"]?
      .mergedSelections

    let onPet_actual = allAnimals?[as: "Pet"]?
      .mergedSelections

    // then
    expect(onWarmBlooded_onPet_actual).to(shallowlyMatch(onWarmBlooded_onPet_expected))
    expect(onPet_actual).to(shallowlyMatch(onPet_expected))
  }

  /// Example:
  /// query {
  ///  allAnimals {
  ///    ... on WarmBlooded {
  ///      ... on Bird {
  ///        wingspan
  ///      }
  ///    }
  ///    ... on Pet { // Bird Implements Pet
  ///      species
  ///    }
  /// }
  /// Expected:
  /// Bird mergedSelections: [wingspan, species]
  /// Pet mergedSelections: [species]
  func test__mergedSelections__givenIsObjectInInterfaceType_uncleSelectionSetIsMatchingInterfaceType_mergesUncleSelections() {
    // given
    let Interface_Animal = GraphQLInterfaceType.mock("Animal")
    let Interface_WarmBlooded = GraphQLInterfaceType.mock("WarmBlooded",
                                                          interfaces: [Interface_Animal])
    let Interface_Pet = GraphQLInterfaceType.mock("Pet",
                                                  interfaces: [Interface_Animal])
    let Object_Bird = GraphQLObjectType.mock("Bird",
                                             interfaces: [
                                              Interface_Animal,
                                              Interface_Pet,
                                              Interface_WarmBlooded])

    operation = .mock(selections: [
      .field(.mock(
        "allAnimals",
        selectionSet: .mock(
          parentType: Interface_Animal,
          selections: [
            .inlineFragment(.mock(
              parentType: Interface_WarmBlooded,
              selections: [
                .inlineFragment(.mock(
                  parentType: Object_Bird,
                  selections: [.field(.mock("wingspan"))]
                )),
              ]
            )),
            .inlineFragment(.mock(
              parentType: Interface_Pet,
              selections: [.field(.mock("species"))]
            )),
          ]
        )))])

    let onWarmBlooded_onBird_expected = [
      CompilationResult.Selection.field(.mock("wingspan")),
      CompilationResult.Selection.field(.mock("species"))
    ]

    let onPet_expected = [
      CompilationResult.Selection.field(.mock("species"))
    ]

    // when
    buildSubjectOperation()

    let allAnimals = subject[field: "query"]?[field: "allAnimals"]

    let asWarmBlooded_asBird_actual = allAnimals?[as: "WarmBlooded"]?[as: "Bird"]?
      .mergedSelections

    let asPet_actual = allAnimals?[as: "Pet"]?
      .mergedSelections

    // then
    expect(asWarmBlooded_asBird_actual).to(shallowlyMatch(onWarmBlooded_onBird_expected))
    expect(asPet_actual).to(shallowlyMatch(onPet_expected))
  }

  /// Example:
  /// query {
  ///  allAnimals {
  ///    ... on WarmBlooded {
  ///      ... on Bird {
  ///        wingspan
  ///      }
  ///    }
  ///    ... on Pet { // Bird Does Not Implement Pet
  ///      species
  ///    }
  /// }
  /// Expected:
  /// Bird mergedSelections: [wingspan]
  /// Pet mergedSelections: [species]
  func test__mergedSelections__givenIsObjectInInterfaceType_uncleSelectionSetIsNonMatchingInterfaceType_doesNotMergeUncleSelections() {
    // given
    let Interface_Animal = GraphQLInterfaceType.mock("Animal")
    let Interface_WarmBlooded = GraphQLInterfaceType.mock("WarmBlooded",
                                                          interfaces: [Interface_Animal])
    let Interface_Pet = GraphQLInterfaceType.mock("Pet",
                                                  interfaces: [Interface_Animal])
    let Object_Bird = GraphQLObjectType.mock("Bird",
                                             interfaces: [
                                              Interface_Animal,
                                              Interface_WarmBlooded])

    operation = .mock(selections: [
      .field(.mock(
        "allAnimals",
        selectionSet: .mock(
          parentType: Interface_Animal,
          selections: [
            .inlineFragment(.mock(
              parentType: Interface_WarmBlooded,
              selections: [
                .inlineFragment(.mock(
                  parentType: Object_Bird,
                  selections: [.field(.mock("wingspan"))]
                )),
              ]
            )),
            .inlineFragment(.mock(
              parentType: Interface_Pet,
              selections: [.field(.mock("species"))]
            )),
          ]
        )))])

    let asWarmBlooded_asBird_expected = [
      CompilationResult.Selection.field(.mock("wingspan")),
    ]

    let asPet_expected = [
      CompilationResult.Selection.field(.mock("species"))
    ]

    // when
    buildSubjectOperation()

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

  /// Example:
  /// query {
  ///  allAnimals {
  ///    ... on Bird {
  ///      wingspan
  ///    }
  ///    ... on ClassroomPet {
  ///      ... on Bird {
  ///        species
  ///      }
  ///    }
  ///   }
  /// }
  /// Expected:
  /// Both selection sets should have mergedSelections [wingspan, species]
  func test__mergedSelections__givenIsObjectType_siblingSelectionSetIsUnionTypeWithNestedTypeCaseOfSameObjectType_mergesSiblingChildSelectionsInBothDirections() {
    // given
    let Object_Bird = GraphQLObjectType.mock("Bird")
    let Union_ClassroomPet = GraphQLUnionType.mock("ClassroomPet", types: [Object_Bird])

    let Field_Wingspan: CompilationResult.Selection = .field(.mock("wingspan"))
    let Field_Species: CompilationResult.Selection = .field(.mock("species"))

    mockCompilationResult.referencedTypes = .init([Object_Bird, Union_ClassroomPet])

    operation = .mock(selections: [
      .field(.mock(
        "allAnimals",
        selectionSet: .mock(
          parentType: GraphQLInterfaceType.mock("Animal"),
          selections: [
            .inlineFragment(.mock(
              parentType: Object_Bird,
              selections: [Field_Wingspan]
            )),
            .inlineFragment(.mock(
              parentType: Union_ClassroomPet,
              selections: [
                .inlineFragment(.mock(
                  parentType: Object_Bird,
                  selections: [Field_Species]
                ))]
            )),
          ]
        )))])

    let asBirdExpected = [
      Field_Wingspan,
      Field_Species
    ]

    let asClassroomPet_asBirdExpected = [
      Field_Species,
      Field_Wingspan
    ]

    // when
    buildSubjectOperation()

    let allAnimals = subject[field: "query"]?[field: "allAnimals"]

    let asBirdActual = allAnimals?[as: "Bird"]?.mergedSelections
    let asClassroomPet_asBirdActual = allAnimals?[as: "ClassroomPet"]?[as: "Bird"]?
      .mergedSelections

    // then
    expect(asBirdActual).to(shallowlyMatch(asBirdExpected))
    expect(asClassroomPet_asBirdActual).to(shallowlyMatch(asClassroomPet_asBirdExpected))
  }

  /// Example:
  /// query {
  ///  allAnimals {
  ///    ... on Bird {
  ///      wingspan
  ///    }
  ///    ... on ClassroomPet {
  ///      ... on Cat {
  ///        species
  ///      }
  ///    }
  ///   }
  /// }
  /// Expected:
  /// Bird mergedSelections: [wingspan]
  /// ClassroomPet.Cat mergedSelections: [species]
  func test__mergedSelections__givenIsObjectType_siblingSelectionSetIsUnionTypeWithNestedTypeCaseOfDifferentObjectType_doesNotMergeSiblingChildSelectionsInEitherDirection() {
    // given
    let Object_Bird = GraphQLObjectType.mock("Bird")
    let Object_Cat = GraphQLObjectType.mock("Cat")
    let Union_ClassroomPet = GraphQLUnionType.mock("ClassroomPet",
                                                   types: [Object_Bird, Object_Cat])

    let Field_Wingspan: CompilationResult.Selection = .field(.mock("wingspan"))
    let Field_Species: CompilationResult.Selection = .field(.mock("species"))

    operation = .mock(selections: [
      .field(.mock(
        "allAnimals",
        selectionSet: .mock(
          parentType: GraphQLInterfaceType.mock("Animal"),
          selections: [
            .inlineFragment(.mock(
              parentType: Object_Bird,
              selections: [Field_Wingspan]
            )),
            .inlineFragment(.mock(
              parentType: Union_ClassroomPet,
              selections: [
                .inlineFragment(.mock(
                  parentType: Object_Cat,
                  selections: [Field_Species]
                ))]
            )),
          ]
        )))])

    let asBirdExpected = [
      Field_Wingspan
    ]

    let asClassroomPet_asCatExpected = [
      Field_Species
    ]

    // when
    buildSubjectOperation()

    let allAnimals = subject[field: "query"]?[field: "allAnimals"]

    let asBirdActual = allAnimals?[as: "Bird"]?.mergedSelections
    let asClassroomPet_asCatActual = allAnimals?[as: "ClassroomPet"]?[as: "Cat"]?
      .mergedSelections

    // then
    expect(asBirdActual).to(shallowlyMatch(asBirdExpected))
    expect(asClassroomPet_asCatActual).to(shallowlyMatch(asClassroomPet_asCatExpected))
  }

  // MARK: Merged Selections - Parent's Sibling - Interface in Union Type

  /// Example:
  /// query {
  ///  allAnimals {
  ///    ... on WarmBlooded {
  ///      bodyTemperature
  ///    }
  ///    ... on ClassroomPet {
  ///      ... on WarmBlooded {
  ///        species
  ///      }
  ///    }
  ///   }
  /// }
  /// Expected:
  /// AllAnimal.AsWarmBlooded mergedSelections: [bodyTemperature]
  /// AllAnimal.AsClassroomPet.AsWarmBlooded mergedSelections: [species, bodyTemperature]
  func test__mergedSelections__givenInterfaceTypeInUnion_uncleSelectionSetIsMatchingInterfaceType_mergesUncleSelections() {
    // given
    let Interface_Animal = GraphQLInterfaceType.mock("Animal")
    let Interface_WarmBlooded = GraphQLInterfaceType.mock("WarmBlooded",
                                                          interfaces: [Interface_Animal])
    let Object_Bird = GraphQLObjectType.mock("Bird",
                                             interfaces: [
                                              Interface_Animal,
                                              Interface_WarmBlooded])
    let Union_ClassroomPet = GraphQLUnionType.mock("ClassroomPet", types: [Object_Bird])

    mockCompilationResult.referencedTypes = .init([
      Interface_Animal, Interface_WarmBlooded, Object_Bird, Union_ClassroomPet])

    operation = .mock(selections: [
      .field(.mock(
        "allAnimals",
        selectionSet: .mock(
          parentType: Interface_Animal,
          selections: [
            .inlineFragment(.mock(
              parentType: Interface_WarmBlooded,
              selections: [.field(.mock("bodyTemperature"))]
            )),
            .inlineFragment(.mock(
              parentType: Union_ClassroomPet,
              selections: [
                .inlineFragment(.mock(
                  parentType: Interface_WarmBlooded,
                  selections: [.field(.mock("species"))]
                )),
              ]
            )),
          ]
        )))])

    let asWarmBlooded_expected = [
      CompilationResult.Selection.field(.mock("bodyTemperature")),
    ]

    let asClassroomPet_asWarmBlooded_expected = [
      CompilationResult.Selection.field(.mock("species")),
      CompilationResult.Selection.field(.mock("bodyTemperature")),
    ]

    // when
    buildSubjectOperation()

    let allAnimals = subject[field: "query"]?[field: "allAnimals"]

    let asWarmBlooded_actual = allAnimals?[as: "WarmBlooded"]!
      .mergedSelections

    let asClassroomPet_asWarmBlooded_actual = allAnimals?[as: "ClassroomPet"]?[as: "WarmBlooded"]?
      .mergedSelections

    // then
    expect(asWarmBlooded_actual).to(shallowlyMatch(asWarmBlooded_expected))
    expect(asClassroomPet_asWarmBlooded_actual).to(shallowlyMatch(asClassroomPet_asWarmBlooded_expected))
  }

  /// Example:
  /// query {
  ///  allAnimals {
  ///    ... on Pet {
  ///      humanName
  ///    }
  ///    ... on ClassroomPet {
  ///      ... on WarmBloodedPet { // WarmBloodedPet implements Pet
  ///        species
  ///      }
  ///    }
  ///   }
  /// }
  /// Expected:
  /// AllAnimal.AsPet mergedSelections: [humanName]
  /// AllAnimal.AsClassroomPet.AsWarmBloodedPet mergedSelections: [species, humanName]
  func test__mergedSelections__givenInterfaceTypeInUnion_uncleSelectionSetIsChildMatchingInterfaceType_mergesUncleSelections() {
    // given
    let Interface_Animal = GraphQLInterfaceType.mock("Animal")
    let Interface_Pet = GraphQLInterfaceType.mock("Pet",
                                                  interfaces: [Interface_Animal])
    let Interface_WarmBloodedPet = GraphQLInterfaceType.mock("WarmBloodedPet",
                                                             interfaces: [
                                                              Interface_Animal,
                                                              Interface_Pet])
    let Object_Bird = GraphQLObjectType.mock("Bird",
                                             interfaces: [
                                              Interface_Animal,
                                              Interface_Pet,
                                              Interface_WarmBloodedPet])
    let Union_ClassroomPet = GraphQLUnionType.mock("ClassroomPet", types: [Object_Bird])

    mockCompilationResult.referencedTypes = .init([
      Interface_Animal, Interface_Pet, Interface_WarmBloodedPet, Object_Bird, Union_ClassroomPet])

    operation = .mock(selections: [
      .field(.mock(
        "allAnimals",
        selectionSet: .mock(
          parentType: Interface_Animal,
          selections: [
            .inlineFragment(.mock(
              parentType: Interface_Pet,
              selections: [.field(.mock("humanName"))]
            )),
            .inlineFragment(.mock(
              parentType: Union_ClassroomPet,
              selections: [
                .inlineFragment(.mock(
                  parentType: Interface_WarmBloodedPet,
                  selections: [.field(.mock("species"))]
                )),
              ]
            )),
          ]
        )))])

    let asPet_expected = [
      CompilationResult.Selection.field(.mock("humanName")),
    ]

    let asClassroomPet_asWarmBloodedPet_expected = [
      CompilationResult.Selection.field(.mock("species")),
      CompilationResult.Selection.field(.mock("humanName")),
    ]

    // when
    buildSubjectOperation()

    let allAnimals = subject[field: "query"]?[field: "allAnimals"]

    let asPet_actual = allAnimals?[as: "Pet"]?
      .mergedSelections

    let asClassroomPet_asWarmBloodedPet_actual = allAnimals?[as: "ClassroomPet"]?[as: "WarmBloodedPet"]?
      .mergedSelections

    // then
    expect(asPet_actual).to(shallowlyMatch(asPet_expected))
    expect(asClassroomPet_asWarmBloodedPet_actual).to(shallowlyMatch(asClassroomPet_asWarmBloodedPet_expected))
  }

  /// Example:
  /// query {
  ///  allAnimals {
  ///    ... on WarmBlooded {
  ///      bodyTemperature
  ///    }
  ///    ... on ClassroomPet {
  ///      ... on Pet {
  ///        species
  ///      }
  ///    }
  ///   }
  /// }
  /// Expected:
  /// AllAnimal.AsWarmBlooded mergedSelections: [bodyTemperature]
  /// AllAnimal.AsClassroomPet.AsPet mergedSelections: [species]
  func test__mergedSelections__givenInterfaceTypeInUnion_uncleSelectionSetIsNonMatchingInterfaceType_doesNotMergesUncleSelections() {
    // given
    let Interface_Animal = GraphQLInterfaceType.mock("Animal")
    let Interface_Pet = GraphQLInterfaceType.mock("Pet",
                                                  interfaces: [Interface_Animal])
    let Interface_WarmBlooded = GraphQLInterfaceType.mock("WarmBlooded",
                                                          interfaces: [Interface_Animal])
    let Object_Bird = GraphQLObjectType.mock("Bird",
                                             interfaces: [
                                              Interface_Animal,
                                              Interface_WarmBlooded])
    let Union_ClassroomPet = GraphQLUnionType.mock("ClassroomPet", types: [Object_Bird])

    mockCompilationResult.referencedTypes = .init([
      Interface_Animal, Interface_Pet, Interface_WarmBlooded, Object_Bird, Union_ClassroomPet])

    operation = .mock(selections: [
      .field(.mock(
        "allAnimals",
        selectionSet: .mock(
          parentType: Interface_Animal,
          selections: [
            .inlineFragment(.mock(
              parentType: Interface_WarmBlooded,
              selections: [.field(.mock("bodyTemperature"))]
            )),
            .inlineFragment(.mock(
              parentType: Union_ClassroomPet,
              selections: [
                .inlineFragment(.mock(
                  parentType: Interface_Pet,
                  selections: [.field(.mock("species"))]
                )),
              ]
            )),
          ]
        )))])

    let asWarmBlooded_expected = [
      CompilationResult.Selection.field(.mock("bodyTemperature")),
    ]

    let asClassroomPet_asPet_expected = [
      CompilationResult.Selection.field(.mock("species")),
    ]

    // when
    buildSubjectOperation()

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

  /// Example:
  /// query {
  ///  allAnimals {
  ///    ...AnimalDetails
  ///  }
  /// }
  ///
  /// fragment AnimalDetails on Animal {
  ///   species
  /// }
  ///
  /// Expected:
  /// AllAnimal.mergedSelections: [field_species, fragment_AnimalDetails]
  func test__mergedSelections__givenChildIsNamedFragmentOnSameType_mergesFragmentFieldsAndMaintainsFragment() {
    // given
    let Interface_Animal = GraphQLInterfaceType.mock("Animal")
    let Field_Species = CompilationResult.Field.mock("species")

    let animalDetails = CompilationResult.FragmentDefinition.mock(
      "AnimalDetails",
      type: Interface_Animal,
      selections: [
        .field(Field_Species)
      ]
    )

    operation = .mock(selections: [
      .field(.mock(
        "allAnimals",
        selectionSet: .mock(
          parentType: Interface_Animal,
          selections: [
            .fragmentSpread(animalDetails),
          ]
        )))])

    let expected: [CompilationResult.Selection] = [
      .field(Field_Species),
      .fragmentSpread(animalDetails)
    ]

    // when
    buildSubjectOperation()

    let allAnimals = subject[field: "query"]?[field: "allAnimals"]
    let actual = allAnimals?.selectionSet?.mergedSelections

    // then
    expect(actual).to(shallowlyMatch(expected))
  }

  /// Example:
  /// query {
  ///  allAnimals {
  ///    ...BirdDetails
  ///  }
  /// }
  ///
  /// fragment BirdDetails on Bird {
  ///   species
  /// }
  /// Expected:
  /// AllAnimal.mergedSelections: [typeCase_AsBird]
  func test__mergedSelections__givenChildIsNamedFragmentOnMoreSpecificType_doesNotMergeFragmentFields_hasTypeCaseForNamedFragmentType() {
    // given
    let Interface_Animal = GraphQLInterfaceType.mock("Animal")
    let Object_Bird = GraphQLObjectType.mock("Bird", interfaces: [Interface_Animal])
    let Field_Species = CompilationResult.Field.mock("species")

    let birdDetails = CompilationResult.FragmentDefinition.mock(
      "BirdDetails",
      type: Object_Bird,
      selections: [
        .field(Field_Species)
      ]
    )

    operation = .mock(selections: [
      .field(.mock(
        "allAnimals",
        selectionSet: .mock(
          parentType: Interface_Animal,
          selections: [
            .fragmentSpread(birdDetails),
          ]
        )))])

    let expected: [CompilationResult.Selection] = [
      .inlineFragment(.init(parentType: Object_Bird, selections: [.fragmentSpread(birdDetails)]))
    ]

    // when
    buildSubjectOperation()

    let allAnimals = subject[field: "query"]?[field: "allAnimals"]
    let actual = allAnimals?.selectionSet?.mergedSelections

    // then
    expect(actual).to(shallowlyMatch(expected))
  }

  /// Example:
  /// query {
  ///  birds {
  ///    ...AnimalDetails
  ///  }
  /// }
  ///
  /// fragment AnimalDetails on Animal {
  ///   species
  /// }
  ///
  /// Expected:
  /// AllAnimal.mergedSelections: [field_species, fragment_AnimalDetails]
  func test__mergedSelections__givenIsObjectType_childIsNamedFragmentOnLessSpecificMatchingType_mergesFragmentFields() {
    // given
    let Interface_Animal = GraphQLInterfaceType.mock("Animal")
    let Object_Bird = GraphQLObjectType.mock("Bird", interfaces: [Interface_Animal])
    let Field_Species = CompilationResult.Field.mock("species")

    let animalDetails = CompilationResult.FragmentDefinition.mock(
      "AnimalDetails",
      type: Interface_Animal,
      selections: [
        .field(Field_Species)
      ]
    )

    operation = .mock(selections: [
      .field(.mock(
        "allAnimals",
        selectionSet: .mock(
          parentType: Object_Bird,
          selections: [
            .fragmentSpread(animalDetails),
          ]
        )))])

    let expected: [CompilationResult.Selection] = [
      .field(Field_Species),
      .fragmentSpread(animalDetails)
    ]

    // when
    buildSubjectOperation()

    let allAnimals = subject[field: "query"]?[field: "allAnimals"]
    let actual = allAnimals?.selectionSet?.mergedSelections

    // then
    expect(actual).to(shallowlyMatch(expected))
  }

  /// Example:
  /// query {
  ///  flyingAnimals {
  ///    ...AnimalDetails
  /// }
  ///
  /// fragment AnimalDetails on Animal {
  ///   species
  /// }
  /// Expected:
  /// FlyingAnimal.mergedSelections: [field_species, fragment_AnimalDetails]
  func test__mergedSelections__givenIsInterfaceType_childIsNamedFragmentOnLessSpecificMatchingType_mergesFragmentFields() {
    // given
    let Interface_Animal = GraphQLInterfaceType.mock("Animal")
    let Interface_FlyingAnimal = GraphQLInterfaceType.mock("FlyingAnimal", interfaces: [Interface_Animal])
    let Field_Species = CompilationResult.Field.mock("species")

    let animalDetails = CompilationResult.FragmentDefinition.mock(
      "AnimalDetails",
      type: Interface_Animal,
      selections: [
        .field(Field_Species)
      ]
    )

    operation = .mock(selections: [
      .field(.mock(
        "allAnimals",
        selectionSet: .mock(
          parentType: Interface_FlyingAnimal,
          selections: [
            .fragmentSpread(animalDetails),
          ]
        )))])

    let expected: [CompilationResult.Selection] = [
      .field(Field_Species),
      .fragmentSpread(animalDetails)
    ]

    // when
    buildSubjectOperation()

    let allAnimals = subject[field: "query"]?[field: "allAnimals"]
    let actual = allAnimals?.selectionSet?.mergedSelections

    // then
    expect(actual).to(shallowlyMatch(expected))
  }

  /// Example:
  /// query {
  ///  rocks {
  ///    ...BirdDetails
  ///  }
  /// }
  ///
  /// fragment BirdDetails on Bird {
  ///   species
  /// }
  /// Expected:
  /// Rocks.mergedSelections: [typeCase_AsBird]
  func test__mergedSelections__givenChildIsNamedFragmentOnUnrelatedType_doesNotMergeFragmentFields_hasTypeCaseForNamedFragmentType() {
    // given
    let Interface_Animal = GraphQLInterfaceType.mock("Animal")
    let Object_Bird = GraphQLObjectType.mock("Bird", interfaces: [Interface_Animal])
    let Object_Rock = GraphQLObjectType.mock("Rock")
    let Field_Species = CompilationResult.Field.mock("species")

    let birdDetails = CompilationResult.FragmentDefinition.mock(
      "BirdDetails",
      type: Object_Bird,
      selections: [
        .field(Field_Species)
      ]
    )

    operation = .mock(selections: [
      .field(.mock(
        "rocks",
        selectionSet: .mock(
          parentType: Object_Rock,
          selections: [
            .fragmentSpread(birdDetails),
          ]
        )))])

    let expected: [CompilationResult.Selection] = [
      .inlineFragment(.init(parentType: Object_Bird, selections: [.fragmentSpread(birdDetails)]))
    ]

    // when
    buildSubjectOperation()

    let rocks = subject[field: "query"]?[field: "rocks"]
    let actual = rocks?.selectionSet?.mergedSelections

    // then
    expect(actual).to(shallowlyMatch(expected))
  }

  // MARK: - Nested Entity Field - Merged Selections

  /// Example:
  /// query {
  ///  allAnimals {
  ///    height {
  ///      feet
  ///    }
  ///    ... on Pet {
  ///      height {
  ///        meters
  ///      }
  ///    }
  ///  }
  /// }
  ///
  /// Expected:
  /// AllAnimal.mergedSelections: [feet]
  /// AllAnimal.AsPet.mergedSelections: [feet, meters]
  func test__mergedSelections__givenEntityFieldOnObjectAndTypeCase_withOtherNestedFieldInTypeCase_mergesParentFieldIntoNestedSelectionsInTypeCase() throws {
    // given
    let Interface_Animal = GraphQLInterfaceType.mock("Animal")
    let Interface_Pet = GraphQLInterfaceType.mock("Pet", interfaces: [Interface_Animal])
    let Object_Height = GraphQLObjectType.mock("Height")

    operation = .mock(selections: [
      .field(.mock(
        "allAnimals",
        selectionSet: .mock(
          parentType: Interface_Animal,
          selections: [
            .field(.mock(
              "height",
              selectionSet: .mock(
                parentType: Object_Height,
                selections: [
                  .field(.mock("feet", type: .integer()))
                ]
              ))),
            .inlineFragment(.mock(
              parentType: Interface_Pet,
              selections: [
                .field(.mock(
                  "height",
                  selectionSet: .mock(
                    parentType: Object_Height,
                    selections: [
                      .field(.mock("meters", type: .integer()))
                    ]
                  )))
              ]))
          ])))])


    // when
    buildSubjectOperation()

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

  /// Example:
  /// query {
  ///  allAnimals {
  ///    height {
  ///      feet
  ///    }
  ///    predators {
  ///      height {
  ///        meters
  ///      }
  ///    }
  ///  }
  /// }
  ///
  /// Expected:
  /// AllAnimal.mergedSelections: [feet]
  /// AllAnimal.Predator.mergedSelections: [meters]
  func test__mergedSelections__givenEntityFieldOnObjectWithSelectionSetIncludingSameFieldNameAndDifferentSelections_doesNotMergeFieldIntoNestedFieldsSelections() throws {
    // given
    let Interface_Animal = GraphQLInterfaceType.mock("Animal")
    let Object_Height = GraphQLObjectType.mock("Height")

    operation = .mock(selections: [
      .field(.mock(
        "allAnimals",
        selectionSet: .mock(
          parentType: Interface_Animal,
          selections: [
            .field(.mock(
              "height",
              selectionSet: .mock(
                parentType: Object_Height,
                selections: [
                  .field(.mock("feet", type: .integer()))
                ]
              ))),
            .field(.mock(
              "predators",
              selectionSet: .mock(
                parentType: Interface_Animal,
                selections: [
                  .field(.mock(
                    "height",
                    selectionSet: .mock(
                      parentType: Object_Height,
                      selections: [
                        .field(.mock("meters", type: .integer()))
                      ]
                    )))
                ])))
          ])))])


    // when
    buildSubjectOperation()

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

  /// Example:
  /// query {
  ///  allAnimals {
  ///    height {
  ///      feet
  ///    }
  ///    ... on Pet {
  ///      height {
  ///        meters
  ///      }
  ///    }
  ///    ... on Cat {
  ///      species
  ///    }
  ///  }
  /// }
  ///
  /// Expected:
  /// AllAnimal.mergedSelections: [feet]
  /// AllAnimal.AsCat.mergedSelections: [feet, meters]
  func test__mergedSelections__givenEntityFieldOnInterfaceAndTypeCase_withOtherNestedFieldInTypeCase_mergesParentFieldIntoNestedSelectionsInObjectTypeCaseMatchingInterfaceTypeCase() throws {
    // given
    let Interface_Animal = GraphQLInterfaceType.mock("Animal")
    let Interface_Pet = GraphQLInterfaceType.mock("Pet", interfaces: [Interface_Animal])
    let Object_Cat = GraphQLObjectType.mock("Cat", interfaces: [Interface_Animal, Interface_Pet])
    let Object_Height = GraphQLObjectType.mock("Height")

    operation = .mock(selections: [
      .field(.mock(
        "allAnimals",
        selectionSet: .mock(
          parentType: Interface_Animal,
          selections: [
            .field(.mock(
              "height",
              selectionSet: .mock(
                parentType: Object_Height,
                selections: [
                  .field(.mock("feet", type: .integer()))
                ]
              ))),
            .inlineFragment(.mock(
              parentType: Interface_Pet,
              selections: [
                .field(.mock(
                  "height",
                  selectionSet: .mock(
                    parentType: Object_Height,
                    selections: [
                      .field(.mock("meters", type: .integer()))
                    ]
                  )))
              ])),
            .inlineFragment(.mock(
              parentType: Object_Cat,
              selections: [
                .field(.mock("species", type: .integer()))
              ]))
          ])))])


    // when
    buildSubjectOperation()

    let allAnimals = subject[field: "query"]?[field: "allAnimals"]

    let allAnimals_asCat_expected: [CompilationResult.Selection] = [
      .field(.mock("feet", type: .integer())),
      .field(.mock("meters", type: .integer())),
    ]

    let allAnimals_asCat_height_actual = allAnimals?[as: "Cat"]?[field: "height"]?.selectionSet?.mergedSelections

    // then
    expect(allAnimals_asCat_height_actual).to(shallowlyMatch(allAnimals_asCat_expected))
  }

  /// Example:
  /// query {
  ///  allAnimals {
  ///    height {
  ///      feet
  ///    }
  ///    ... on Pet {
  ///      height {
  ///        meters
  ///      }
  ///    }
  ///    ... on Elephant { // does not implement Pet
  ///      species
  ///    }
  ///  }
  /// }
  ///
  /// Expected:
  /// AllAnimal.mergedSelections: [feet]
  /// AllAnimal.AsElephant.mergedSelections: [feet]
  func test__mergedSelections__givenEntityFieldOnInterfaceAndTypeCase_withOtherNestedFieldInTypeCase_doesNotMergeParentFieldIntoNestedSelectionsInObjectTypeCaseNotMatchingInterfaceTypeCase() throws {
    // given
    let Interface_Animal = GraphQLInterfaceType.mock("Animal")
    let Interface_Pet = GraphQLInterfaceType.mock("Pet", interfaces: [Interface_Animal])
    let Object_Elephant = GraphQLObjectType.mock("Elephant", interfaces: [Interface_Animal])
    let Object_Height = GraphQLObjectType.mock("Height")

    operation = .mock(selections: [
      .field(.mock(
        "allAnimals",
        selectionSet: .mock(
          parentType: Interface_Animal,
          selections: [
            .field(.mock(
              "height",
              selectionSet: .mock(
                parentType: Object_Height,
                selections: [
                  .field(.mock("feet", type: .integer()))
                ]
              ))),
            .inlineFragment(.mock(
              parentType: Interface_Pet,
              selections: [
                .field(.mock(
                  "height",
                  selectionSet: .mock(
                    parentType: Object_Height,
                    selections: [
                      .field(.mock("meters", type: .integer()))
                    ]
                  )))
              ])),
            .inlineFragment(.mock(
              parentType: Object_Elephant,
              selections: [
                .field(.mock("species", type: .integer()))
              ]))
          ])))])


    // when
    buildSubjectOperation()

    let allAnimals = subject[field: "query"]?[field: "allAnimals"]

    let allAnimals_asElephant_expected: [CompilationResult.Selection] = [
      .field(.mock("feet", type: .integer()))
    ]

    let allAnimals_asElephant_height_actual = allAnimals?[as: "Elephant"]?[field: "height"]?.selectionSet?.mergedSelections

    // then
    expect(allAnimals_asElephant_height_actual).to(shallowlyMatch(allAnimals_asElephant_expected))
  }

  /// Example:
  /// query {
  ///  allAnimals {
  ///    height {
  ///      feet
  ///    }
  ///    ... on Pet {
  ///      height {
  ///        meters
  ///      }
  ///      ... on WarmBlooded {
  ///        height {
  ///          inches
  ///        }
  ///      }
  ///    }
  ///    ... on WarmBlooded {
  ///      height {
  ///        yards
  ///      }
  ///    }
  ///  }
  /// }
  ///
  /// Expected:
  /// AllAnimal.Height.mergedSelections: [feet]
  /// AllAnimal.AsPet.Height.mergedSelections: [feet, meters]
  /// AllAnimal.AsPet.AsWarmBlooded.Height.mergedSelections: [feet, meters, inches, yards]
  /// AllAnimal.AsWarmBlooded.Height.mergedSelections: [feet, yards]
  func test__mergedSelections__givenEntityFieldOnEntityWithDeepNestedTypeCases_eachTypeCaseHasDifferentNestedEntityFields_mergesFieldIntoMatchingNestedTypeCases() throws {
    // given
    let Interface_Animal = GraphQLInterfaceType.mock("Animal")
    let Interface_Pet = GraphQLInterfaceType.mock("Pet", interfaces: [Interface_Animal])
    let Interface_WarmBlooded = GraphQLInterfaceType.mock("WarmBlooded", interfaces: [Interface_Animal])
    let Object_Height = GraphQLObjectType.mock("Height")

    operation = .mock(selections: [
      .field(.mock(
        "allAnimals",
        selectionSet: .mock(
          parentType: Interface_Animal,
          selections: [
            .field(.mock(
              "height",
              selectionSet: .mock(
                parentType: Object_Height,
                selections: [
                  .field(.mock("feet", type: .integer()))
                ]
              ))),
            .inlineFragment(.mock(
              parentType: Interface_Pet,
              selections: [
                .field(.mock(
                  "height",
                  selectionSet: .mock(
                    parentType: Object_Height,
                    selections: [
                      .field(.mock("meters", type: .integer()))
                    ]
                  ))),
                .inlineFragment(.mock(
                  parentType: Interface_WarmBlooded,
                  selections: [
                    .field(.mock(
                      "height",
                      selectionSet: .mock(
                        parentType: Object_Height,
                        selections: [
                          .field(.mock("inches", type: .integer()))
                        ]
                      )))
                  ]))
              ])),
            .inlineFragment(.mock(
              parentType: Interface_WarmBlooded,
              selections: [
                .field(.mock(
                  "height",
                  selectionSet: .mock(
                    parentType: Object_Height,
                    selections: [
                      .field(.mock("yards", type: .integer()))
                    ]
                  )))
              ]))
          ])))])


    // when
    buildSubjectOperation()

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
}
