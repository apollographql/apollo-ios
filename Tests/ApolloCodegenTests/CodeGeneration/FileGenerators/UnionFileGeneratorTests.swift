import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloUtils

class UnionFileGeneratorTests: XCTestCase {
  let graphqlUnion = GraphQLUnionType.mock("MockUnion", types: [])

  var subject: UnionFileGenerator!

  override func tearDown() {
    subject = nil
  }

  // MARK: Test Helpers

  private func buildSubject() {
    subject = UnionFileGenerator(
      graphqlUnion: graphqlUnion,
      schemaName: "MockSchema",
      config: ReferenceWrapped(value: ApolloCodegenConfiguration.mock())
    )
  }

  // MARK: Property Tests

  func test__properties__shouldReturnTargetType_union() {
    // given
    buildSubject()

    // then
    expect(self.subject.target).to(equal(.union))
  }

  func test__properties__givenGraphQLUnion_shouldReturnFileName_matchingUnionName() {
    // given
    buildSubject()

    let expected = "\(graphqlUnion.name).swift"

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
