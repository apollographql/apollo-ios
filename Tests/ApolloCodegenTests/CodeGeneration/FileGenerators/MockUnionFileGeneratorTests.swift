import XCTest
import Nimble
@testable import ApolloCodegenLib

class MockUnionFileGeneratorTests: XCTestCase {
  let graphqlUnion = GraphQLUnionType.mock("MockUnion", types: [])

  var subject: MockUnionFileGenerator!

  override func tearDown() {
    subject = nil
  }

  // MARK: Test Helpers

  private func buildSubject() {
    subject = MockUnionFileGenerator(
      graphqlUnion: graphqlUnion,
      ir: .mock(compilationResult: .mock()),
      config: ApolloCodegen.ConfigurationContext(config: .mock(.other))
    )
  }

  // MARK: Property Tests

  func test__properties__shouldReturnTargetType_testMock() {
    // given
    buildSubject()

    // then
    expect(self.subject.target).to(equal(.testMock))
  }

  func test__properties__givenGraphQLUnion_shouldReturnFileName_matchingUnionName() {
    // given
    buildSubject()

    let expected = "\(graphqlUnion.name)+Mock.swift"

    // then
    expect(self.subject.fileName).to(equal(expected))
  }

  func test__properties__givenGraphQLUnion_shouldOverwrite() {
    // given
    buildSubject()

    // then
    expect(self.subject.overwrite).to(beTrue())
  }
}
