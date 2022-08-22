import XCTest
import Nimble
@testable import ApolloCodegenLib

class SchemaCacheKeyResolutionFileGeneratorTests: XCTestCase {
  let irSchema = IR.Schema(name: "MockSchema", referencedTypes: .init([]))

  var subject: SchemaCacheKeyResolutionFileGenerator!

  override func tearDown() {
    subject = nil
  }

  // MARK: Test Helpers

  private func buildSubject() {
    subject = SchemaCacheKeyResolutionFileGenerator(
      schema: irSchema,
      config: ApolloCodegen.ConfigurationContext(config: ApolloCodegenConfiguration.mock())
    )
  }

  // MARK: Property Tests

  func test__properties__shouldReturnTargetType_schema() {
    // given
    buildSubject()

    // then
    expect(self.subject.target).to(equal(.schema))
  }

  func test__properties__givenIrSchema_shouldReturnFileName_plusCacheKeyResolution() {
    // given
    buildSubject()

    let expected = "Schema+CacheKeyResolution.swift"

    // then
    expect(self.subject.fileName).to(equal(expected))
  }

  func test__properties_overwrite__shouldBeFalse() {
    // given
    buildSubject()

    // then
    expect(self.subject.overwrite).to(beTrue())
  }
}
