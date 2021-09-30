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
    let childSelections: [CompilationResult.Selection] = [.field(.mock(name: "wingspan"))]

    let subject = SelectionSetScope(selectionSet: .mock(
      parentType: GraphQLInterfaceType.mock(name: "Animal"),
      selections: [
        .inlineFragment(.mock(
          selectionSet: .mock(
            parentType: GraphQLObjectType.mock(name: "Bird"),
            selections: childSelections
          ))),
      ]
    ), parent: nil)

    // then
    expect(subject.children?.count).to(equal(1))
    let child = subject.children?[0]
    expect(child?.parent).to(beIdenticalTo(subject))
    expect(child?.type.name).to(equal("Bird"))
    expect(child?.selections?.elements).to(equal(childSelections))
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
    let childSelections: [CompilationResult.Selection] = [.field(.mock(name: "species"))]

    let subject = SelectionSetScope(selectionSet: .mock(
      parentType: GraphQLInterfaceType.mock(name: "Animal"),
      selections: [
        .inlineFragment(.mock(
          selectionSet: .mock(
            parentType: GraphQLInterfaceType.mock(name: "Animal"),
            selections: childSelections
          ))),
      ]
    ), parent: nil)

    // then
    expect(subject.children?.count).to(equal(1))
    let child = subject.children?[0]
    expect(child?.parent).to(beIdenticalTo(subject))
    expect(child?.type.name).to(equal("Animal"))
    expect(child?.selections?.elements).to(equal(childSelections))
  }

  // MARK: - Merged Selections

  func test__mergedSelections__givenSelectionSetWithNoSelectionsAndNoParent_returnsNil() {
    // given
    let selectionSet = CompilationResult.SelectionSet.mock()
    
    // when
    let actual = SelectionSetScope(selectionSet: selectionSet, parent: nil)
      .mergedSelections

    // then
    expect(actual).to(beNil())
  }

  func test__mergedSelections__givenSelectionSetWithSelections_returnsSelections() {
    // given
    let expected: OrderedSet = [CompilationResult.Selection.field(.mock())]

    let selectionSet = CompilationResult.SelectionSet.mock()
    selectionSet.selections = expected.elements

    // when
    let actual = SelectionSetScope(selectionSet: selectionSet, parent: nil)
      .mergedSelections

    // then
    expect(actual).to(equal(expected))
  }

  func test__mergedSelections__givenSelectionSetWithSelectionsAndParentSelections_returnsSelfAndParentSelections() {
    // given
    let parent = SelectionSetScope(selectionSet: .mock(
      selections: [.field(.mock(name: "A"))]
    ), parent: nil)

    let subject = SelectionSetScope(selectionSet: .mock(
      selections: [.field(.mock(name: "B"))]
    ), parent: parent)

    let expected: OrderedSet = OrderedSet(subject.selections!.elements + parent.selections!.elements)

    // when
    let actual = subject.mergedSelections

    // then
    expect(actual).to(equal(expected))
  }

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
      parentType: GraphQLInterfaceType.mock(name: "Animal"),
      selections: [
        .inlineFragment(.mock(
          selectionSet: .mock(
            parentType: GraphQLObjectType.mock(name: "Bird"),
            selections: [.field(.mock(name: "wingspan"))]
          ))),
        .inlineFragment(.mock(
          selectionSet: .mock(
            parentType: GraphQLObjectType.mock(name: "Bird"),
            selections: [.field(.mock(name: "species"))]
          ))),
      ]
    ), parent: nil)

    let sibling1 = parent.children![0]
    let sibling2 = parent.children![1]

    let sibling1Expected: OrderedSet = OrderedSet(
      sibling1.selections!.elements +
      sibling2.selections!.elements
    )

    let sibling2Expected: OrderedSet = OrderedSet(
      sibling2.selections!.elements +
      sibling1.selections!.elements
    )

    // when
    let sibling1Actual = sibling1.mergedSelections
    let sibling2Actual = sibling2.mergedSelections

    // then
    expect(sibling1Actual).to(equal(sibling1Expected))
    expect(sibling2Actual).to(equal(sibling2Expected))
  }
}
