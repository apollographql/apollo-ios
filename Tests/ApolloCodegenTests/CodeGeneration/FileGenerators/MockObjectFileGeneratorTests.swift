import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloUtils

class MockObjectFileGeneratorTests: XCTestCase {
  let graphqlObject = GraphQLObjectType.mock("MockObject", fields: [:], interfaces: [])

  var subject: MockObjectFileGenerator!

  override func tearDown() {
    subject = nil
  }

  // MARK: Test Helpers

  private func buildSubject() {
    subject = MockObjectFileGenerator(
      graphqlObject: graphqlObject,
      ir: .mock(compilationResult: .mock()),
      config: ReferenceWrapped(value: .mock(.other))
    )
  }

  // MARK: Property Tests

  func test__properties__shouldReturnTargetType_testMock() {
    // given
    buildSubject()

    // then
    expect(self.subject.target).to(equal(.testMock))
  }

  func test__properties__givenGraphQLObject_shouldReturnFileName_matchingObjectName() {
    // given
    buildSubject()

    let expected = "\(graphqlObject.name)+Mock.swift"

    // then
    expect(self.subject.fileName).to(equal(expected))
  }

  func test__properties__givenGraphQLObject_shouldOverwrite() {
    // given
    buildSubject()

    // then
    expect(self.subject.overwrite).to(beTrue())
  }
}
