import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloUtils

class ObjectFileGeneratorTests: XCTestCase {
  let graphqlObject = GraphQLObjectType.mock("MockObject", fields: [:], interfaces: [])

  var subject: ObjectFileGenerator!

  override func tearDown() {
    subject = nil
  }

  // MARK: Test Helpers

  private func buildSubject() {
    subject = ObjectFileGenerator(
      graphqlObject: graphqlObject,
      config: ApolloCodegen.ConfigurationContext(config: ApolloCodegenConfiguration.mock())
    )
  }

  // MARK: Property Tests

  func test__properties__shouldReturnTargetType_object() {
    // given
    buildSubject()

    // then
    expect(self.subject.target).to(equal(.object))
  }

  func test__properties__givenGraphQLObject_shouldReturnFileName_matchingObjectName() {
    // given
    buildSubject()

    let expected = "\(graphqlObject.name).swift"

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
