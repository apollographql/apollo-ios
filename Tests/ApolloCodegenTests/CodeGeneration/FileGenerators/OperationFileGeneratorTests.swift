import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenTestSupport
import ApolloUtils

class OperationFileGeneratorTests: XCTestCase {
  var irOperation: IR.Operation!
  var subject: OperationFileGenerator!

  override func tearDown() {
    subject = nil
    irOperation = nil
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
        species
      }
    }
    """

    let ir = try IR.mock(schema: schemaSDL, document: operationDocument)
    irOperation = ir.build(operation: ir.compilationResult.operations[0])

    let config = ReferenceWrapped(value: ApolloCodegenConfiguration.mock())
    
    subject = OperationFileGenerator(irOperation: irOperation, schema: ir.schema, config: config)
  }

  // MARK: Property Tests

  func test__properties__shouldReturnTargetType_operation() throws {
    // given
    try buildSubject()

    let expected: FileTarget = .operation(irOperation.definition)

    // then
    expect(self.subject.target).to(equal(expected))
  }

  func test__properties__givenIrOperation_shouldReturnFileName_matchingOperationDefinitionName() throws {
    // given
    try buildSubject()

    let expected = "\(irOperation.definition.nameWithSuffix).swift"

    // then
    expect(self.subject.fileName).to(equal(expected))
  }

  func test__properties__givenIrOperation_shouldOverwrite() throws {
    // given
    try buildSubject()

    // then
    expect(self.subject.overwrite).to(beTrue())
  }
}
