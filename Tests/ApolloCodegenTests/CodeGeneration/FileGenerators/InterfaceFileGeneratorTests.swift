import XCTest
import Nimble
@testable import ApolloCodegenLib

class InterfaceFileGeneratorTests: XCTestCase {
  var subject: InterfaceFileGenerator!

  override func tearDown() {
    subject = nil
  }

  // MARK: Test Helpers

  private func buildSubject(interface: GraphQLInterfaceType = .mock("MockInterface", fields: [:], interfaces: [])) {
    subject = InterfaceFileGenerator(graphqlInterface: graphqlInterface)
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

    let expected = "MockInterface.swift"

    // then
    expect(self.subject.fileName).to(equal(expected))
  }

  func test__properties__givenGraphQLInterfaceWithLowercaseName_shouldReturnFileName_matchingObjectNameUppercased() {
    // given
    buildSubject(interface: .mock("mockInterface", fields: [:], interfaces: []))

    let expected = "MockInterface.swift"

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
