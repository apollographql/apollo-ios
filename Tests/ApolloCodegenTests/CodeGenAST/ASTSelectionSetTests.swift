import XCTest
import Nimble
import OrderedCollections
@testable import ApolloCodegenLib
import ApolloTestSupport
import ApolloCodegenTestSupport
import ApolloAPI

class ASTSelectionSetTests: XCTestCase {

  var mockCompilationResult: CompilationResult!

  override func setUp() {
    super.setUp()
    mockCompilationResult = CompilationResult.mock()
  }

  override func tearDown() {
    mockCompilationResult = nil
    super.tearDown()
  }

  // MARK: - Children Computation

  // MARK: Children - Fragment Type

  /// Example:
  /// query {
  ///  allAnimals {
  ///    ...AnimalDetails
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

    let subject = ASTSelectionSet(selectionSet: .mock(
      parentType: Interface_Animal,
      selections: [
        .fragmentSpread(animalDetails),
      ]
    ), compilationResult: mockCompilationResult)

    // then
    expect(subject.children).to(beEmpty())
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

    let subject = ASTSelectionSet(selectionSet: .mock(
      parentType: Interface_Animal,
      selections: [
        .fragmentSpread(birdDetails),
      ]
    ), compilationResult: mockCompilationResult)

    // then
    expect(subject.children.count).to(equal(1))
    let child = subject.children["Bird"]!
    expect(child.parent).to(beIdenticalTo(subject))
    expect(child.type).to(equal(Object_Bird))
    expect(child.selections).to(equal([.fragmentSpread(birdDetails)]))
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

    let subject = ASTSelectionSet(selectionSet: .mock(
      parentType: Object_Bird,
      selections: [
        .fragmentSpread(animalDetails),
      ]
    ), compilationResult: mockCompilationResult)

    // then
    expect(subject.children).to(beEmpty())
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

    let subject = ASTSelectionSet(selectionSet: .mock(
      parentType: Interface_FlyingAnimal,
      selections: [
        .fragmentSpread(animalDetails),
      ]
    ), compilationResult: mockCompilationResult)

    // then
    expect(subject.children).to(beEmpty())
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

    let subject = ASTSelectionSet(selectionSet: .mock(
      parentType: Object_Rock,
      selections: [
        .fragmentSpread(animalDetails),
      ]
    ), compilationResult: mockCompilationResult)

    // then
    expect(subject.children.count).to(equal(1))
    let child = subject.children["Animal"]!
    expect(child.parent).to(beIdenticalTo(subject))
    expect(child.type).to(equal(Interface_Animal))
    expect(child.selections).to(equal([.fragmentSpread(animalDetails)]))
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

    let parent = ASTSelectionSet(selectionSet: .mock(
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
    ), compilationResult: mockCompilationResult)

    // when
    let onClassroomPet = parent.children["ClassroomPet"]!
    let onClassroomPet_onBird = onClassroomPet.children["Bird"]!

    // then
    expect(onClassroomPet.parent).to(beIdenticalTo(parent))
    expect(onClassroomPet.type).to(beIdenticalTo(Union_ClassroomPet))
    expect(onClassroomPet.children.count).to(equal(1))

