import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenInternalTestHelpers

class FragmentFileGeneratorTests: XCTestCase {
  var irFragment: IR.NamedFragment!
  var subject: FragmentFileGenerator!

  override func tearDown() {
    subject = nil
    irFragment = nil
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
        ...animalDetails
      }
    }

    fragment animalDetails on Animal {
      species
    }
    """

    let ir = try IR.mock(schema: schemaSDL, document: operationDocument)
    irFragment = ir.build(fragment: ir.compilationResult.fragments[0])
    
    subject = FragmentFileGenerator(irFragment: irFragment, schema: ir.schema)
  }

  // MARK: Property Tests

  func test__properties__shouldReturnTargetType_fragment() throws {
    // given
    try buildSubject()

    let expected: FileTarget = .fragment(irFragment.definition)

    // then
    expect(self.subject.target).to(equal(expected))
  }

  func test__properties__givenGraphQLFragment_shouldReturnFileName_matchingFragmentDefinitionName() throws {
    // given
    try buildSubject()

    let expected = "\(irFragment.definition.name).swift"

    // then
    expect(self.subject.fileName).to(equal(expected))
  }

  func test__properties__givenGraphQLFragment_shouldOverwrite() throws {
    // given
    try buildSubject()

    // then
    expect(self.subject.overwrite).to(beTrue())
  }
}
