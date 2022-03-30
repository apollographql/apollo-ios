import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenTestSupport

class SchemaFileGeneratorTests: XCTestCase {
  let irSchema = IR.Schema(name: "MockSchema", referencedTypes: .init([]))

  var subject: SchemaFileGenerator!

  override func tearDown() {
    subject = nil
  }

  // MARK: Test Helpers

  private func buildSubject() {
    subject = SchemaFileGenerator(schema: irSchema)
  }

  // MARK: Property Tests

  func test__properties__shouldReturnTargetType_schema() {
    // given
    buildSubject()

    // then
    expect(self.subject.target).to(equal(.schema))
  }

  func test__properties__givenGraphQLEnum_shouldReturnFileName_matchingName() {
    // given
    buildSubject()

    let expected = "Schema.swift"

    // then
    expect(self.subject.fileName).to(equal(expected))
  }
}
