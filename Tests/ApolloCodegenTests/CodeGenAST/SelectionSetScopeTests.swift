import XCTest
import Nimble
import OrderedCollections
@testable import ApolloCodegenLib
import ApolloCodegenTestSupport

class SelectionSetScopeTests: XCTestCase {

  // MARK: - Children Computation

  /// Example:
  /// query {
  ///  allAnimals {
  ///    ... on Bird {
  ///      wingspan
  ///    }
  ///   }
  /// }
  func test__children__initWithInlineFragmentWithDifferentParentType_hasChildrenForTypeCases() {
    // given
    let Interface_Animal = GraphQLInterfaceType.mock("Animal")
    let Object_Bird = GraphQLObjectType.mock("Bird")

    let childSelections: [CompilationResult.Selection] = [.field(.mock("wingspan"))]

    let subject = SelectionSetScope(selectionSet: .mock(
      parentType: Interface_Animal,
      selections: [
        .inlineFragment(.mock(
          parentType: Object_Bird,
          selections: childSelections
        )),
      ]
    ), parent: nil)

    // then
    expect(subject.children.count).to(equal(1))
    let child = subject.children[0]
    expect(child.parent).to(beIdenticalTo(subject))
    expect(child.type.name).to(equal("Bird"))
    expect(child.selections.values.elements).to(equal(childSelections))
  }

