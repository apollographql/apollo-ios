import XCTest
import Nimble
@testable import ApolloCodegenLib

class EnumFileGeneratorTests: XCTestCase {
  let graphqlEnum = GraphQLEnumType.mock(name: "MockEnum")

  var subject: EnumFileGenerator!

  override func tearDown() {
    subject = nil
  }

  // MARK: Test Helpers

  private func buildSubject() {
    subject = EnumFileGenerator(graphqlEnum: graphqlEnum)
  }

  // MARK: Property Tests

  func test__properties__shouldReturnTargetType_enum() {
    // given
    buildSubject()

    // then
    expect(self.subject.target).to(equal(.enum))
  }

  func test__properties__givenGraphQLEnum_shouldReturnFileName_matchingEnumNameFirstUppercased() {
    // given
    buildSubject()

    let expected = "\(graphqlEnum.name.firstUppercased).swift"

    // then
    expect(self.subject.fileName).to(equal(expected))
  }
}
