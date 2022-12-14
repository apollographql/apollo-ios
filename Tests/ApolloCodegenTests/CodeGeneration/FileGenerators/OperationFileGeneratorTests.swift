import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenInternalTestHelpers

class OperationFileGeneratorTests: XCTestCase {
  var irOperation: IR.Operation!
  var subject: OperationFileGenerator!
  var operationDocument: String!

  override func setUp() {
    super.setUp()

    operationDocument = """
    query AllAnimals {
      animals {
        species
      }
    }
    """
  }

  override func tearDown() {
    subject = nil
    irOperation = nil
    operationDocument = nil
    super.tearDown()
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

    let ir = try IR.mock(schema: schemaSDL, document: operationDocument)
    irOperation = ir.build(operation: ir.compilationResult.operations[0])

    let config = ApolloCodegen.ConfigurationContext(config: ApolloCodegenConfiguration.mock())
    
    subject = OperationFileGenerator(irOperation: irOperation, config: config)
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

    let expected = irOperation.definition.nameWithSuffix

    // then
    expect(self.subject.fileName).to(equal(expected))
  }

  func test__properties__givenIrOperation_shouldOverwrite() throws {
    // given
    try buildSubject()

    // then
    expect(self.subject.overwrite).to(beTrue())
  }

  func test__template__givenNotLocalCacheMutationOperation_shouldBeOperationTemplate() throws {
    // given
    operationDocument = """
    query AllAnimals {
      animals {
        species
      }
    }
    """

    // when
    try buildSubject()

    // then
    expect(self.subject.template).to(beAKindOf(OperationDefinitionTemplate.self))
  }

  func test__template__givenLocalCacheMutationOperation_shouldBeLocalCacheMutationOperationTemplate() throws {
    // given
    operationDocument = """
    query AllAnimals @apollo_client_ios_localCacheMutation {
      animals {
        species
      }
    }
    """

    // when
    try buildSubject()

    // then
    expect(self.subject.template).to(beAKindOf(LocalCacheMutationDefinitionTemplate.self))
  }
}
