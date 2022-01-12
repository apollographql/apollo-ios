import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenTestSupport

class InterfaceFileGeneratorTests: XCTestCase {
  override func tearDown() {
    CodegenTestHelper.deleteExistingOutputFolder()

    super.tearDown()
  }

  func test_generate_givenSchemaType_shouldOutputToPath() throws {
    // given
    let schema = """
    interface NamedEntity {
      name: String
    }

    type Contact {
      entity: NamedEntity
      phoneNumber: String
      address: String
    }

    type Query {
      contacts: [Contact!]!
    }
    """

    let operation = """
    query AllContacts {
      contacts {
        entity {
          name
        }
      }
    }
    """

    let ir = try IR.mock(schema: schema, document: operation)
    let interfaceType = try ir.schema[interface: "NamedEntity"].xctUnwrapped()

    let rootURL = URL(fileURLWithPath: CodegenTestHelper.outputFolderURL().path)
    let fileURL = rootURL.appendingPathComponent("NamedEntity.swift")

    let mockFileManager = MockFileManager(strict: false)

    mockFileManager.mock(closure: .createFile({ path, data, attributes in
      expect(path).to(equal(fileURL.path))
      expect(String(data: try! data.xctUnwrapped(), encoding: .utf8))
        .to(equal("public class NamedEntity {}"))

      return true
    }))

    // then
    try InterfaceFileGenerator(
      interfaceType: interfaceType,
      directoryPath: rootURL.path
    ).generateFile(fileManager: mockFileManager)

    expect(mockFileManager.allClosuresCalled).to(beTrue())
  }
}
