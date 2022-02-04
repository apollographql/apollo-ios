import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenTestSupport

class FragmentFileGeneratorTests: XCTestCase {
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
        ...AnimalDetails
      }
    }

    fragment AnimalDetails on Animal {
      species
    }
    """

    let ir = try IR.mock(schema: schemaSDL, document: operationDocument)
    let irFragment = ir.build(fragment: ir.compilationResult.fragments[0])
    let config = ApolloCodegenConfiguration.mock()

    let fileManager = MockFileManager(strict: false)
    let rootURL = URL(fileURLWithPath: CodegenTestHelper.outputFolderURL().path)
    let fileURL = rootURL.appendingPathComponent("AnimalDetails.swift")

    fileManager.mock(closure: .createFile({ path, data, attributes in
      expect(path).to(equal(fileURL.path))

      return true
    }))

    // then
    try FragmentFileGenerator.generate(
      irFragment,
      schema: ir.schema,
      config: config.output,
      directoryPath: rootURL.path,
      fileManager: fileManager
    )

    expect(fileManager.allClosuresCalled).to(beTrue())
  }
}
