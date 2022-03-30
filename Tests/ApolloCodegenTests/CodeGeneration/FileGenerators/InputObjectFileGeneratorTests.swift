import XCTest
import Nimble
@testable import ApolloCodegenLib

class InputObjectFileGeneratorTests: XCTestCase {
  let graphqlInputObject = GraphQLInputObjectType.mock("MockInputObject")

  var subject: InputObjectFileGenerator!

  override func tearDown() {
    subject = nil
  }

  // MARK: Test Helpers

  private func buildSubject() {
    subject = InputObjectFileGenerator(graphqlInputObject: graphqlInputObject)
  }

  // MARK: Property Tests

  func test__properties__shouldReturnTargetType_inputObject() {
    // given
    buildSubject()

    // then
    expect(self.subject.target).to(equal(.inputObject))
  }

  func test__properties__givenGraphQLEnum_shouldReturnFileName_matchingInputObjectName() {
    // given
    buildSubject()

    let expected = "\(graphqlInputObject.name).swift"

    // then
    expect(self.subject.fileName).to(equal(expected))
  }
}
