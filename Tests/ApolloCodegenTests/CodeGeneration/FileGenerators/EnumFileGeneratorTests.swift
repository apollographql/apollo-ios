import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenTestSupport
import ApolloTestSupport
import SQLite3

class EnumFileGeneratorTests: XCTestCase {
  let graphQLEnum = GraphQLEnumType.mock(name: "MockEnum")

  var subject: EnumFileGenerator!

  override func tearDown() {
    subject = nil
  }

  // MARK: Test Helpers

  private func buildSubject() {
    subject = EnumFileGenerator(graphqlEnum: graphQLEnum)
  }

  // MARK: Property Tests

  func test__properties__shouldReturnTargetType_enum() {
    // given
    buildSubject()

    // then
    expect(self.subject.target).to(equal(FileTarget.enum))
  }

  func test__properties__givenGraphQLEnum_shouldReturnFileName_matchingEnumName() {
    // given
    buildSubject()

    let expected = "\(graphQLEnum.name).swift"

    // then
    expect(self.subject.fileName).to(equal(expected))
  }
}
