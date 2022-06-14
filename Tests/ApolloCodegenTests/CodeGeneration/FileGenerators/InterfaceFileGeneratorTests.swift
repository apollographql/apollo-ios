import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloUtils

class InterfaceFileGeneratorTests: XCTestCase {
  let graphqlInterface = GraphQLInterfaceType.mock("MockInterface", fields: [:], interfaces: [])

  var subject: InterfaceFileGenerator!

  override func tearDown() {
    subject = nil
  }

  // MARK: Test Helpers

  private func buildSubject() {
    subject = InterfaceFileGenerator(
      graphqlInterface: graphqlInterface,
      config: ReferenceWrapped(value: ApolloCodegenConfiguration.mock())
    )
  }

  // MARK: Property Tests

  func test__properties__shouldReturnTargetType_interface() {
    // given
    buildSubject()

    // then
    expect(self.subject.target).to(equal(.interface))
  }

  func test__properties__givenGraphQLInterface_shouldReturnFileName_matchingInterfaceName() {
    // given
    buildSubject()

    let expected = "\(graphqlInterface.name).swift"

    // then
    expect(self.subject.fileName).to(equal(expected))
  }

  func test__properties__givenGraphQLInterface_shouldOverwrite() {
    // given
    buildSubject()

    // then
    expect(self.subject.overwrite).to(beTrue())
  }
}
