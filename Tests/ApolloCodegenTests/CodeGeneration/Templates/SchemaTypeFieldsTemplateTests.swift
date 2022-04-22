import XCTest
import Nimble
@testable import ApolloCodegenLib
import ApolloCodegenTestSupport

class SchemaTypeFieldsTemplateTests: XCTestCase {

  var schemaSDL: String!
  var document: String!
  var ir: IR!
  var subject: SchemaTypeFieldsTemplate!

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

  func buildSubject() throws {
    ir = try .mock(schema: schemaSDL, document: document)

    for operation in ir.compilationResult.operations {
      _ = ir.build(operation: operation)
    }

    subject = SchemaTypeFieldsTemplate(ir: ir)
  }


  // MARK: Field Accessor Tests

  #warning("TODO: fields with arguments")

  func test__render__givenFieldsOnObject_rendersReferencedFields() throws {
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

    let expected =
    """
    @Field("a") public var a: String?
    @Field("b") public var b: String?
    """

    // when
    try buildSubject()

    let Dog = try schema[object: "Dog"].xctUnwrapped()

    let actual = subject.render(type: Dog).description

    // then
    expect(actual).to(equalLineByLine(expected))
  }

  func test__render__givenFieldsInNonAlphabeticalOrder_rendersReferencedFieldsSortedAlphabetically() throws {
    // given
    schemaSDL = """
    type Query {
      dog: Dog!
    }

    type Dog {
      b: String
      a: String
      c: String
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

    let expected =
    """
    @Field("a") public var a: String?
    @Field("b") public var b: String?
    """

    // when
    try buildSubject()

    let Dog = try schema[object: "Dog"].xctUnwrapped()

    let actual = subject.render(type: Dog).description

    // then
    expect(actual).to(equalLineByLine(expected))
  }

  func test__render__givenFieldOnObject_nonNull_rendersFieldAsOptional() throws {
    // given
    schemaSDL = """
    type Query {
      dog: Dog!
    }

    type Dog {
      a: String!
    }
    """

    document = """
    query Test {
      dog {
        a
      }
    }
    """

    let expected =
    """
    @Field("a") public var a: String?
    """

    // when
    try buildSubject()

    let Dog = try schema[object: "Dog"].xctUnwrapped()

    let actual = subject.render(type: Dog).description

    // then
    expect(actual).to(equalLineByLine(expected))
  }

  func test__render__givenFieldsOnInterface_rendersReferencedFields() throws {
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

    let expected =
    """
    @Field("a") public var a: String?
    @Field("b") public var b: String?
    """

    // when
    try buildSubject()

    let Dog = try schema[interface: "Dog"].xctUnwrapped()

    let actual = subject.render(type: Dog).description

    // then
    expect(actual).to(equalLineByLine(expected))
  }

  func test__render__givenObject_withFieldsFromInterface_rendersReferencedFields() throws {
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
          b
        }
      }
    }
    """

    let expected =
    """
    @Field("a") public var a: String?
    @Field("b") public var b: String?
    """

    // when
    try buildSubject()

    let Dog = try schema[object: "Dog"].xctUnwrapped()

    let actual = subject.render(type: Dog).description

    // then
    expect(actual).to(equalLineByLine(expected))
  }

  func test__render__givenObject_withFieldsFromFragment_rendersReferencedFields() throws {
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

    let expected =
    """
    @Field("a") public var a: String?
    @Field("b") public var b: String?
    """

    // when
    try buildSubject()

    let Dog = try schema[object: "Dog"].xctUnwrapped()

    let actual = subject.render(type: Dog).description

    // then
    expect(actual).to(equalLineByLine(expected))
  }

  func test__render__givenObject_withFieldsFromFragmentOnInterface_rendersReferencedFields() throws {
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

    let expected =
    """
    @Field("a") public var a: String?
    @Field("b") public var b: String?
    """

    // when
    try buildSubject()

    let Dog = try schema[object: "Dog"].xctUnwrapped()

    let actual = subject.render(type: Dog).description

    // then
    expect(actual).to(equalLineByLine(expected))
  }

  func test__render__givenObject_withFieldsFromQueryOnImplementedInterface_rendersReferencedFields() throws {
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

    let dog_expected =
    """
    @Field("a") public var a: String?
    @Field("b") public var b: String?
    """

    let animal_expected =
    """
    @Field("a") public var a: String?
    """

    // when
    try buildSubject()

    let Dog = try schema[object: "Dog"].xctUnwrapped()
    let Animal = try schema[interface: "Animal"].xctUnwrapped()

    let dog_actual = subject.render(type: Dog).description
    let animal_actual = subject.render(type: Animal).description

    // then
    expect(dog_actual).to(equalLineByLine(dog_expected))
    expect(animal_actual).to(equalLineByLine(animal_expected))
  }

}