  /// Example:
  /// query {
  ///  allAnimals {
  ///    ... on Animal {
  ///      species
  ///    }
  ///   }
  /// }
  func test__children__initWithInlineFragmentWithSameParentType_hasChildrenForTypeCase() {
    // given
    let Interface_Animal = GraphQLInterfaceType.mock("Animal")

    let childSelections: [CompilationResult.Selection] = [.field(.mock("species"))]

    let subject = SelectionSetScope(selectionSet: .mock(
      parentType: Interface_Animal,
      selections: [
        .inlineFragment(.mock(
          parentType: Interface_Animal,
          selections: childSelections
        )),
      ]
    ), parent: nil)

    // then
    expect(subject.children.count).to(equal(1))
    let child = subject.children[0]
    expect(child.parent).to(beIdenticalTo(subject))
    expect(child.type).to(equal(Interface_Animal))
    expect(child.selections.values.elements).to(equal(childSelections))
  }

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
  /// Birds.children should not include a type case for asAnimal
  func test__children__initWithNamedFragmentOnTheSameType_hasNoChildTypeCase() {
    // given
    let Interface_Animal = GraphQLInterfaceType.mock("Animal")

    let animalDetails = CompilationResult.FragmentDefinition.mock("AnimalDetails", type: Interface_Animal)

    let subject = SelectionSetScope(selectionSet: .mock(
      parentType: Interface_Animal,
      selections: [
        .fragmentSpread(animalDetails),
      ]
    ), parent: nil)

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

    let subject = SelectionSetScope(selectionSet: .mock(
      parentType: Interface_Animal,
      selections: [
        .fragmentSpread(birdDetails),
      ]
    ), parent: nil)

    // then
    expect(subject.children.count).to(equal(1))
    let child = subject.children[0]
    expect(child.parent).to(beIdenticalTo(subject))
    expect(child.type).to(equal(Object_Bird))
    expect(child.selections.values.elements).to(equal([.fragmentSpread(birdDetails)]))
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

    let subject = SelectionSetScope(selectionSet: .mock(
      parentType: Object_Bird,
      selections: [
        .fragmentSpread(animalDetails),
      ]
    ), parent: nil)

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

    let subject = SelectionSetScope(selectionSet: .mock(
      parentType: Interface_FlyingAnimal,
      selections: [
        .fragmentSpread(animalDetails),
      ]
    ), parent: nil)

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

    let subject = SelectionSetScope(selectionSet: .mock(
      parentType: Object_Rock,
      selections: [
        .fragmentSpread(animalDetails),
      ]
    ), parent: nil)

    // then
    expect(subject.children.count).to(equal(1))
    let child = subject.children[0]
    expect(child.parent).to(beIdenticalTo(subject))
    expect(child.type).to(equal(Interface_Animal))
    expect(child.selections.values.elements).to(equal([.fragmentSpread(animalDetails)]))
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

    let parent = SelectionSetScope(selectionSet: .mock(
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
    ), parent: nil)

    // when
    let onClassroomPet = parent.children[0]
    let onClassroomPet_onBird = onClassroomPet.children[0]

    // then
    expect(onClassroomPet.parent).to(beIdenticalTo(parent))
    expect(onClassroomPet.type).to(beIdenticalTo(Union_ClassroomPet))
    expect(onClassroomPet.children.count).to(equal(1))

    expect(onClassroomPet_onBird.parent).to(beIdenticalTo(onClassroomPet))
    expect(onClassroomPet_onBird.type).to(beIdenticalTo(Object_Bird))
    expect(onClassroomPet_onBird.selections.values.elements).to(equal([Field_Species]))
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

    let actual = SelectionSetScope(selectionSet: selectionSet, parent: nil)

    let expectedChildren: [SelectionSetScope] = [
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
    expect(actual.children).to(equal(expectedChildren))
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

    let actual = SelectionSetScope(selectionSet: selectionSet, parent: nil)

    let expectedChildren: [SelectionSetScope] = [
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
    expect(actual.children).to(equal(expectedChildren))
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

    let actual = SelectionSetScope(selectionSet: selectionSet, parent: nil)

    let expectedChildren: [SelectionSetScope] = [
      .init(
        selectionSet: .init(
          parentType: InterfaceB,
          selections: [
            .fragmentSpread(FragmentB),
          ]),
        parent: actual)
    ]

    // then
    expect(actual.children).to(equal(expectedChildren))
  }

  // MARK: - Selections

  // MARK: Selections - Group Duplicate Fields

  func test__selections__givenFieldSelectionsWithSameName_scalarType_deduplicatesSelection() {
    // given
    let selectionSet = CompilationResult.SelectionSet.mock(
      selections: [
        .field(.mock("A", type: .named(GraphQLScalarType.integer()))),
        .field(.mock("A", type: .named(GraphQLScalarType.integer())))
      ]
    )

    let expected: [CompilationResult.Selection] = [
      .field(.mock("A", type: .named(GraphQLScalarType.integer())))
    ]

    // when
    let actual = SelectionSetScope(selectionSet: selectionSet, parent: nil)

    // then
    expect(actual.selections.values.elements).to(equal(expected))
  }

  func test__selections__givenFieldSelectionsWithSameNameDifferentAlias_scalarType_doesNotDeduplicateSelection() {
    // given
    let selectionSet = CompilationResult.SelectionSet.mock(
      selections: [
        .field(.mock("A", alias: "B", type: .named(GraphQLScalarType.integer()))),
        .field(.mock("A", alias: "C", type: .named(GraphQLScalarType.integer())))
      ]
    )

    let expected: [CompilationResult.Selection] = [
      .field(.mock("A", alias: "B", type: .named(GraphQLScalarType.integer()))),
      .field(.mock("A", alias: "C", type: .named(GraphQLScalarType.integer())))
    ]

    // when
    let actual = SelectionSetScope(selectionSet: selectionSet, parent: nil)

    // then
    expect(actual.selections.values.elements).to(equal(expected))
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
              .field(.mock("B", type: .named(GraphQLScalarType.integer())))
            ]
          ))),
        .field(.mock(
          "A",
          type: .named(Object_A),
          selectionSet: .mock(
            parentType: Object_A,
            selections: [
              .field(.mock("C", type: .named(GraphQLScalarType.integer())))
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
            .field(.mock("B", type: .named(GraphQLScalarType.integer()))),
            .field(.mock("C", type: .named(GraphQLScalarType.integer())))
          ]
        )))
    ]

    // when
    let actual = SelectionSetScope(selectionSet: selectionSet, parent: nil)

    // then
    expect(actual.selections.values.elements).to(equal(expected))
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
              .field(.mock("B", type: .named(GraphQLScalarType.integer()))),
              .field(.mock("C", type: .named(GraphQLScalarType.integer()))),
            ]
          ))),
        .field(.mock(
          "A",
          type: .named(Object_A),
          selectionSet: .mock(
            parentType: Object_A,
            selections: [
              .field(.mock("B", type: .named(GraphQLScalarType.integer()))),
              .field(.mock("D", type: .named(GraphQLScalarType.integer()))),
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
            .field(.mock("B", type: .named(GraphQLScalarType.integer()))),
            .field(.mock("C", type: .named(GraphQLScalarType.integer()))),
            .field(.mock("D", type: .named(GraphQLScalarType.integer()))),
          ]
        )))
    ]

    // when
    let actual = SelectionSetScope(selectionSet: selectionSet, parent: nil)

    // then
    expect(actual.selections.values.elements).to(equal(expected))
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
    let actual = SelectionSetScope(selectionSet: selectionSet, parent: nil)

    // then
    expect(actual.selections.values.elements).to(equal(expected))
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
    let actual = SelectionSetScope(selectionSet: selectionSet, parent: nil)

    // then
    expect(actual.selections.values.elements).to(equal(expected))
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
    let actual = SelectionSetScope(selectionSet: selectionSet, parent: nil)

    // then
    expect(actual.selections.values.elements).to(equal(expected))
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
    let actual = SelectionSetScope(selectionSet: selectionSet, parent: nil)

    // then
    expect(actual.selections.values.elements).to(equal(expected))
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
            .field(.mock("B", type: .named(GraphQLScalarType.integer()))),
            .field(.mock("C", type: .named(GraphQLScalarType.integer()))),
          ]
        )),
        .inlineFragment(.mock(
          parentType: Object_A,
          selections: [
            .field(.mock("B", type: .named(GraphQLScalarType.integer()))),
            .field(.mock("D", type: .named(GraphQLScalarType.integer()))),
          ]
        ))
      ]
    )

    let expected: [CompilationResult.Selection] = [
      .inlineFragment(.mock(
        parentType: Object_A,
        selections: [
          .field(.mock("B", type: .named(GraphQLScalarType.integer()))),
          .field(.mock("C", type: .named(GraphQLScalarType.integer()))),
          .field(.mock("D", type: .named(GraphQLScalarType.integer()))),
        ]
      ))
    ]

    // when
    let actual = SelectionSetScope(selectionSet: selectionSet, parent: nil)

    // then
    expect(actual.selections.values.elements).to(equal(expected))
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
    let actual = SelectionSetScope(selectionSet: selectionSet, parent: nil)

    // then
    expect(actual.selections.values.elements).to(equal(expected))
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
    let actual = SelectionSetScope(selectionSet: selectionSet, parent: nil)

    // then
    expect(actual.selections.values.elements).to(equal(expected))
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
    let actual = SelectionSetScope(selectionSet: selectionSet, parent: nil)

    // then
    expect(actual.selections.values.elements).to(equal(expected))
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
    let actual = SelectionSetScope(selectionSet: selectionSet, parent: nil)

    // then
    expect(actual.selections.values.elements).to(equal(expected))
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
    let actual = SelectionSetScope(selectionSet: selectionSet, parent: nil)

    // then
    expect(actual.selections.values.elements).to(equal(expected))
  }

  // MARK: - Merged Selections

  func test__mergedSelections__givenSelectionSetWithNoSelectionsAndNoParent_returnsNil() {
    // given
    let selectionSet = CompilationResult.SelectionSet.mock()
    
    // when
    let actual = SelectionSetScope(selectionSet: selectionSet, parent: nil)
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
    let actual = SelectionSetScope(selectionSet: selectionSet, parent: nil)
      .mergedSelections

    // then
    expect(actual).to(equal(MergedSelections(expected)))
  }

  func test__mergedSelections__givenSelectionSetWithSelectionsAndParentFields_returnsSelfAndParentFields() {
    // given
    let parent = SelectionSetScope(selectionSet: .mock(
      selections: [.field(.mock("A"))]
    ), parent: nil)

    let subject = SelectionSetScope(selectionSet: .mock(
      selections: [.field(.mock("B"))]
    ), parent: parent)

    let expected = subject.selections.values.elements + parent.selections.values.elements

    // when
    let actual = subject.mergedSelections

    // then
    expect(actual).to(equal(MergedSelections(expected)))
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
    let parent = SelectionSetScope(selectionSet: .mock(
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
    ), parent: nil)

    let expected = [
      CompilationResult.Selection.field(.mock("wingspan")),
      CompilationResult.Selection.field(.mock("species"))
    ]

    // when
    let actual = parent.children[0].mergedSelections

    // then
    expect(parent.children.count).to(equal(1))
    expect(actual).to(equal(MergedSelections(expected)))
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
    let parent = SelectionSetScope(selectionSet: .mock(
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
    ), parent: nil)

    let sibling1 = parent.children[0]
    let sibling2 = parent.children[1]

    let sibling1Expected = sibling1.selections.values.elements

    let sibling2Expected = sibling2.selections.values.elements

    // when
    let sibling1Actual = sibling1.mergedSelections
    let sibling2Actual = sibling2.mergedSelections

    // then
    expect(sibling1Actual).to(equal(MergedSelections(sibling1Expected)))
    expect(sibling2Actual).to(equal(MergedSelections(sibling2Expected)))
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

    let parent = SelectionSetScope(selectionSet: .mock(
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
    ), parent: nil)

    let sibling1 = parent.children[0]
    let sibling2 = parent.children[1]

    let sibling1Expected =
    sibling1.selections.values.elements +
    sibling2.selections.values.elements

    let sibling2Expected = sibling2.selections.values.elements

    // when
    let sibling1Actual = sibling1.mergedSelections
    let sibling2Actual = sibling2.mergedSelections

    // then
    expect(sibling1Actual).to(equal(MergedSelections(sibling1Expected)))
    expect(sibling2Actual).to(equal(MergedSelections(sibling2Expected)))
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
  ///   }
  /// }
  /// Expected:
  /// Bird mergedSelections: [wingspan]
  /// Pet mergedSelections: [species]
  func test__mergedSelections__givenIsObjectType_siblingSelectionSetIsUnimplementedInterface_doesNotMergeSiblingSelections() {
    // given
    let Pet = GraphQLInterfaceType.mock("Pet")
    let Bird = GraphQLObjectType.mock("Bird")

    let parent = SelectionSetScope(selectionSet: .mock(
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
    ), parent: nil)

    let sibling1 = parent.children[0]
    let sibling2 = parent.children[1]

    let sibling1Expected = sibling1.selections.values.elements

    let sibling2Expected = sibling2.selections.values.elements

    // when
    let sibling1Actual = sibling1.mergedSelections
    let sibling2Actual = sibling2.mergedSelections

    // then
    expect(sibling1Actual).to(equal(MergedSelections(sibling1Expected)))
    expect(sibling2Actual).to(equal(MergedSelections(sibling2Expected)))
  }

  // MARK: Merged Selections - Siblings - Object Type <-> Object in Union Type

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

    let parent = SelectionSetScope(selectionSet: .mock(
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
    ), parent: nil)

    let onBird = parent.children[0]
    let onClassroomPet = parent.children[1]
    let onClassroomPet_onBird = onClassroomPet.children[0]

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
    expect(onBirdActual).to(equal(MergedSelections(onBirdExpected)))
    expect(onClassroomPet_onBirdActual).to(equal(MergedSelections(onClassroomPet_onBirdExpected)))
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

    let parent = SelectionSetScope(selectionSet: .mock(
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
    ), parent: nil)

    let onBird = parent.children[0]
    let onClassroomPet = parent.children[1]
    let onClassroomPet_onCat = onClassroomPet.children[0]

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
    expect(onBirdActual).to(equal(MergedSelections(onBirdExpected)))
    expect(onClassroomPet_onCatActual).to(equal(MergedSelections(onClassroomPet_onCatExpected)))
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

    let parent = SelectionSetScope(selectionSet: .mock(
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
    ), parent: nil)

    let sibling1 = parent.children[0]
    let sibling2 = parent.children[1]

    let sibling1Expected =
    sibling1.selections.values.elements +
    sibling2.selections.values.elements

    let sibling2Expected = sibling2.selections.values.elements

    // when
    let sibling1Actual = sibling1.mergedSelections
    let sibling2Actual = sibling2.mergedSelections

    // then
    expect(sibling1Actual).to(equal(MergedSelections(sibling1Expected)))
    expect(sibling2Actual).to(equal(MergedSelections(sibling2Expected)))
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

    let parent = SelectionSetScope(selectionSet: .mock(
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
    ), parent: nil)

    let sibling1 = parent.children[0]
    let sibling2 = parent.children[1]

    let sibling1Expected = sibling1.selections.values.elements

    let sibling2Expected = sibling2.selections.values.elements

    // when
    let sibling1Actual = sibling1.mergedSelections
    let sibling2Actual = sibling2.mergedSelections

    // then
    expect(sibling1Actual).to(equal(MergedSelections(sibling1Expected)))
    expect(sibling2Actual).to(equal(MergedSelections(sibling2Expected)))
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

    let subject = SelectionSetScope(selectionSet: .mock(
      parentType: Interface_Animal,
      selections: [
        .fragmentSpread(animalDetails),
      ]
    ), parent: nil)

    let expected = MergedSelections(
      fields: [Field_Species],
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

    let subject = SelectionSetScope(selectionSet: .mock(
      parentType: Interface_Animal,
      selections: [
        .fragmentSpread(birdDetails),
      ]
    ), parent: nil)

    let expected = MergedSelections(
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

    let subject = SelectionSetScope(selectionSet: .mock(
      parentType: Object_Bird,
      selections: [
        .fragmentSpread(animalDetails),
      ]
    ), parent: nil)

    let expected = MergedSelections(
      fields: [Field_Species],
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

    let subject = SelectionSetScope(selectionSet: .mock(
      parentType: Interface_FlyingAnimal,
      selections: [
        .fragmentSpread(animalDetails),
      ]
    ), parent: nil)

    let expected = MergedSelections(
      fields: [Field_Species],
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

    let subject = SelectionSetScope(selectionSet: .mock(
      parentType: Object_Rock,
      selections: [
        .fragmentSpread(birdDetails),
      ]
    ), parent: nil)

    let expected = MergedSelections(
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

}
