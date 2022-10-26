import XCTest
import ApolloAPI
import Nimble

final class InputDictTests: XCTestCase {

  struct MockInputObject: InputObject {
    var __data: InputDict

    init(_ data: InputDict) {
      __data = data
    }

    init(hash: GraphQLNullable<String> = nil) {
      __data = InputDict(["hash": hash])
    }

    public var hash: GraphQLNullable<String> {
      get { __data["hash"] }
      set { __data["hash"] = newValue }
    }
  }

  func test__inputDict__shouldConformToHashable() {
    // given
    let subject = MockInputObject(hash: .some("MyValue"))

    // then
    var hasher = Hasher()
    subject.__data.hash(into: &hasher)
  }

  func test__inputDict__givenPropertyNameMatchingHashableFunctionName_shouldInitializeWithPropertyName() {
    // given
    let subject = MockInputObject(hash: .some("MyValue"))

    // then
    expect(subject.hash).to(equal(.some("MyValue")))
  }

  func test__inputDict__givenPropertyNameMatchingHashableFunctionName_shouldInitializeWithInputDict() {
    // given
    let subject = MockInputObject(.init(["hash": GraphQLNullable.some("MyValue")]))

    // then
    expect(subject.hash).to(equal(.some("MyValue")))
  }

}
