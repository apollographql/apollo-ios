import XCTest
import Nimble
import OrderedCollections
@testable import ApolloCodegenLib

class IRFieldCollectorTests: XCTestCase {

  var schemaSDL: String!
  var document: String!
  var ir: IR!
  var subject: IR.FieldCollector!

  var schema: IR.Schema { ir.schema }

  override func setUp() {
    super.setUp()
  }

  override func tearDown() {
    schemaSDL = nil
    document = nil
    ir = nil
    subject = nil
    super.tearDown()
  }

  // MARK: - Helpers

  func buildIR() throws {
    ir = try .mock(schema: schemaSDL, document: document)

    for operation in ir.compilationResult.operations {
      _ = ir.build(operation: operation)
    }

    subject = ir.fieldCollector
  }

  // MARK: - Tests

  func test__collectedFields__givenObject_collectsReferencedFieldsOnly() throws {
    // given
    schemaSDL = """
    type Query {
      dog: Dog!
    }

    type Dog {
      a: String
      b: String
      c: String
    }
    """

    document = """
    query Test {
      dog {
        a
        b
      }
    }
    """

    // when
    try buildIR()

    let Dog = try schema[object: "Dog"].xctUnwrapped()
    let actual = subject.collectedFields(for: Dog)

    let expected: IR.FieldCollector.ReferencedFields = try [
      Dog.fields["a"].xctUnwrapped(),
      Dog.fields["b"].xctUnwrapped(),
    ]

    print(subject.collectedFields)
    expect(actual).to(equal(expected))
  }

  func test__collectedFields__givenInterface_collectsReferencedFieldsOnly() throws {
    // given
    schemaSDL = """
    type Query {
      dog: Dog!
    }

    interface Dog {
      a: String
      b: String
      c: String
    }
    """

    document = """
    query Test {
      dog {
        a
        b
      }
    }
    """

    // when
    try buildIR()

    let Dog = try schema[interface: "Dog"].xctUnwrapped()
    let actual = subject.collectedFields(for: Dog)

    let expected: IR.FieldCollector.ReferencedFields = try [
      Dog.fields["a"].xctUnwrapped(),
      Dog.fields["b"].xctUnwrapped(),
    ]

    print(subject.collectedFields)
    expect(actual).to(equal(expected))
  }

  func test__collectedFields__givenObjectImplementingInterface_collectsFieldsReferencedOnInterface() throws {
    // given
    schemaSDL = """
    type Query {
      animal: Animal!
    }

    interface Animal {
      a: String
    }

    type Dog implements Animal{
      a: String
      b: String
      c: String
    }
    """

    document = """
    query Test {
      animal {
        a
        ... on Dog {
          b
        }
      }
    }
    """

    // when
    try buildIR()

    let Dog = try schema[object: "Dog"].xctUnwrapped()
    let actual = subject.collectedFields(for: Dog)

    let expected: IR.FieldCollector.ReferencedFields = try [
      Dog.fields["b"].xctUnwrapped(),
      Dog.fields["a"].xctUnwrapped(),
    ]

    print(subject.collectedFields)
    expect(actual).to(equal(expected))
  }

}
