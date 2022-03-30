import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenTestSupport

class FragmentFileGeneratorTests: XCTestCase {
  var namedFragment: IR.NamedFragment!
  var subject: FragmentFileGenerator!

  override func tearDown() {
    subject = nil
    namedFragment = nil
  }

  // MARK: Test Helpers

  private func buildSubject() throws {
    let schemaSDL = """
    type Animal {
      species: String
    }

    type Query {
      animals: [Animal]
    }
    """

    let operationDocument = """
    query AllAnimals {
      animals {
        ...AnimalDetails
      }
    }

    fragment AnimalDetails on Animal {
      species
    }
    """

    let ir = try IR.mock(schema: schemaSDL, document: operationDocument)
    namedFragment = ir.build(fragment: ir.compilationResult.fragments[0])
    subject = FragmentFileGenerator(namedFragment: namedFragment, schema: ir.schema)
  }

  // MARK: Property Tests

  func test__properties__shouldReturnTargetType_fragment() throws {
    // given
    try buildSubject()

    let expected: FileTarget = .fragment(namedFragment.definition)

    // then
    expect(self.subject.target).to(equal(expected))
  }

  func test__properties__givenGraphQLEnum_shouldReturnFileName_matchingFragmentDefinitionName() throws {
    // given
    try buildSubject()

    let expected = "\(namedFragment.definition.name).swift"

    // then
    expect(self.subject.fileName).to(equal(expected))
  }
}
