import XCTest
import Nimble
@testable import ApolloCodegenLib

class ObjectFileGeneratorTests: XCTestCase {
  var subject: ObjectFileGenerator!

  override func tearDown() {
    subject = nil
  }

  // MARK: Test Helpers

  private func buildSubject(object: GraphQLObjectType = .mock("MockObject", fields: [:], interfaces: [])) {
    subject = ObjectFileGenerator(graphqlObject: object, ir: .mock(compilationResult: .mock()))
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

    let expected = "MockObject.swift"

    // then
    expect(self.subject.fileName).to(equal(expected))
  }

  func test__properties__givenGraphQLObjectWithLowercaseName_shouldReturnFileName_matchingObjectNameUppercased() {
    // given
    buildSubject(object: .mock("mockObject", fields: [:], interfaces: []))

    let expected = "MockObject.swift"

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
