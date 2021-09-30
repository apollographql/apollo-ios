import XCTest
import Nimble
import OrderedCollections
@testable import ApolloCodegenLib
import ApolloCodegenTestSupport

class SelectionSetScopeTests: XCTestCase {

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
}