    expect(onClassroomPet_onBird.parent).to(beIdenticalTo(onClassroomPet))
    expect(onClassroomPet_onBird.type).to(beIdenticalTo(Object_Bird))
    expect(onClassroomPet_onBird.selections).to(equal([Field_Species]))
  }

  // MARK: Children - Type Cases

  /// Example:
  /// query { // On A
  ///   A
  ///   ... on A {
  ///     B
  ///   }
  /// }
  ///
  /// Expected:
  /// Query.Children: { }
  func test__children__givenInlineFragment_onSameType_mergesTypeCaseIn_doesNotHaveTypeCaseChild() {
    // given
    let Object_A = GraphQLObjectType.mock("A")

    let selectionSet = CompilationResult.SelectionSet.mock(
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

    // when
    let actual = ASTSelectionSet(selectionSet: selectionSet, compilationResult: mockCompilationResult)

    // then
    expect(actual.children).to(beEmpty())
  }

  /// Example:
  /// type B implements A {}
  ///
  /// query { // On B
  ///   A
  ///   ... on A {
  ///     B
  ///   }
  /// }
  ///
  /// Expected:
  /// Query.Children: { }
  func test__children__givenInlineFragment_onMatchingType_mergesTypeCaseIn_doesNotHaveTypeCaseChild() {
    // given
    let Interface_A = GraphQLInterfaceType.mock("A")
    let Object_B = GraphQLObjectType.mock("B", interfaces: [Interface_A])

    let selectionSet = CompilationResult.SelectionSet.mock(
      parentType: Object_B,
      selections: [
        .field(.mock("A")),
        .inlineFragment(.mock(
          parentType: Interface_A,
          selections: [
            .field(.mock("B")),
          ]
        ))
      ])

    // when
    let actual = ASTSelectionSet(selectionSet: selectionSet, compilationResult: mockCompilationResult)

    // then
    expect(actual.children).to(beEmpty())
  }

  /// Example:
  /// query { // On A
  ///   A
  ///   ... on B {
  ///     B
  ///   }
  /// }
  ///
  /// Expected:
  /// Query.Children: {
  ///   ... on B
  /// }
  func test__children__givenInlineFragment_onNonMatchingType_doesNotMergeTypeCaseIn_hasChildTypeCase() {
    // given
    let Object_A = GraphQLObjectType.mock("A")
    let Object_B = GraphQLObjectType.mock("B")

    let selectionSet = CompilationResult.SelectionSet.mock(
      parentType: Object_A,
      selections: [
        .field(.mock("A")),
        .inlineFragment(.mock(
          parentType: Object_B,
          selections: [
            .field(.mock("B")),
          ]
        ))
      ])

    // when
    let actual = ASTSelectionSet(selectionSet: selectionSet, compilationResult: mockCompilationResult)

    let expected: OrderedDictionary<String, ASTSelectionSet> = [
      "B": ASTSelectionSet(
        selectionSet: .mock(
          parentType: Object_B,
          selections: [
            .field(.mock("B")),
          ]),
        parent: actual),
    ]

    // then
    expect(actual.children).to(equal(expected))
  }

  // MARK: Children - Group Duplicate Type Cases

  /// Example:
  /// query {
  ///   ... on InterfaceA {
  ///     A
  ///   }
  ///   ... on InterfaceA {
  ///     B
  ///   }
  /// }
  ///
  /// Expected:
  /// Query.Children: {
  ///   ... on InterfaceA {
  ///     A
  ///     B
  ///   }
  /// }
  func test__children__givenInlineFragmentsWithSameType_deduplicatesChildren() {
    // given
    let selectionSet = CompilationResult.SelectionSet.mock(
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
      ]
    )

    let actual = ASTSelectionSet(selectionSet: selectionSet, compilationResult: mockCompilationResult)

    let expectedChildren: [ASTSelectionSet] = [
      .init(
        selectionSet: .init(
          parentType: GraphQLInterfaceType.mock("InterfaceA"),
          selections: [
            .field(.mock("A")),
            .field(.mock("B")),
          ]),
        parent: actual)
    ]

    // then
    expect(actual.children.values.elements).to(equal(expectedChildren))
  }

  /// Example:
  /// query {
  ///   ... on InterfaceA {
  ///     A
  ///   }
  ///   ... on InterfaceB {
  ///     B
  ///   }
  /// }
  ///
  /// Expected:
  /// Query.Children: {
  ///   ... on InterfaceA {
  ///     A
  ///   }
  ///   ... on InterfaceB {
  ///     B
  ///   }
  /// }
  func test__children__givenInlineFragmentsWithDifferentType_hasSeperateChildrenChildren() {
    // given
    let selectionSet = CompilationResult.SelectionSet.mock(
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
      ]
    )

    let actual = ASTSelectionSet(selectionSet: selectionSet, compilationResult: mockCompilationResult)

    let expectedChildren: [ASTSelectionSet] = [
      .init(
        selectionSet: .init(
          parentType: GraphQLInterfaceType.mock("InterfaceA"),
          selections: [
            .field(.mock("A")),
          ]),
        parent: actual),
      .init(
        selectionSet: .init(
          parentType: GraphQLInterfaceType.mock("InterfaceB"),
          selections: [
            .field(.mock("B")),
          ]),
        parent: actual)
    ]

    // then
    expect(actual.children.values.elements).to(equal(expectedChildren))
  }

  // MARK: Children - Group Duplicate Fragments

  /// Example:
  /// fragment FragmentB on B {
  ///   C
  /// }
  ///
  /// query { // on A
  ///   ... FragmentB
  ///   ... FragmentB
  /// }
  ///
  /// Expected:
  /// Query.Children: {
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

    let selectionSet = CompilationResult.SelectionSet.mock(
      parentType: InterfaceA,
      selections: [
        .fragmentSpread(FragmentB),
        .fragmentSpread(FragmentB),
      ]
    )

    let actual = ASTSelectionSet(selectionSet: selectionSet, compilationResult: mockCompilationResult)

    let expectedChildren: [ASTSelectionSet] = [
      .init(
        selectionSet: .init(
          parentType: InterfaceB,
          selections: [
            .fragmentSpread(FragmentB),
          ]),
        parent: actual)
    ]

    // then
    expect(actual.children.values.elements).to(equal(expectedChildren))
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
  /// query { // on A
  ///   ... FragmentB1
  ///   ... FragmentB2
  /// }
  ///
  /// Expected:
  /// Query.Children: {
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

    let selectionSet = CompilationResult.SelectionSet.mock(
      parentType: InterfaceA,
      selections: [
        .fragmentSpread(FragmentB1),
        .fragmentSpread(FragmentB2),
      ]
    )

    let actual = ASTSelectionSet(selectionSet: selectionSet, compilationResult: mockCompilationResult)

    let expectedChildren: [ASTSelectionSet] = [
      .init(
        selectionSet: .init(
          parentType: InterfaceB,
          selections: [
            .fragmentSpread(FragmentB1),
            .fragmentSpread(FragmentB2),
          ]),
        parent: actual)
    ]

    // then
    expect(actual.children.values.elements).to(equal(expectedChildren))
  }

  // MARK: - Selections

  // MARK: Selections - Group Duplicate Fields

  func test__selections__givenFieldSelectionsWithSameName_scalarType_deduplicatesSelection() {
    // given
    let selectionSet = CompilationResult.SelectionSet.mock(
      selections: [
        .field(.mock("A", type: GraphQLScalarType.integer())),
        .field(.mock("A", type: GraphQLScalarType.integer()))
      ]
    )

    let expected: [CompilationResult.Selection] = [
      .field(.mock("A", type: GraphQLScalarType.integer()))
    ]

    // when
    let actual = ASTSelectionSet(selectionSet: selectionSet, compilationResult: mockCompilationResult)

    // then
    expect(actual.selections).to(equal(expected))
  }

  func test__selections__givenFieldSelectionsWithSameNameDifferentAlias_scalarType_doesNotDeduplicateSelection() {
    // given
    let selectionSet = CompilationResult.SelectionSet.mock(
      selections: [
        .field(.mock("A", alias: "B", type: GraphQLScalarType.integer())),
        .field(.mock("A", alias: "C", type: GraphQLScalarType.integer()))
      ]
    )

    let expected: [CompilationResult.Selection] = [
      .field(.mock("A", alias: "B", type: GraphQLScalarType.integer())),
      .field(.mock("A", alias: "C", type: GraphQLScalarType.integer()))
    ]

    // when
    let actual = ASTSelectionSet(selectionSet: selectionSet, compilationResult: mockCompilationResult)

    // then
    expect(actual.selections).to(equal(expected))
  }

  func test__selections__givenFieldSelectionsWithSameResponseKey_onObjectWithDifferentChildSelections_mergesChildSelectionsIntoOneField() {
    // given
    let Object_A = GraphQLObjectType.mock("A")

    let selectionSet = CompilationResult.SelectionSet.mock(
      selections: [
        .field(.mock(
          "A",
          type: .named(Object_A),
          selectionSet: .mock(
            parentType: Object_A,
            selections: [
              .field(.mock("B", type: GraphQLScalarType.integer()))
            ]
          ))),
        .field(.mock(
          "A",
          type: .named(Object_A),
          selectionSet: .mock(
            parentType: Object_A,
            selections: [
              .field(.mock("C", type: GraphQLScalarType.integer()))
            ]
          )))
      ]
    )

    let expected: [CompilationResult.Selection] = [
      .field(.mock(
        "A",
        type: .named(Object_A),
        selectionSet: .mock(
          parentType: Object_A,
          selections: [
            .field(.mock("B", type: GraphQLScalarType.integer())),
            .field(.mock("C", type: GraphQLScalarType.integer()))
          ]
        )))
    ]

    // when
    let actual = ASTSelectionSet(selectionSet: selectionSet, compilationResult: mockCompilationResult)

    // then
    expect(actual.selections).to(equal(expected))
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

    let selectionSet = CompilationResult.SelectionSet.mock(
      selections: [
        .field(.mock(
          "A",
          type: .named(Object_A),
          selectionSet: .mock(
            parentType: Object_A,
            selections: [
              .field(.mock("B", type: GraphQLScalarType.integer())),
              .field(.mock("C", type: GraphQLScalarType.integer())),
            ]
          ))),
        .field(.mock(
          "A",
          type: .named(Object_A),
          selectionSet: .mock(
            parentType: Object_A,
            selections: [
              .field(.mock("B", type: GraphQLScalarType.integer())),
              .field(.mock("D", type: GraphQLScalarType.integer())),
            ]
          )))
      ]
    )

    let expected: [CompilationResult.Selection] = [
      .field(.mock(
        "A",
        type: .named(Object_A),
        selectionSet: .mock(
          parentType: Object_A,
          selections: [
            .field(.mock("B", type: GraphQLScalarType.integer())),
            .field(.mock("C", type: GraphQLScalarType.integer())),
            .field(.mock("D", type: GraphQLScalarType.integer())),
          ]
        )))
    ]

    // when
    let actual = ASTSelectionSet(selectionSet: selectionSet, compilationResult: mockCompilationResult)

    // then
    expect(actual.selections).to(equal(expected))
  }

  // MARK: Selections - Type Cases

  /// Example:
  /// query { // On A
  ///   A
  ///   ... on A {
  ///     B
  ///   }
  /// }
  ///
  /// Expected:
  /// Query.Selections: {
  ///   A
  ///   B
  /// }
  func test__selections__givenInlineFragment_onSameType_mergesTypeCaseIn() {
    // given
    let Object_A = GraphQLObjectType.mock("A")

    let selectionSet = CompilationResult.SelectionSet.mock(
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

    let expected: [CompilationResult.Selection] = [
      .field(.mock("A")),
      .field(.mock("B")),
    ]

    // when
    let actual = ASTSelectionSet(selectionSet: selectionSet, compilationResult: mockCompilationResult)

    // then
    expect(actual.selections).to(equal(expected))
  }

  /// Example:
  /// type B implements A {}
  ///
  /// query { // On B
  ///   A
  ///   ... on A {
  ///     B
  ///   }
  /// }
  ///
  /// Expected:
  /// Query.Selections: {
  ///   A
  ///   B
  /// }
  func test__selections__givenInlineFragment_onMatchingType_mergesTypeCaseIn() {
    // given
    let Interface_A = GraphQLInterfaceType.mock("A")
    let Object_B = GraphQLObjectType.mock("B", interfaces: [Interface_A])

    let selectionSet = CompilationResult.SelectionSet.mock(
      parentType: Object_B,
      selections: [
        .field(.mock("A")),
        .inlineFragment(.mock(
          parentType: Interface_A,
          selections: [
            .field(.mock("B")),
          ]
        ))
      ])

    let expected: [CompilationResult.Selection] = [
      .field(.mock("A")),
      .field(.mock("B")),
    ]

    // when
    let actual = ASTSelectionSet(selectionSet: selectionSet, compilationResult: mockCompilationResult)

    // then
    expect(actual.selections).to(equal(expected))
  }

  /// Example:
  /// query { // On A
  ///   A
  ///   ... on B {
  ///     B
  ///   }
  /// }
  ///
  /// Expected:
  /// Query.Selections: {
  ///   A
  ///   ... on B {
  ///     B
  ///   }
  /// }
  func test__selections__givenInlineFragment_onNonMatchingType_doesNotMergeTypeCaseIn() {
    // given
    let Object_A = GraphQLObjectType.mock("A")
    let Object_B = GraphQLObjectType.mock("B")

    let selectionSet = CompilationResult.SelectionSet.mock(
      parentType: Object_A,
      selections: [
        .field(.mock("A")),
        .inlineFragment(.mock(
          parentType: Object_B,
          selections: [
            .field(.mock("B")),
          ]
        ))
      ])

    let expected: [CompilationResult.Selection] = [
      .field(.mock("A")),
      .inlineFragment(.mock(
        parentType: Object_B,
        selections: [
          .field(.mock("B")),
        ]
      ))
    ]

    // when
    let actual = ASTSelectionSet(selectionSet: selectionSet, compilationResult: mockCompilationResult)

    // then
    expect(actual.selections).to(equal(expected))
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
    let selectionSet = CompilationResult.SelectionSet.mock(
      selections: [
        .inlineFragment(.mock(parentType: GraphQLInterfaceType.mock("InterfaceA"))),
        .inlineFragment(.mock(parentType: GraphQLInterfaceType.mock("InterfaceA"))),
      ]
    )

    let expected: [CompilationResult.Selection] = [
      .inlineFragment(.mock(parentType: GraphQLInterfaceType.mock("InterfaceA")))
    ]

    // when
    let actual = ASTSelectionSet(selectionSet: selectionSet, compilationResult: mockCompilationResult)

    // then
    expect(actual.selections).to(equal(expected))
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
    let selectionSet = CompilationResult.SelectionSet.mock(
      selections: [
        .inlineFragment(.mock(parentType: GraphQLObjectType.mock("ObjectA"))),
        .inlineFragment(.mock(parentType: GraphQLObjectType.mock("ObjectA"))),
      ]
    )

    let expected: [CompilationResult.Selection] = [
      .inlineFragment(.mock(parentType: GraphQLObjectType.mock("ObjectA"))),
    ]

    // when
    let actual = ASTSelectionSet(selectionSet: selectionSet, compilationResult: mockCompilationResult)

    // then
    expect(actual.selections).to(equal(expected))
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
    let selectionSet = CompilationResult.SelectionSet.mock(
      selections: [
        .inlineFragment(.mock(parentType: GraphQLUnionType.mock("UnionA"))),
        .inlineFragment(.mock(parentType: GraphQLUnionType.mock("UnionA"))),
      ]
    )

    let expected: [CompilationResult.Selection] = [
      .inlineFragment(.mock(parentType: GraphQLUnionType.mock("UnionA"))),
    ]

    // when
    let actual = ASTSelectionSet(selectionSet: selectionSet, compilationResult: mockCompilationResult)

    // then
    expect(actual.selections).to(equal(expected))
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
    let selectionSet = CompilationResult.SelectionSet.mock(
      selections: [
        .inlineFragment(.mock(parentType: GraphQLInterfaceType.mock("InterfaceA"))),
        .inlineFragment(.mock(parentType: GraphQLInterfaceType.mock("InterfaceB"))),
      ]
    )

    let expected: [CompilationResult.Selection] = [
      .inlineFragment(.mock(parentType: GraphQLInterfaceType.mock("InterfaceA"))),
      .inlineFragment(.mock(parentType: GraphQLInterfaceType.mock("InterfaceB"))),
    ]

    // when
    let actual = ASTSelectionSet(selectionSet: selectionSet, compilationResult: mockCompilationResult)

    // then
    expect(actual.selections).to(equal(expected))
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
  /// A.Selections: {
  ///   inlineFragment on A {
  ///     B
  ///     C
  ///     D
  ///   }
  /// }
  func test__selections__givenInlineFragmentsWithSameType_withSameAndDifferentChildSelections_mergesChildSelectionsIntoOneTypeCaseAndDeduplicatesChildSelections() {
    // given
    let Object_A = GraphQLObjectType.mock("A")

    let selectionSet = CompilationResult.SelectionSet.mock(
      selections: [
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
      .inlineFragment(.mock(
        parentType: Object_A,
        selections: [
          .field(.mock("B", type: GraphQLScalarType.integer())),
          .field(.mock("C", type: GraphQLScalarType.integer())),
          .field(.mock("D", type: GraphQLScalarType.integer())),
        ]
      ))
    ]

    // when
    let actual = ASTSelectionSet(selectionSet: selectionSet, compilationResult: mockCompilationResult)

    // then
    expect(actual.selections).to(equal(expected))
  }

  // MARK: Selections - Fragments

  func test__selections__givenNamedFragmentWithSelectionSet_onMatchingParentType_hasFragmentSelection() {
    // given
    let Object_A = GraphQLObjectType.mock("A")

    let selectionSet = CompilationResult.SelectionSet.mock(
      parentType: Object_A,
      selections: [
        .fragmentSpread(.mock(
          "FragmentA",
          type: Object_A,
          selections: [
            .field(.mock("A")),
          ])),
      ]
    )

    let expected: [CompilationResult.Selection] = [
      .fragmentSpread(.mock("FragmentA", type: Object_A)),
    ]

    // when
    let actual = ASTSelectionSet(selectionSet: selectionSet, compilationResult: mockCompilationResult)

    // then
    expect(actual.selections).to(equal(expected))
  }

  // MARK: Selections - Group Duplicate Fragments

  func test__selections__givenNamedFragmentsWithSameName_onMatchingParentType_deduplicatesSelection() {
    // given
    let Object_A = GraphQLObjectType.mock("A")

    let selectionSet = CompilationResult.SelectionSet.mock(
      parentType: Object_A,
      selections: [
        .fragmentSpread(.mock("FragmentA", type: Object_A)),
        .fragmentSpread(.mock("FragmentA", type: Object_A)),
      ]
    )

    let expected: [CompilationResult.Selection] = [
      .fragmentSpread(.mock("FragmentA", type: Object_A)),
    ]

    // when
    let actual = ASTSelectionSet(selectionSet: selectionSet, compilationResult: mockCompilationResult)

    // then
    expect(actual.selections).to(equal(expected))
  }

  func test__selections__givenNamedFragmentsWithDifferentNames_onMatchingParentType_doesNotDeduplicateSelection() {
    // given
    let Object_A = GraphQLObjectType.mock("A")

    let selectionSet = CompilationResult.SelectionSet.mock(
      parentType: Object_A,
      selections: [
        .fragmentSpread(.mock("FragmentA", type: Object_A)),
        .fragmentSpread(.mock("FragmentB", type: Object_A)),
      ]
    )

    let expected: [CompilationResult.Selection] = [
      .fragmentSpread(.mock("FragmentA", type: Object_A)),
      .fragmentSpread(.mock("FragmentB", type: Object_A)),
    ]

    // when
    let actual = ASTSelectionSet(selectionSet: selectionSet, compilationResult: mockCompilationResult)

    // then
    expect(actual.selections).to(equal(expected))
  }

  func test__selections__givenNamedFragmentsWithSameName_onNonMatchingParentType_deduplicatesSelectionIntoSingleTypeCase() {
    // given
    let Object_A = GraphQLObjectType.mock("A")
    let Interface_B = GraphQLInterfaceType.mock("B")

    let selectionSet = CompilationResult.SelectionSet.mock(
      parentType: Object_A,
      selections: [
        .fragmentSpread(.mock("FragmentA", type: Interface_B)),
        .fragmentSpread(.mock("FragmentA", type: Interface_B)),
      ]
    )

    let expected: [CompilationResult.Selection] = [
      .inlineFragment(.mock(
        parentType: Interface_B,
        selections: [
          .fragmentSpread(.mock("FragmentA", type: Interface_B))
        ])),
    ]

    // when
    let actual = ASTSelectionSet(selectionSet: selectionSet, compilationResult: mockCompilationResult)

    // then
    expect(actual.selections).to(equal(expected))
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
  /// query { // on A
  ///   ...FragmentA
  ///   ...FragmentB
  /// }
  ///
  /// Expected:
  /// Query.selections = {
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
        .field(.mock("B", type: .named(GraphQLScalarType.integer()))),
      ])
    let Fragment_B = CompilationResult.FragmentDefinition.mock(
      "FragmentB",
      type: Interface_B,
      selections: [
        .field(.mock("C", type: .named(GraphQLScalarType.integer()))),
      ])

    let selectionSet = CompilationResult.SelectionSet.mock(
      parentType: Object_A,
      selections: [
        .fragmentSpread(Fragment_A),
        .fragmentSpread(Fragment_B),
      ]
    )

    let expected: [CompilationResult.Selection] = [
      .inlineFragment(.mock(
        parentType: Interface_B,
        selections: [
          .fragmentSpread(Fragment_A),
          .fragmentSpread(Fragment_B),
        ])),
    ]

    // when
    let actual = ASTSelectionSet(selectionSet: selectionSet, compilationResult: mockCompilationResult)

    // then
    expect(actual.selections).to(equal(expected))
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
        .field(.mock("B", type: .named(GraphQLScalarType.integer()))),
      ])
    let Fragment_C = CompilationResult.FragmentDefinition.mock(
      "FragmentC",
      type: Interface_C,
      selections: [
        .field(.mock("C", type: .named(GraphQLScalarType.integer()))),
      ])

    let selectionSet = CompilationResult.SelectionSet.mock(
      parentType: Object_A,
      selections: [
        .fragmentSpread(Fragment_B),
        .fragmentSpread(Fragment_C),
      ]
    )

    let expected: [CompilationResult.Selection] = [
      .inlineFragment(.mock(
        parentType: Interface_B,
        selections: [
          .fragmentSpread(Fragment_B),
        ])),
      .inlineFragment(.mock(
        parentType: Interface_C,
        selections: [
          .fragmentSpread(Fragment_C),
        ])),
    ]

    // when
    let actual = ASTSelectionSet(selectionSet: selectionSet, compilationResult: mockCompilationResult)

    // then
    expect(actual.selections).to(equal(expected))
  }

  // MARK: - Merged Selections

  func test__mergedSelections__givenSelectionSetWithNoSelectionsAndNoParent_returnsNil() {
    // given
    let selectionSet = CompilationResult.SelectionSet.mock()
    
    // when
    let actual = ASTSelectionSet(selectionSet: selectionSet, compilationResult: mockCompilationResult)
      .mergedSelections

    // then
    expect(actual.isEmpty).to(beTrue())
  }

  func test__mergedSelections__givenSelectionSetWithSelections_returnsSelections() {
    // given
    let expected = [CompilationResult.Selection.field(.mock())]

    let selectionSet = CompilationResult.SelectionSet.mock()
    selectionSet.selections = expected

    // when
    let actual = ASTSelectionSet(selectionSet: selectionSet, compilationResult: mockCompilationResult)
      .mergedSelections

    // then
    expect(actual).to(equal(expected))
  }

  func test__mergedSelections__givenSelectionSetWithSelectionsAndParentFields_returnsSelfAndParentFields() {
    // given
    let parent = ASTSelectionSet(selectionSet: .mock(
      parentType: GraphQLObjectType.mock("A"),
      selections: [
        .field(.mock("A")),
        .inlineFragment(.mock(
          parentType: GraphQLObjectType.mock("B"),
          selections: [.field(.mock("B"))]
        ))
      ]
    ), compilationResult: mockCompilationResult)

    let subject = parent.children["B"]!

    let expected: [CompilationResult.Selection] = [
      .field(.mock("B")),
      .field(.mock("A")),
    ]

    // when
    let actual = subject.mergedSelections

    // then
    expect(actual).to(equal(expected))
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
  /// Both selection sets should have mergedSelections [wingspan, species]
  func test__mergedSelections__givenIsObjectType_siblingSelectionSetIsTheSameObjectType_mergesSiblingSelections() {
    // given
    let parent = ASTSelectionSet(selectionSet: .mock(
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
    ), compilationResult: mockCompilationResult)

    let expected = [
      CompilationResult.Selection.field(.mock("wingspan")),
      CompilationResult.Selection.field(.mock("species"))
    ]

    // when
    let actual = parent.children["Bird"]?.mergedSelections

    // then
    expect(parent.children.count).to(equal(1))
    expect(actual).to(equal(expected))
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
    let parent = ASTSelectionSet(selectionSet: .mock(
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
    ), compilationResult: mockCompilationResult)

    let sibling1 = parent.children["Bird"]!
    let sibling2 = parent.children["Cat"]!

    let sibling1Expected: [CompilationResult.Selection] = [.field(.mock("wingspan"))]

    let sibling2Expected: [CompilationResult.Selection] = [.field(.mock("species"))]

    // when
    let sibling1Actual = sibling1.mergedSelections
    let sibling2Actual = sibling2.mergedSelections

    // then
    expect(sibling1Actual).to(equal(sibling1Expected))
    expect(sibling2Actual).to(equal(sibling2Expected))
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

    let parent = ASTSelectionSet(selectionSet: .mock(
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
    ), compilationResult: mockCompilationResult)

    let sibling1 = parent.children["Bird"]!
    let sibling2 = parent.children["Pet"]!

    let sibling1Expected: [CompilationResult.Selection] = [
      .field(.mock("wingspan")),
      .field(.mock("species"))
    ]

    let sibling2Expected: [CompilationResult.Selection] = [
      .field(.mock("species"))
    ]

    // when
    let sibling1Actual = sibling1.mergedSelections
    let sibling2Actual = sibling2.mergedSelections

    // then
    expect(sibling1Actual).to(equal(sibling1Expected))
    expect(sibling2Actual).to(equal(sibling2Expected))
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

    let parent = ASTSelectionSet(selectionSet: .mock(
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
    ), compilationResult: mockCompilationResult)

    let sibling1 = parent.children["Bird"]!
    let sibling2 = parent.children["Pet"]!

    let sibling1Expected: [CompilationResult.Selection] = [.field(.mock("wingspan"))]

    let sibling2Expected: [CompilationResult.Selection] = [.field(.mock("species"))]

    // when
    let sibling1Actual = sibling1.mergedSelections
    let sibling2Actual = sibling2.mergedSelections

    // then
    expect(sibling1Actual).to(equal(SortedSelections(sibling1Expected)))
    expect(sibling2Actual).to(equal(SortedSelections(sibling2Expected)))
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

    let parent = ASTSelectionSet(selectionSet: .mock(
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
    ), compilationResult: mockCompilationResult)

    let sibling1 = parent.children["HousePet"]!
    let sibling2 = parent.children["Pet"]!

    let sibling1Expected: [CompilationResult.Selection] = [
      .field(.mock("humanName")),
      .field(.mock("species"))
    ]

    let sibling2Expected: [CompilationResult.Selection] = [
      .field(.mock("species"))
    ]

    // when
    let sibling1Actual = sibling1.mergedSelections
    let sibling2Actual = sibling2.mergedSelections

    // then
    expect(sibling1Actual).to(equal(SortedSelections(sibling1Expected)))
    expect(sibling2Actual).to(equal(SortedSelections(sibling2Expected)))
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

    let parent = ASTSelectionSet(selectionSet: .mock(
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
    ), compilationResult: mockCompilationResult)

    let sibling1 = parent.children["HousePet"]!
    let sibling2 = parent.children["Pet"]!

    let sibling1Expected: [CompilationResult.Selection] = [.field(.mock("humanName"))]

    let sibling2Expected: [CompilationResult.Selection] = [.field(.mock("species"))]

    // when
    let sibling1Actual = sibling1.mergedSelections
    let sibling2Actual = sibling2.mergedSelections

    // then
    expect(sibling1Actual).to(equal(SortedSelections(sibling1Expected)))
    expect(sibling2Actual).to(equal(SortedSelections(sibling2Expected)))
  }

  // MARK: - Merged Selections - Uncle (Parent's Sibling)

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
    let parent = ASTSelectionSet(selectionSet: .mock(
      parentType: GraphQLInterfaceType.mock("Animal"),
      selections: [
        .inlineFragment(.mock(
          parentType: GraphQLInterfaceType.mock("WarmBlooded"),
          selections: [
            .inlineFragment(.mock(
              parentType: GraphQLInterfaceType.mock("Pet"),
              selections: [.field(.mock("humanName"))]
            )),
          ]
        )),
        .inlineFragment(.mock(
          parentType: GraphQLInterfaceType.mock("Pet"),
          selections: [.field(.mock("species"))]
        )),
      ]
    ), compilationResult: mockCompilationResult)

    let onWarmBlooded_onPet_expected = [
      CompilationResult.Selection.field(.mock("humanName")),
      CompilationResult.Selection.field(.mock("species"))
    ]

    let onPet_expected = [
      CompilationResult.Selection.field(.mock("species"))
    ]

    // when
    let onWarmBlooded_onPet_actual = parent
      .children["WarmBlooded"]!
      .children["Pet"]!
      .mergedSelections

    let onPet_actual = parent
      .children["Pet"]!
      .mergedSelections

    // then
    expect(onWarmBlooded_onPet_actual).to(equal(onWarmBlooded_onPet_expected))
    expect(onPet_actual).to(equal(onPet_expected))
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

    let parent = ASTSelectionSet(selectionSet: .mock(
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
    ), compilationResult: mockCompilationResult)

    let onWarmBlooded_onBird_expected = [
      CompilationResult.Selection.field(.mock("wingspan")),
      CompilationResult.Selection.field(.mock("species"))
    ]

    let onPet_expected = [
      CompilationResult.Selection.field(.mock("species"))
    ]

    // when
    let onWarmBlooded_onBird_actual = parent
      .children["WarmBlooded"]!
      .children["Bird"]!
      .mergedSelections

    let onPet_actual = parent
      .children["Pet"]!
      .mergedSelections

    // then
    expect(onWarmBlooded_onBird_actual).to(equal(onWarmBlooded_onBird_expected))
    expect(onPet_actual).to(equal(onPet_expected))
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

    let parent = ASTSelectionSet(selectionSet: .mock(
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
    ), compilationResult: mockCompilationResult)

    let onWarmBlooded_onBird_expected = [
      CompilationResult.Selection.field(.mock("wingspan")),
    ]

    let onPet_expected = [
      CompilationResult.Selection.field(.mock("species"))
    ]

    // when
    let onWarmBlooded_onBird_actual = parent
      .children["WarmBlooded"]!
      .children["Bird"]!
      .mergedSelections

    let onPet_actual = parent
      .children["Pet"]!
      .mergedSelections

    // then
    expect(onWarmBlooded_onBird_actual).to(equal(onWarmBlooded_onBird_expected))
    expect(onPet_actual).to(equal(onPet_expected))
  }

  // MARK: Merged Selections - Uncle - Object Type <-> Object in Union Type

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

    let parent = ASTSelectionSet(selectionSet: .mock(
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
    ), compilationResult: mockCompilationResult)

    let onBird = parent.children["Bird"]!
    let onClassroomPet = parent.children["ClassroomPet"]!
    let onClassroomPet_onBird = onClassroomPet.children["Bird"]!

    let onBirdExpected = [
      Field_Wingspan,
      Field_Species
    ]

    let onClassroomPet_onBirdExpected = [
      Field_Species,
      Field_Wingspan
    ]

    // when
    let onBirdActual = onBird.mergedSelections
    let onClassroomPet_onBirdActual = onClassroomPet_onBird.mergedSelections

    // then
    expect(onBirdActual).to(equal(SortedSelections(onBirdExpected)))
    expect(onClassroomPet_onBirdActual).to(equal(SortedSelections(onClassroomPet_onBirdExpected)))
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

    let parent = ASTSelectionSet(selectionSet: .mock(
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
    ), compilationResult: mockCompilationResult)

    let onBird = parent.children["Bird"]!
    let onClassroomPet = parent.children["ClassroomPet"]!
    let onClassroomPet_onCat = onClassroomPet.children["Cat"]!

    let onBirdExpected = [
      Field_Wingspan
    ]

    let onClassroomPet_onCatExpected = [
      Field_Species
    ]

    // when
    let onBirdActual = onBird.mergedSelections
    let onClassroomPet_onCatActual = onClassroomPet_onCat.mergedSelections

    // then
    expect(onBirdActual).to(equal(SortedSelections(onBirdExpected)))
    expect(onClassroomPet_onCatActual).to(equal(SortedSelections(onClassroomPet_onCatExpected)))
  }

  // MARK: Merged Selections - Uncle - Interface in Union Type

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

    let parent = ASTSelectionSet(selectionSet: .mock(
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
    ), compilationResult: mockCompilationResult)

    let asWarmBlooded_expected = [
      CompilationResult.Selection.field(.mock("bodyTemperature")),
    ]

    let asClassroomPet_asWarmBlooded_expected = [
      CompilationResult.Selection.field(.mock("species")),
      CompilationResult.Selection.field(.mock("bodyTemperature")),
    ]

    // when
    let asWarmBlooded_actual = parent
      .children["WarmBlooded"]!
      .mergedSelections

    let asClassroomPet_asWarmBlooded_actual = parent
      .children["ClassroomPet"]!
      .children["WarmBlooded"]!
      .mergedSelections

    // then
    expect(asWarmBlooded_actual).to(equal(asWarmBlooded_expected))
    expect(asClassroomPet_asWarmBlooded_actual).to(equal(asClassroomPet_asWarmBlooded_expected))
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

    let parent = ASTSelectionSet(selectionSet: .mock(
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
    ), compilationResult: mockCompilationResult)

    /// AllAnimal.AsPet mergedSelections: [humanName]
    /// AllAnimal.AsClassroomPet.AsWarmBloodedPet mergedSelections: [species, humanName]
    let asPet_expected = [
      CompilationResult.Selection.field(.mock("humanName")),
    ]

    let asClassroomPet_asWarmBloodedPet_expected = [
      CompilationResult.Selection.field(.mock("species")),
      CompilationResult.Selection.field(.mock("humanName")),
    ]

    // when
    let asPet_actual = parent
      .children["Pet"]!
      .mergedSelections

    let asClassroomPet_asWarmBloodedPet_actual = parent
      .children["ClassroomPet"]!
      .children["WarmBloodedPet"]!
      .mergedSelections

    // then
    expect(asPet_actual).to(equal(asPet_expected))
    expect(asClassroomPet_asWarmBloodedPet_actual).to(equal(asClassroomPet_asWarmBloodedPet_expected))
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

    let parent = ASTSelectionSet(selectionSet: .mock(
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
    ), compilationResult: mockCompilationResult)

    let asWarmBlooded_expected = [
      CompilationResult.Selection.field(.mock("bodyTemperature")),
    ]

    let asClassroomPet_asPet_expected = [
      CompilationResult.Selection.field(.mock("species")),
    ]

    // when
    let asWarmBlooded_actual = parent
      .children["WarmBlooded"]!
      .mergedSelections

    let asClassroomPet_asPet_actual = parent
      .children["ClassroomPet"]!
      .children["Pet"]!
      .mergedSelections

    // then
    expect(asWarmBlooded_actual).to(equal(asWarmBlooded_expected))
    expect(asClassroomPet_asPet_actual).to(equal(asClassroomPet_asPet_expected))
  }

  // MARK: - Merged Selections - Child Fragment

  /// Example:
  /// query {
  ///  allAnimals {
  ///    ...AnimalDetails
  /// }
  ///
  /// fragment AnimalDetails on Animal {
  ///   species
  /// }
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

    let subject = ASTSelectionSet(selectionSet: .mock(
      parentType: Interface_Animal,
      selections: [
        .fragmentSpread(animalDetails),
      ]
    ), compilationResult: mockCompilationResult)

    let expected = SortedSelections(
      fields: [ASTField(Field_Species)],
      typeCases: [],
      fragments: [animalDetails]
    )

    // when
    let actual = subject.mergedSelections

    // then
    expect(actual).to(equal(expected))
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

    let subject = ASTSelectionSet(selectionSet: .mock(
      parentType: Interface_Animal,
      selections: [
        .fragmentSpread(birdDetails),
      ]
    ), compilationResult: mockCompilationResult)

    let expected = SortedSelections(
      typeCases: [
        .init(parentType: Object_Bird, selections: [.fragmentSpread(birdDetails)])
      ]
    )

    // when
    let actual = subject.mergedSelections

    // then
    expect(actual).to(equal(expected))
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

    let subject = ASTSelectionSet(selectionSet: .mock(
      parentType: Object_Bird,
      selections: [
        .fragmentSpread(animalDetails),
      ]
    ), compilationResult: mockCompilationResult)

    let expected = SortedSelections(
      fields: [ASTField(Field_Species)],
      typeCases: [],
      fragments: [animalDetails]
    )

    // when
    let actual = subject.mergedSelections

    // then
    expect(actual).to(equal(expected))
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

    let subject = ASTSelectionSet(selectionSet: .mock(
      parentType: Interface_FlyingAnimal,
      selections: [
        .fragmentSpread(animalDetails),
      ]
    ), compilationResult: mockCompilationResult)

    let expected = SortedSelections(
      fields: [ASTField(Field_Species)],
      typeCases: [],
      fragments: [animalDetails]
    )

    // when
    let actual = subject.mergedSelections

    // then
    expect(actual).to(equal(expected))
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

    let subject = ASTSelectionSet(selectionSet: .mock(
      parentType: Object_Rock,
      selections: [
        .fragmentSpread(birdDetails),
      ]
    ), compilationResult: mockCompilationResult)

    let expected = SortedSelections(
      fields: [],
      typeCases: [
        .init(parentType: Object_Bird, selections: [.fragmentSpread(birdDetails)])
      ],
      fragments: []
    )

    // when
    let actual = subject.mergedSelections

    // then
    expect(actual).to(equal(expected))
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
  /// Both height fields have merged selection builder
  /// Merged selection builder has type scopes: [
  ///   Animal: [feet],
  ///   Animal+Pet: [meters]
  /// ]
  func test__nestedEntityField_mergedSelectionBuilder__givenObjectField_withOtherSameNamedField_onChildTypeCaseSelectionSet_withOtherNestedSelections_fieldsHaveMergedSelectionBuilderWithFieldsForTypeScopes() throws {
    // given
    let Interface_Animal = GraphQLInterfaceType.mock("Animal")
    let Interface_Pet = GraphQLInterfaceType.mock("Pet", interfaces: [Interface_Animal])
    let Object_Height = GraphQLObjectType.mock("Height")

    let subject = ASTSelectionSet(selectionSet: .mock(
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
      ]), compilationResult: mockCompilationResult)


    // when
    let mergedSelectionBuilder_actual = subject
      .mergedSelectionBuilder.fieldSelectionMergedScopes["height"]

    let animalScope_expected = SortedSelections([
      .field(.mock("feet", type: .integer()))
    ])

    let animal_asPet_scope_expected = SortedSelections([
      .field(.mock("feet", type: .integer())),
      .field(.mock("meters", type: .integer()))
    ])

    let animal_height_actual = subject.selections.fields["height"]
    let animal_asPet_height_actual = subject
      .children["Pet"]?
      .selections.fields["height"]

    let animalScope_actual = mergedSelectionBuilder_actual?.selectionsForScopes[[Interface_Animal]]
    let animal_asPet_scope_actual = mergedSelectionBuilder_actual?.selectionsForScopes[[Interface_Animal]]

    // then
    expect(try animal_height_actual?.mergedSelectionBuilder)
      .to(beIdenticalTo(mergedSelectionBuilder_actual))
    expect(try animal_asPet_height_actual?.mergedSelectionBuilder)
      .to(beIdenticalTo(mergedSelectionBuilder_actual))

    expect(animalScope_actual).to(equal(animalScope_expected))
    expect(animal_asPet_scope_actual).to(equal(animal_asPet_scope_expected))
  }
}

extension ASTField {
  var mergedSelectionBuilder: MergedSelectionBuilder {
    get throws {
      guard case let .entity(entityData) = self.type else {
        throw TestError("Attempted to get MergedSelectionBuilder of non-entity field \(self)")
      }
      return entityData.enclosingEntityMergedSelectionBuilder
    }
  }
}
