import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenTestSupport

class OperationFileGeneratorTests: XCTestCase {
  override func tearDown() {
    CodegenTestHelper.deleteExistingOutputFolder()

    super.tearDown()
  }

  func test_generate_givenSchemaType_shouldWriteToCorrectFilePath() throws {
    // given
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
    let irOperation = ir.build(operation: ir.compilationResult.operations[0])
    let config = ApolloCodegenConfiguration.mock()

    let fileManager = MockFileManager(strict: false)
    let rootURL = URL(fileURLWithPath: CodegenTestHelper.outputFolderURL().path)
    let fileURL = rootURL.appendingPathComponent("AllAnimals.swift")

    fileManager.mock(closure: .createFile({ path, data, attributes in
      expect(path).to(equal(fileURL.path))

      return true
    }))

    // then
    try OperationFileGenerator.generate(
      irOperation,
      schema: ir.schema,
      config: config,
      directoryPath: rootURL.path,
      fileManager: fileManager
    )

    expect(fileManager.allClosuresCalled).to(beTrue())
  }
}
