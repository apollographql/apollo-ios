import XCTest
import Nimble
@testable import ApolloCodegenLib

class CustomScalarFileGeneratorTests: XCTestCase {
  let graphqlScalar = GraphQLScalarType.mock(name: "MockCustomScalar")

  var subject: CustomScalarFileGenerator!

  override func tearDown() {
    subject = nil
  }

  // MARK: Test Helpers

  private func buildSubject() {
    subject = CustomScalarFileGenerator(graphqlScalar: graphqlScalar)
  }

  // MARK: Property Tests

  func test__properties__shouldReturnTargetType_customScalar() {
    // given
    buildSubject()

    // then
    expect(self.subject.target).to(equal(.customScalar))
  }

  func test__properties__givenGraphQLScalar_shouldReturnFileName_matchingScalarNameFirstUppercased() {
    // given
    buildSubject()

    let expected = "\(graphqlScalar.name.firstUppercased).swift"

    // then
    expect(self.subject.fileName).to(equal(expected))
  }
}
