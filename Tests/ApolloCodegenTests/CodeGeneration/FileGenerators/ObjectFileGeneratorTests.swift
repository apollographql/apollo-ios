import XCTest
import Nimble
@testable import ApolloCodegenLib

class ObjectFileGeneratorTests: XCTestCase {
  let graphQLObject = GraphQLObjectType.mock("MockObject", fields: [:], interfaces: [])

  var subject: ObjectFileGenerator!

  override func tearDown() {
    subject = nil
  }

  // MARK: Test Helpers

  private func buildSubject() {
    subject = ObjectFileGenerator(graphqlObject: graphQLObject)
  }

  // MARK: Property Tests

  func test__properties__shouldReturnTargetType_object() {
    // given
    buildSubject()

    // then
    expect(self.subject.target).to(equal(.object))
  }

  func test__properties__givenGraphQLEnum_shouldReturnFileName_matchingEnumName() {
    // given
    buildSubject()

    let expected = "\(graphQLObject.name).swift"

    // then
    expect(self.subject.fileName).to(equal(expected))
  }
}
