import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenTestSupport

class InputObjectFileGeneratorTests: XCTestCase {
  override func tearDown() {
    CodegenTestHelper.deleteExistingOutputFolder()

    super.tearDown()
  }

  func test_generate_givenSchemaType_shouldOutputToPath() throws {
    // given
    let schema = """
    input MessageInput {
      author: String
      content: String
    }

    type Message {
      author: String
      content: String
    }

    type Query {
      messages: [Message!]!
    }

    type Mutation {
      createMessage(input: MessageInput): Message
    }
    """

    let operation = """
    mutation CreateMessage($input: MessageInput) {
      createMessage(input: $input) {
        author
        content
      }
    }
    """

    let ir = try IR.mock(schema: schema, document: operation)
    let inputObjectType = try ir.schema[inputObject: "MessageInput"].xctUnwrapped()

    let rootURL = URL(fileURLWithPath: CodegenTestHelper.outputFolderURL().path)
    let fileURL = rootURL.appendingPathComponent("MessageInput.swift")

    let mockFileManager = MockFileManager(strict: false)

    mockFileManager.mock(closure: .createFile({ path, data, attributes in
      expect(path).to(equal(fileURL.path))
      expect(String(data: try! data.xctUnwrapped(), encoding: .utf8))
        .to(equal("public struct MessageInput {}"))

      return true
    }))

    // then
    try InputObjectFileGenerator(
      inputObjectType: inputObjectType,
      directoryPath: rootURL.path
    ).generateFile(fileManager: mockFileManager)

    expect(mockFileManager.allClosuresCalled).to(beTrue())
  }
}
