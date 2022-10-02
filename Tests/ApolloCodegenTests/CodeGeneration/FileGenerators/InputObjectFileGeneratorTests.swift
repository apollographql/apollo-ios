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
    let schema = IR.Schema(name: "TestSchema", referencedTypes: .init([]))    
    subject = InputObjectFileGenerator(
      graphqlInputObject: graphqlInputObject,
      schema: schema,
      config: ApolloCodegen.ConfigurationContext(config: ApolloCodegenConfiguration.mock())
    )
  }

  // MARK: Property Tests

  func test__properties__shouldReturnTargetType_inputObject() {
    // given
    buildSubject()

    // then
    expect(self.subject.target).to(equal(.inputObject))
  }

  func test__properties__givenGraphQLInputObject_shouldReturnFileName_matchingInputObjectName() {
    // given
    buildSubject()

    let expected = graphqlInputObject.name

    // then
    expect(self.subject.fileName).to(equal(expected))
  }

  func test__properties__givenGraphQLInputObject_shouldOverwrite() {
    // given
    buildSubject()

    // then
    expect(self.subject.overwrite).to(beTrue())
  }
}
