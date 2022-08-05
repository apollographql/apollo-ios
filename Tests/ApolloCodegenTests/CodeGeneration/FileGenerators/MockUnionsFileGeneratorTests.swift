import XCTest
import Nimble
import OrderedCollections
@testable import ApolloCodegenLib

class MockUnionsFileGeneratorTests: XCTestCase {
  static let mockUnion = GraphQLUnionType.mock("MockUnion", types: [])

  var subject: MockUnionsFileGenerator!

  override func tearDown() {
    subject = nil
  }

  // MARK: Test Helpers

  private func buildSubject(unions: OrderedSet<GraphQLUnionType> = [mockUnion]) {
    let compilationResult = CompilationResult.mock()
    compilationResult.referencedTypes.append(contentsOf: unions.elements)

    let ir = IR.mock(compilationResult: compilationResult)

    subject = MockUnionsFileGenerator(
      ir: ir,
      config: ApolloCodegen.ConfigurationContext(config: .mock(.other))
    )
  }

  // MARK: Property Tests

  func test__init_givenNoUnions__shouldBeNil() {
    // given
    buildSubject(unions: [])

    // then
    expect(self.subject).to(beNil())
  }

  func test__properties__shouldReturnTargetType_testMock() {
    // given
    buildSubject()

    // then
    expect(self.subject.target).to(equal(.testMock))
  }

  func test__properties__shouldReturnFileName() {
    // given
    buildSubject()

    let expected = "MockObject+Unions.swift"

    // then
    expect(self.subject.fileName).to(equal(expected))
  }

  func test__properties__overwrite_shouldBeTrue() {
    // given
    buildSubject()

    // then
    expect(self.subject.overwrite).to(beTrue())
  }
}
