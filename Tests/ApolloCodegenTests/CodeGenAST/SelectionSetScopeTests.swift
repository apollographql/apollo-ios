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
          selectionSet: .mock(
            parentType: Object_Bird,
            selections: childSelections
          ))),
      ]
    ), parent: nil)

    // then
    expect(subject.children.count).to(equal(1))
    let child = subject.children[0]
    expect(child.parent).to(beIdenticalTo(subject))
    expect(child.type.name).to(equal("Bird"))
    expect(child.selections.elements).to(equal(childSelections))
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
          selectionSet: .mock(
            parentType: Interface_Animal,
            selections: childSelections
          ))),
      ]
    ), parent: nil)

    // then
    expect(subject.children.count).to(equal(1))
    let child = subject.children[0]
    expect(child.parent).to(beIdenticalTo(subject))
    expect(child.type).to(equal(Interface_Animal))
    expect(child.selections.elements).to(equal(childSelections))
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
        .fragmentSpread(.mock(animalDetails)),
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
        .fragmentSpread(.mock(birdDetails)),
      ]
    ), parent: nil)

    // then
    expect(subject.children.count).to(equal(1))
    let child = subject.children[0]
    expect(child.parent).to(beIdenticalTo(subject))
    expect(child.type).to(equal(Object_Bird))
    expect(child.selections.elements).to(equal([.fragmentSpread(.mock(birdDetails))]))
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
        .fragmentSpread(.mock(animalDetails)),
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
        .fragmentSpread(.mock(animalDetails)),
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
        .fragmentSpread(.mock(animalDetails)),
      ]
    ), parent: nil)

    // then
    expect(subject.children.count).to(equal(1))
    let child = subject.children[0]
    expect(child.parent).to(beIdenticalTo(subject))
    expect(child.type).to(equal(Interface_Animal))
    expect(child.selections.elements).to(equal([.fragmentSpread(.mock(animalDetails))]))
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
          selectionSet: .mock(
            parentType: Union_ClassroomPet,
            selections: [
              .inlineFragment(.mock(
                selectionSet: .mock(
                  parentType: Object_Bird,
                  selections: [Field_Species]
                )))]
          ))),
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
    expect(onClassroomPet_onBird.selections.elements).to(equal([Field_Species]))
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

    let expected: OrderedSet = OrderedSet(subject.selections.elements + parent.selections.elements)

    // when
    let actual = subject.mergedSelections

    // then
    expect(actual).to(equal(MergedSelections(expected)))
  }

  // MARK: Merged Selections - Siblings

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
          selectionSet: .mock(
            parentType: GraphQLObjectType.mock("Bird"),
            selections: [.field(.mock("wingspan"))]
          ))),
        .inlineFragment(.mock(
          selectionSet: .mock(
            parentType: GraphQLObjectType.mock("Bird"),
            selections: [.field(.mock("species"))]
          ))),
      ]
    ), parent: nil)

    let sibling1 = parent.children[0]
    let sibling2 = parent.children[1]

    let sibling1Expected = OrderedSet(
      sibling1.selections.elements +
      sibling2.selections.elements
    )

    let sibling2Expected = OrderedSet(
      sibling2.selections.elements +
      sibling1.selections.elements
    )

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
  ///    ... on Cat {
  ///      species
  ///    }
  ///   }
  /// }
  /// Expected:
  /// Bird and Cat selections sets should not merge eachother's selections
  func test__mergedSelections__givenIsObjectType_siblingSelectionSetIsDifferentObjectType_doesNotMergesSiblingSelections() {
    // given
    let parent = SelectionSetScope(selectionSet: .mock(
      parentType: GraphQLInterfaceType.mock("Animal"),
      selections: [
        .inlineFragment(.mock(
          selectionSet: .mock(
            parentType: GraphQLObjectType.mock("Bird"),
            selections: [.field(.mock("wingspan"))]
          ))),
        .inlineFragment(.mock(
          selectionSet: .mock(
            parentType: GraphQLObjectType.mock("Cat"),
            selections: [.field(.mock("species"))]
          ))),
      ]
    ), parent: nil)

    let sibling1 = parent.children[0]
    let sibling2 = parent.children[1]

    let sibling1Expected: OrderedSet = OrderedSet(
      sibling1.selections.elements
    )

    let sibling2Expected: OrderedSet = OrderedSet(
      sibling2.selections.elements
    )

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
          selectionSet: .mock(
            parentType: Bird,
            selections: [.field(.mock("wingspan"))]
          ))),
        .inlineFragment(.mock(
          selectionSet: .mock(
            parentType: Pet,
            selections: [.field(.mock("species"))]
          ))),
      ]
    ), parent: nil)

    let sibling1 = parent.children[0]
    let sibling2 = parent.children[1]

    let sibling1Expected: OrderedSet = OrderedSet(
      sibling1.selections.elements +
      sibling2.selections.elements
    )

    let sibling2Expected: OrderedSet = OrderedSet(
      sibling2.selections.elements
    )

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
          selectionSet: .mock(
            parentType: Bird,
            selections: [.field(.mock("wingspan"))]
          ))),
        .inlineFragment(.mock(
          selectionSet: .mock(
            parentType: Pet,
            selections: [.field(.mock("species"))]
          ))),
      ]
    ), parent: nil)

    let sibling1 = parent.children[0]
    let sibling2 = parent.children[1]

    let sibling1Expected: OrderedSet = OrderedSet(
      sibling1.selections.elements
    )

    let sibling2Expected: OrderedSet = OrderedSet(
      sibling2.selections.elements
    )

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
          selectionSet: .mock(
            parentType: Object_Bird,
            selections: [Field_Wingspan]
          ))),
        .inlineFragment(.mock(
          selectionSet: .mock(
            parentType: Union_ClassroomPet,
            selections: [
              .inlineFragment(.mock(
                selectionSet: .mock(
                  parentType: Object_Bird,
                  selections: [Field_Species]
                )))]
          ))),
      ]
    ), parent: nil)

    let onBird = parent.children[0]
    let onClassroomPet = parent.children[1]
    let onClassroomPet_onBird = onClassroomPet.children[0]

    let onBirdExpected: OrderedSet = OrderedSet([
      Field_Wingspan,
      Field_Species
    ])

    let onClassroomPet_onBirdExpected: OrderedSet = OrderedSet([
      Field_Species,
      Field_Wingspan
    ])

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
          selectionSet: .mock(
            parentType: Object_Bird,
            selections: [Field_Wingspan]
          ))),
        .inlineFragment(.mock(
          selectionSet: .mock(
            parentType: Union_ClassroomPet,
            selections: [
              .inlineFragment(.mock(
                selectionSet: .mock(
                  parentType: Object_Cat,
                  selections: [Field_Species]
                )))]
          ))),
      ]
    ), parent: nil)

    let onBird = parent.children[0]
    let onClassroomPet = parent.children[1]
    let onClassroomPet_onCat = onClassroomPet.children[0]

    let onBirdExpected: OrderedSet = OrderedSet([
      Field_Wingspan
    ])

    let onClassroomPet_onCatExpected: OrderedSet = OrderedSet([
      Field_Species
    ])

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
          selectionSet: .mock(
            parentType: HousePet,
            selections: [.field(.mock("humanName"))]
          ))),
        .inlineFragment(.mock(
          selectionSet: .mock(
            parentType: Pet,
            selections: [.field(.mock("species"))]
          ))),
      ]
    ), parent: nil)

    let sibling1 = parent.children[0]
    let sibling2 = parent.children[1]

    let sibling1Expected: OrderedSet = OrderedSet(
      sibling1.selections.elements +
      sibling2.selections.elements
    )

    let sibling2Expected: OrderedSet = OrderedSet(
      sibling2.selections.elements
    )

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
          selectionSet: .mock(
            parentType: HousePet,
            selections: [.field(.mock("humanName"))]
          ))),
        .inlineFragment(.mock(
          selectionSet: .mock(
            parentType: Pet,
            selections: [.field(.mock("species"))]
          ))),
      ]
    ), parent: nil)

    let sibling1 = parent.children[0]
    let sibling2 = parent.children[1]

    let sibling1Expected: OrderedSet = OrderedSet(
      sibling1.selections.elements
    )

    let sibling2Expected: OrderedSet = OrderedSet(
      sibling2.selections.elements
    )

    // when
    let sibling1Actual = sibling1.mergedSelections
    let sibling2Actual = sibling2.mergedSelections

    // then
    expect(sibling1Actual).to(equal(MergedSelections(sibling1Expected)))
    expect(sibling2Actual).to(equal(MergedSelections(sibling2Expected)))
  }

  // MARK: Merged Selections - Child Fragment

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
  /// AllAnimal.mergedSelections: [species]
  func test__mergedSelections__givenChildIsNamedFragmentOnSameType_mergesFragmentFields() {
    #warning("TODO")
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
    #warning("TODO")
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
  /// AllAnimal.mergedSelections: [species]
  func test__mergedSelections__givenIsObjectType_childIsNamedFragmentOnLessSpecificMatchingType_mergesFragmentFields() {
    #warning("TODO")
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
  /// FlyingAnimal.mergedSelections: [species]
  func test__mergedSelections__givenIsInterfaceType_childIsNamedFragmentOnLessSpecificMatchingType_mergesFragmentFields() {
#warning("TODO")
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
  /// AllAnimal.mergedSelections: [typeCase_AsBird]
  func test__mergedSelections__givenChildIsNamedFragmentOnUnrelatedType_doesNotMergeFragmentFields_hasTypeCaseForNamedFragmentType() {
    #warning("TODO")
  }
}
