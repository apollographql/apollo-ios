import XCTest
import Nimble
@testable import ApolloCodegenLib

class IRCustomScalarTests: XCTestCase {
  func test__givenScalarString__shouldAppendToScalarsSet() {
    // given
    let scalar = GraphQLScalarType.string()

    // when
    let subject = IR.Schema.ReferencedTypes.init([scalar])

    // then
    expect(subject.scalars).to(equal([scalar]))
    expect(subject.customScalars).to(beEmpty())
  }

  func test__givenScalarInt__shouldAppendToScalarsSet() {
    // given
    let scalar = GraphQLScalarType.integer()

    // when
    let subject = IR.Schema.ReferencedTypes.init([scalar])

    // then
    expect(subject.scalars).to(equal([scalar]))
    expect(subject.customScalars).to(beEmpty())
  }

  func test__givenScalarBool__shouldAppendToScalarsSet() {
    // given
    let scalar = GraphQLScalarType.boolean()

    // when
    let subject = IR.Schema.ReferencedTypes.init([scalar])

    // then
    expect(subject.scalars).to(equal([scalar]))
    expect(subject.customScalars).to(beEmpty())
  }

  func test__givenScalarFloat__shouldAppendToScalarsSet() {
    // given
    let scalar = GraphQLScalarType.float()

    // when
    let subject = IR.Schema.ReferencedTypes.init([scalar])

    // then
    expect(subject.scalars).to(equal([scalar]))
    expect(subject.customScalars).to(beEmpty())
  }

  func test__givenScalarID__shouldAppendToScalarsSet() {
    // given
    let scalar = GraphQLScalarType.mock(name: "ID")

    // when
    let subject = IR.Schema.ReferencedTypes.init([scalar])

    // then
    expect(subject.scalars).to(equal([scalar]))
    expect(subject.customScalars).to(beEmpty())
  }

  func test__givenCustomScalar__shouldAppendToCustomScalarsSet() {
    // given
    let scalar = GraphQLScalarType.mock(name: "CustomScalar")

    // when
    let subject = IR.Schema.ReferencedTypes.init([scalar])

    // then
    expect(subject.customScalars).to(equal([scalar]))
    expect(subject.scalars).to(beEmpty())
  }

  func test__givenCustomScalarWithSpecifiedByURL__shouldAppendToCustomScalarsSet() {
    // given
    let scalar = GraphQLScalarType.mock(
      name: "String",
      specifiedByURL: "https://tools.ietf.org/html/rfc4122"
    )

    // when
    let subject = IR.Schema.ReferencedTypes.init([scalar])

    // then
    expect(subject.customScalars).to(equal([scalar]))
    expect(subject.scalars).to(beEmpty())
  }
}
