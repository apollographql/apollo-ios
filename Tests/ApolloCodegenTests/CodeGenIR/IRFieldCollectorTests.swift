import XCTest
import Nimble
import OrderedCollections
@testable import ApolloCodegenLib

class IRFieldCollectorTests: XCTestCase {

  typealias ReferencedFields = [(String, GraphQLType)]

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

    let expected: ReferencedFields = [
      ("a", .string()),
      ("b", .string())
    ]

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

    let expected: ReferencedFields = [
      ("a", .string()),
      ("b", .string())
    ]

    expect(actual).to(equal(expected))
  }

  func test__collectedFields__givenFieldsInNonAlphabeticalOrder_retrurnsReferencedFieldsSortedAlphabetically() throws {
    // given
    schemaSDL = """
    type Query {
      dog: Dog!
    }

    type Dog {
      a: String
      b: String
    }
    """

    document = """
    query Test {
      dog {
        b
        a
      }
    }
    """

    // when
    try buildIR()

    let Dog = try schema[object: "Dog"].xctUnwrapped()
    let actual = subject.collectedFields(for: Dog)

    let expected: ReferencedFields = [
      ("a", .string()),
      ("b", .string())
    ]

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

    let expected: ReferencedFields = [
      ("a", .string()),
      ("b", .string())
    ]

    expect(actual).to(equal(expected))
  }

  func test__collectedFields__givenFieldsFromFragment_collectsFieldsReferencedInFragment() throws {
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
        ...FragmentB
        a
      }
    }

    fragment FragmentB on Dog {
      b
    }
    """

    // when
    try buildIR()

    let Dog = try schema[object: "Dog"].xctUnwrapped()
    let actual = subject.collectedFields(for: Dog)

    let expected: ReferencedFields = [
      ("a", .string()),
      ("b", .string())
    ]

    expect(actual).to(equal(expected))
  }

  func test__collectedFields__givenFieldsFromFragmentOnInterface_collectsFieldsReferencedInFragment() throws {
    // given
    schemaSDL = """
    type Query {
      animal: Animal!
    }

    interface Animal {
      a: String
    }

    type Dog implements Animal {
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
          ...FragmentB
        }
      }
    }

    fragment FragmentB on Dog {
      b
    }
    """

    // when
    try buildIR()

    let Dog = try schema[object: "Dog"].xctUnwrapped()
    let actual = subject.collectedFields(for: Dog)

    let expected: ReferencedFields = [
      ("a", .string()),
      ("b", .string())
    ]

    expect(actual).to(equal(expected))
  }

  func test__collectedFields__givenFieldsFromQueryOnImplementedInterface_collectsFieldsReferencedInQueryOnInterface() throws {
    // given
    schemaSDL = """
    type Query {
      animal: Animal!
      dog: Dog!
    }

    interface Animal {
      a: String
    }

    type Dog implements Animal {
      a: String
      b: String
      c: String
    }
    """

    document = """
    query Test1 {
      animal {
        a
      }
    }

    query Test2 {
      dog {
        b
      }
    }
    """

    // when
    try buildIR()

    let Dog = try schema[object: "Dog"].xctUnwrapped()
    let actual = subject.collectedFields(for: Dog)

    let expected: ReferencedFields = [
      ("a", .string()),
      ("b", .string())
    ]

    expect(actual).to(equal(expected))
  }

  func test__collectedFields__givenAliasedField_collectsFields() throws {
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
    query Test1 {
      dog {
        aliasedA: a
      }
    }
    """

    // when
    try buildIR()

    let Dog = try schema[object: "Dog"].xctUnwrapped()
    let actual = subject.collectedFields(for: Dog)

    let expected: ReferencedFields = [
      ("aliasedA", .string()),
    ]

    expect(actual).to(equal(expected))
  }

  func test__collectedFields__givenFieldWithArguments_collectsFields() throws {
    // given
    schemaSDL = """
    type Query {
      dog: Dog!
    }

    type Dog {
      a(arg1: String): String
    }
    """

    document = """
    query Test1 {
      dog {
        a(arg1: "test")
      }
    }
    """

    // when
    try buildIR()

    let Dog = try schema[object: "Dog"].xctUnwrapped()
    let actual = subject.collectedFields(for: Dog)

    let expected: ReferencedFields = [
      ("a", .string()),
    ]

    expect(actual).to(equal(expected))
  }

  func test__collectedFields__givenAliasedFieldsWithArguments_collectsFields() throws {
    // given
    schemaSDL = """
    type Query {
      dog: Dog!
    }

    type Dog {
      a(arg1: String): String
    }
    """

    document = """
    query Test1 {
      dog {
        field1: a(arg1: "one")
        field2: a(arg1: "two")
      }
    }
    """

    // when
    try buildIR()

    let Dog = try schema[object: "Dog"].xctUnwrapped()
    let actual = subject.collectedFields(for: Dog)

    let expected: ReferencedFields = [
      ("field1", .string()),
      ("field2", .string()),
    ]

    expect(actual).to(equal(expected))
  }

  /// MARK: - Custom Matchers
  func equal(
    _ expected: ReferencedFields
  ) -> Predicate<ReferencedFields> {
    return Predicate.define { actual in
      let message: ExpectationMessage = .expectedActualValueTo("have fields equal to \(expected)")

      guard let actual = try actual.evaluate(),
            expected.count == actual.count else {
        return PredicateResult(status: .fail, message: message.appended(details: "Fields Did Not Match!"))
      }

      for (index, field) in zip(expected, actual).enumerated() {
        guard field.0.0 == field.1.0, field.0.1 == field.1.1 else {
          return PredicateResult(
            status: .fail,
            message: message.appended(
              details: "Expected fields[\(index)] to equal \(field.0), got \(field.1)."
            )
          )
        }
      }

      return PredicateResult(status: .matches, message: message)
    }
  }
}

